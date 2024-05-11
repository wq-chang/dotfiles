pullthemes() {
	local curdir=$(pwd)

	local extraswez=$HOME/dotfiles/configs/wezterm
	echo "Pulling Wezterm themes"
	mkdir -p $extraswez
	cd $extraswez
	curl -O https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/wezterm/tokyonight_night.toml
	echo "Pulled Wezterm themes"

	cd $curdir
}
