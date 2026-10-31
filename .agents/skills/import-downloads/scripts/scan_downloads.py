#!/usr/bin/env python3
"""Scan a directory for top-level PDFs and detect a DOI or ISBN for each.

Read-only. Prints one JSON object per line (JSONL) to stdout:
  {"path": "...", "filename": "...", "id_type": "doi"|"isbn"|null, "id_value": "...", "source": "filename"|"text"|null}

Identifier detection order per file:
  1. DOI or ISBN encoded in the filename (Anna's Archive / libgen / JSTOR export conventions)
  2. DOI or ISBN found in the extracted text of the first few pages (via pdftotext)
  3. Nothing found -> id_type is null
"""
import json
import re
import subprocess
import sys
from pathlib import Path

DASH = "\\-\u2010\u2011\u2012\u2013\u2014"

DOI_FILENAME_RE = re.compile(r"^(10\.\d{4,9})[_@](.+)$")
# No \s in the class: these filenames use " -- " as a field separator, and an
# ISBN written with plain spaces is rare enough that excluding \s avoids
# bleeding across the separator into the next field (e.g. the MD5 hash).
ISBN13_LABELED_RE = re.compile(
    rf"isbn-?1[03]\s*[:\s]?\s*([0-9][0-9{DASH}]{{9,16}}[0-9Xx])", re.IGNORECASE
)
ISBN_BARE_RE = re.compile(r"(?<!\d)(97[89]\d{10})(?!\d)")

DOI_TEXT_RE = re.compile(r"\b10\.\d{4,9}/[-._;()/:A-Za-z0-9]+\b")
ISBN_TEXT_RE = re.compile(
    rf"ISBN(?:-1[03])?[:\s]*([0-9][0-9{DASH}]{{9,16}}[0-9Xx])", re.IGNORECASE
)
JSTOR_STABLE_RE = re.compile(r"jstor\.org/stable/(\d+)", re.IGNORECASE)


def clean_isbn(raw: str) -> str:
    return re.sub(rf"[\s{DASH}]", "", raw)


def doi_from_filename(stem: str):
    m = DOI_FILENAME_RE.match(stem)
    if not m:
        return None
    prefix, rest = m.groups()
    return f"{prefix}/{rest}"


def isbn_from_filename(name: str):
    m = ISBN13_LABELED_RE.search(name)
    if m:
        candidate = clean_isbn(m.group(1))
        if len(candidate) in (10, 13):
            return candidate
    m = ISBN_BARE_RE.search(name)
    if m:
        return m.group(1)
    return None


def extract_text(path: Path, pages: int = 8) -> str:
    try:
        result = subprocess.run(
            ["pdftotext", "-l", str(pages), str(path), "-"],
            capture_output=True, text=True, timeout=30,
        )
        return result.stdout or ""
    except Exception:
        return ""


def doi_from_text(text: str):
    m = DOI_TEXT_RE.search(text)
    if m:
        return m.group(0).rstrip(".,)")
    m = JSTOR_STABLE_RE.search(text)
    if m:
        return f"10.2307/{m.group(1)}"
    return None


def isbn_from_text(text: str):
    for m in ISBN_TEXT_RE.finditer(text):
        candidate = clean_isbn(m.group(1))
        if len(candidate) in (10, 13):
            return candidate
    return None


def scan_file(path: Path):
    stem = path.stem
    name = path.name

    doi = doi_from_filename(stem)
    if doi:
        return {"path": str(path), "filename": name, "id_type": "doi", "id_value": doi, "source": "filename"}

    isbn = isbn_from_filename(name)
    if isbn:
        return {"path": str(path), "filename": name, "id_type": "isbn", "id_value": isbn, "source": "filename"}

    text = extract_text(path)
    if text:
        doi = doi_from_text(text)
        if doi:
            return {"path": str(path), "filename": name, "id_type": "doi", "id_value": doi, "source": "text"}
        isbn = isbn_from_text(text)
        if isbn:
            return {"path": str(path), "filename": name, "id_type": "isbn", "id_value": isbn, "source": "text"}

    return {"path": str(path), "filename": name, "id_type": None, "id_value": None, "source": None}


def main():
    if len(sys.argv) != 2:
        print("usage: scan_downloads.py <directory>", file=sys.stderr)
        sys.exit(1)

    directory = Path(sys.argv[1]).expanduser()
    pdfs = sorted(p for p in directory.iterdir() if p.is_file() and p.suffix.lower() == ".pdf")

    for pdf in pdfs:
        print(json.dumps(scan_file(pdf)))


if __name__ == "__main__":
    main()
