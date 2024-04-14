pullThemes() {
	curdir=$(pwd)

	echo "Pulling Bat themes"
	mkdir -p "$(bat --config-dir)/themes"
	cd "$(bat --config-dir)/themes"
	curl -O https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/sublime/tokyonight_night.tmTheme
	bat cache --build
	echo "Pulled Bat themes"

	echo "Pulling Wezterm themes"
	mkdir -p $HOME/dotfiles/extras/wezterm
	cd $HOME/dotfiles/extras/wezterm
	curl -O https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/wezterm/tokyonight_night.toml
	echo "Pulled Wezterm themes"

	cd $curdir
}
