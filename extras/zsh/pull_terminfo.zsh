pull_terminfo() {
	if ! find $HOME/.terminfo -name "wezterm" -print -quit | grep -q .; then
		local tempfile=$(mktemp) &&
			curl -o $tempfile https://raw.githubusercontent.com/wez/wezterm/main/termwiz/data/wezterm.terminfo &&
			tic -x -o ~/.terminfo $tempfile &&
			rm $tempfile
	fi
}

pull_terminfo
