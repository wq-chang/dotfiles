#!/bin/bash
curdir=$(pwd)
cd ${HOME}/dotfiles/configs

for d in *; do
	stow -d $(pwd) -t ${HOME} -R ${d}
done

cd ${curdir}
unset curdir
echo "Updated all dotfiles"
