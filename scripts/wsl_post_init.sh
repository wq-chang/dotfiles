#!/bin/bash

mv /tmp/dotfiles $HOME/dotfiles
mv /home/nixos/.ssh ./.ssh
cd $HOME/dotfiles
sudo rm -rf /home/nixos
sudo nixos-rebuild switch --flake .#wsl && upcmp && sudo shutdown -h now
