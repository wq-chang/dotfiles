upcmp() {
	cacheDir=$HOME/.zsh_plugins/.cache
	fishDir=$cacheDir/fish
	cacheCmpDir=$cacheDir/completions
	cmcpy=$cacheDir/create_manpage_completions.py
	drpy=$cacheDir/deroff.py

	if [ ! -d "$fishDir" ]; then
		mkdir -p "$fishDir"
	fi
	if [ ! -d "$cacheCmpDir" ]; then
		mkdir -p "$cacheCmpDir"
	fi
	curl -s -o $cmcpy -O https://raw.githubusercontent.com/fish-shell/fish-shell/master/share/tools/create_manpage_completions.py
	curl -s -o $drpy -O https://raw.githubusercontent.com/fish-shell/fish-shell/master/share/tools/deroff.py
	python $cmcpy --manpath --cleanup-in $fishDir -d $fishDir --progress
	zsh-manpage-completion-generator -clean -src $fishDir -dst $cacheCmpDir
	rm -rf $fishDir
	rm $cmcpy
	rm $drpy

	urls=(
		"https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/terraform/_terraform"
		"https://raw.githubusercontent.com/docker/cli/master/contrib/completion/zsh/_docker"
	)

	for url in "${urls[@]}"; do
		filename=$(basename "$url")
		curl -s -o "$cacheCmpDir/$filename" "$url"
		if [ $? -eq 0 ]; then
			echo "Completion script '$filename' downloaded successfully."
		else
			echo "Failed to download completion script '$filename'."
		fi
	done
}
