pull_term_info() {
	if [[ ! -e "$HOME/.terminfo/w/wezterm" ]]; then
		tempfile=$(mktemp) &&
			curl -o $tempfile https://raw.githubusercontent.com/wez/wezterm/main/termwiz/data/wezterm.terminfo &&
			tic -x -o ~/.terminfo $tempfile &&
			rm $tempfile
	fi
}

pull_term_info
