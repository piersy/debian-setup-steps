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
zsh \
inxi \
acpitool \
silversearcher-ag \
cmake \
ccache \
build-essential

echo ""
echo "Setting global git options"
git config --global url.ssh://git@github.com/.insteadof https://github.com/
git config --global user.email $GIT_USER_EMAIL
git config --global merge.conflictstyle diff3
git config --global core.autocrlf input
git config --global help.autocorrect 5
git config --global color.diff.meta "magenta"

echo ""
echo "Installing golang"
# Get the latest golang amd64 release

golatestrelease=$(wget --quiet --output-document - \
	https://github.com/golang/go/tags \
	| perl -ne 'm/release-branch.* (.+?)$/ && print $1."\n"' \
	| head -n 1)


godownload=$golatestrelease.linux-amd64.tar.gz
wget https://dl.google.com/go/$godownload
mkdir -p $HOME/programs
tar -xvf $godownload -C $HOME/programs
rm $godownload
mv $HOME/programs/go $HOME/programs/$golatestrelease
sudo ln -s $HOME/programs/$golatestrelease /usr/local/go
export PATH=$PATH:/usr/local/go/bin

echo ""
echo "Setting up zsh"
mkdir -p $HOME/projects
cd $HOME/projects
git clone --recursive git@github.com:piersy/dotfiles.git
ln -s projects/dotfiles/.zshrc $HOME/.zshrc 
# Set root to have same config
sudo ln -s $HOME/.zshrc /root/.zshrc 
sudo mkdir -p /root/projects
sudo ln -s $HOME/projects/dotfiles /root/projects/dotfiles

echo ""
echo "Changing default shell to zsh, you will be prompted for your user password"
chsh -s $(which zsh)
# Set root to have same config
sudo chsh -s $(which zsh)

cd $HOME/projects
git clone git@github.com:junegunn/fzf.git 
./fzf/install --no-update-rc --completion --key-bindings

# copy fzf config for root
sudo ln -s $HOME/.fzf.zsh /root/.fzf.zsh
sudo ln -s $HOME/.fzf.bash /root/.fzf.bash

mkdir -p $HOME/bin
# Set root to have same config
sudo ln -s $HOME/bin /root/bin

echo ""
echo "Setting up neovim"

echo "Installing pakcages needed for nvim plugins"
# xclip allows system copy to be pasted with p in vim and vice versa.
# python and python3 are required for any python plugins in nvim.
# libboost-all-dev is needed to build cpsm.
sudo apt install -y \
xclip \
python3-pip \
python-pip \
libboost-all-dev

# Get the latest neovim appimage url
neovimurl=$(wget --quiet --output-document - \
	https://api.github.com/repos/neovim/neovim/releases/latest \
	| grep '\.appimage"' \
	| perl -ne 'm/"browser_download_url":.*?"(.+?)"$/ && print $1."\n"')

cd $HOME/bin
wget --output-document nvim $neovimurl
chmod +x nvim
ln -s nvim vim

pip install --user --upgrade pynvim
pip3 install --user --upgrade pynvim

cd $HOME/.config
git clone git@github.com:piersy/nvim.git
mkdir -p nvim/autoload

# Put vim plug in place
wget --quiet --output-document nvim/autoload/plug.vim \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# let root use the same nvim config
sudo mkdir -p /root/.config
sudo ln -s $HOME/config/nvim /root/.config/nvim


echo ""
echo "zsh and nvim installed"
echo "Logout and back in to make zsh your default shell or just run zsh for now."
echo "Run :PlugInstall in nvim to install plugins, then close and re-open"
