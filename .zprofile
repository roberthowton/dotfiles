
eval "$(/opt/homebrew/bin/brew shellenv)"

# ---- Eza (better ls) -----
alias ls="eza --icons=always"
alias ll="eza --icons=always -1 -l --color=always --all"
alias la='ls -A'
alias l='ls -CF'
alias diogenes='open /Applications/Diogenes.app/Contents/MacOS/Diogenes'
alias v='nvim'


# call yazi with 'y', exit in navigated directory with 'q',
# exit in original cwd with 'Q'
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

