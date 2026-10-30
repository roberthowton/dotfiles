#!/usr/bin/env python3
"""Cross-check scanned DOI/ISBN candidates against the library's BBT biblatex
export, and annotate each with whether it's already in the library.

Why this exists: the zotero-mcp server's own duplicate check
(``if_exists="skip"``) pre-filters candidates via a Zotero quicksearch on the
bare identifier. That quicksearch does a literal substring match against the
stored field text. DOIs are stored bare, so DOI dedup works. ISBNs are
commonly stored hyphenated (e.g. "978-0-8425-2353-0"), so a bare-digit query
like "9780842523530" never matches and the built-in dedup silently misses it
-- creating a real duplicate item. This script does the normalized comparison
ourselves against a full export of the library instead of trusting that
quicksearch.

Also flags DOIs/ISBNs found more than once WITHIN this same scan batch (e.g.
two different downloads of the same book). IMPORTANT: a shared identifier
does NOT reliably mean "same file" -- this library has multi-volume works
(Boyle's collected works, Alexander of Aphrodisias' Metaphysics commentary,
Anscombe's collected papers, Plotinus' Enneads) where Anna's Archive's
cataloging reuses ONE ISBN across several genuinely different volumes.
Treating same-identifier as same-file would silently drop real, distinct
volumes. So identifier collisions are only auto-resolved as a true duplicate
when the files are byte-identical (content hash match); otherwise they're
routed to a manual-review bucket instead of being guessed at either way.

Reads scan_downloads.py's JSONL from stdin, writes the same objects to
stdout with fields added:
  "already_in_library" (bool), "matched_citekey" (str or null) -- matches an
    item already in the Zotero library.
  "batch_duplicate" (bool), "duplicate_of" (str or null) -- byte-identical to
    another, earlier file in this same scan (path of the primary copy).
  "identifier_collision" (bool), "collision_with" (list of str) -- shares a
    DOI/ISBN with other file(s) in this batch but is NOT byte-identical to
    them (different volume, different scan, etc.) -- needs manual review,
    not auto-imported.
"""
import hashlib
import json
import re
import sys
from pathlib import Path


def file_hash(path: str) -> str:
    h = hashlib.md5()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()

ENTRY_SPLIT_RE = re.compile(r"\n(?=@\w+\{)")
CITEKEY_RE = re.compile(r"^@\w+\{([^,]+),")
ISBN_FIELD_RE = re.compile(r"isbn\s*=\s*\{([^}]*)\}", re.IGNORECASE)
DOI_FIELD_RE = re.compile(r"doi\s*=\s*\{([^}]*)\}", re.IGNORECASE)


def norm_isbn(s: str) -> str:
    """Strip formatting and canonicalize to ISBN-13 digits.

    Bug this fixes: scanned candidates are often printed/embedded as ISBN-10
    (10 digits), while this library's items are typically cataloged as
    ISBN-13 (13 digits, Zotero/OpenLibrary's standard). A pure digit-strip
    never bridges the two -- "0226767485" (ISBN-10) and "9780226767482"
    (ISBN-13) are the same book but never string-equal without conversion.
    Confirmed to cause silent duplicate creation (Sober, Hegel, 2026-08-05).
    """
    digits = re.sub(r"[^0-9Xx]", "", s).upper()
    if len(digits) == 10:
        core = digits[:9]
        total = sum((10 - i) * int(d) for i, d in enumerate(core))
        check = (11 - (total % 11)) % 11
        if check == 10:
            # Invalid as ISBN-10 (check digit would be 'X' at position 10,
            # which doesn't map to an ISBN-13 check digit) -- return as-is.
            return digits
        isbn10 = core + str(check)
        # Only trust the conversion if the given check digit actually
        # validates; otherwise the source may not really be an ISBN-10.
        prefix = "978" + isbn10[:9]
        total13 = sum((1 if i % 2 == 0 else 3) * int(d) for i, d in enumerate(prefix))
        check13 = (10 - (total13 % 10)) % 10
        return prefix + str(check13)
    return digits


def norm_doi(s: str) -> str:
    return s.strip().lower()


def load_existing(bib_path: Path):
    text = bib_path.read_text(encoding="utf-8")
    existing_isbn, existing_doi = {}, {}
    for entry in ENTRY_SPLIT_RE.split(text):
        m = CITEKEY_RE.match(entry)
        if not m:
            continue
        citekey = m.group(1)
        for isbn_m in ISBN_FIELD_RE.finditer(entry):
            for token in isbn_m.group(1).split():
                n = norm_isbn(token)
                if len(n) in (10, 13):
                    existing_isbn[n] = citekey
        doi_m = DOI_FIELD_RE.search(entry)
        if doi_m:
            existing_doi[norm_doi(doi_m.group(1))] = citekey
    return existing_isbn, existing_doi


def main():
    if len(sys.argv) != 2:
        print("usage: check_existing.py <bib_path>  (reads scan JSONL on stdin)", file=sys.stderr)
        sys.exit(1)

    existing_isbn, existing_doi = load_existing(Path(sys.argv[1]).expanduser())

    rows = [json.loads(line) for line in sys.stdin if line.strip()]

    for row in rows:
        citekey = None
        if row.get("id_type") == "doi":
            citekey = existing_doi.get(norm_doi(row["id_value"]))
        elif row.get("id_type") == "isbn":
            citekey = existing_isbn.get(norm_isbn(row["id_value"]))
        row["already_in_library"] = citekey is not None
        row["matched_citekey"] = citekey
        row["batch_duplicate"] = False
        row["duplicate_of"] = None
        row["identifier_collision"] = False
        row["collision_with"] = []

    # Group by (id_type, normalized_id) to find identifier collisions.
    groups = {}
    for row in rows:
        if row.get("id_type") not in ("doi", "isbn"):
            continue
        norm = norm_doi(row["id_value"]) if row["id_type"] == "doi" else norm_isbn(row["id_value"])
        groups.setdefault((row["id_type"], norm), []).append(row)

    for members in groups.values():
        if len(members) < 2:
            continue
        # Sub-group by actual file content hash -- only byte-identical files
        # are treated as a confirmed duplicate. Order preserved (scan output
        # is already alphabetically sorted), so the first hash seen is primary.
        by_hash = {}
        for row in members:
            try:
                h = file_hash(row["path"])
            except OSError:
                h = None  # unreadable file: treat as its own singleton group
            by_hash.setdefault(h, []).append(row)

        if len(by_hash) == 1:
            # Every member of this identifier group is byte-identical: a
            # clean re-download, not a different volume.
            primary, *dupes = members
            for d in dupes:
                d["batch_duplicate"] = True
                d["duplicate_of"] = primary["path"]
            continue

        # Multiple distinct file contents share this identifier. Any
        # byte-identical pair within that is still a confirmed duplicate;
        # anything left with a unique hash is ambiguous (could be a
        # different volume cataloged under the same ISBN) -- flag for
        # manual review rather than guessing.
        for h, subgroup in by_hash.items():
            if h is not None and len(subgroup) > 1:
                primary, *dupes = subgroup
                for d in dupes:
                    d["batch_duplicate"] = True
                    d["duplicate_of"] = primary["path"]
            else:
                for row in subgroup:
                    row["identifier_collision"] = True
                    row["collision_with"] = [r["path"] for r in members if r is not row]

    for row in rows:
        print(json.dumps(row))


if __name__ == "__main__":
    main()
