#!/bin/bash
set -e

echo "Installing useful packages"
# install required packages
sudo apt install -y \
git \
locate \
fwupd \
tree \
htop \
checkinstall \
python3-pip \
python-pip \
xclip \
zsh \
inxi \
acpitool \
silversearcher-ag

echo ""
echo "Setting up zsh"
mkdir -p $HOME/projects
cd $HOME/projects
git clone git@github.com:piersy/dotfiles.git
cd $HOME
ln -s projects/dotfiles/.zshrc .zshrc 

echo ""
echo "Changing default shell to zsh, you will be prompted for your user password"
chsh -s $(which zsh)

echo ""
echo "Setting up neovim"

# Get the latest neovim appimage url
neovimurl=$(wget --quiet --output-document - \
	https://api.github.com/repos/neovim/neovim/releases/latest \
	| grep '\.appimage"' \
	| perl -ne 'm/"browser_download_url":.*?"(.+?)"$/ && print $1."\n"')

mkdir -p $HOME/bin
cd $HOME/bin
wget --output-document nvim $neovimurl
chmod +x nvim
ln -s nvim vim

pip install --user --upgrade pynvim
pip3 install --user --upgrade pynvim

cd $HOME/.config
git clone git@github.com:piersy/nvim.git

echo ""
echo "zsh and nvim installed"
echo "Logout and back in to make zsh your default shell or just run zsh for now."
echo "Run :PlugInstall in nvim to install plugins, then close and re-open"
