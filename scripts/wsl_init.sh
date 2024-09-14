#!/bin/bash

echo "Enter the private SSH key (Press Ctrl+D when you're done):"
input=$(cat)

ssh_dir="$HOME/.ssh"
if [ ! -d "$ssh_dir" ]; then
	mkdir -p "$ssh_dir"
fi
cd "$ssh_dir"

filename="id_ed25519"
echo "$input" >"$filename"
chmod 700 "$filename"

sudo nix-env -i git
git clone git@github.com:wq-chang/dotfiles.git /tmp/dotfiles
cd /tmp/dotfiles
nix flake archive --extra-experimental-features nix-command --extra-experimental-features flakes
sudo nixos-rebuild boot --flake .#wsl && sudo shutdown -h now
