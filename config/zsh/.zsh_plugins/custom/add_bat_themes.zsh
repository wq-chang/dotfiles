addBatThemes() {
	curdir=$(pwd)
	mkdir -p "$(bat --config-dir)/themes"
	cd "$(bat --config-dir)/themes"
	curl -O https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/sublime/tokyonight_night.tmTheme
	bat cache --build
	cd $curdir
}
