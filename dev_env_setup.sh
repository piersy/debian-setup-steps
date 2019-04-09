# install required packages
sudo apt install -y
git \
locate \
fwupd \
tree \
htop \
checkinstall \
python-pip3 \
python-pip \
xclip \
zsh \
inxi \
acpitool \
silversearcher-ag

# setup shell
mkdir $HOME/projects
cd $HOME/projects
git clone git@github.com:piersy/dotfiles.git
cd $HOME
ln -s .zshrc projects/.zshrc
chsh -s $(which zsh)

# Get the latest neovim appimage url
neovimurl=wget --quiet --output-document - \
	https://api.github.com/repos/neovim/neovim/releases/latest \
	| grep '\.appimage"' \
	| perl -ne 'm/"browser_download_url":.*?"(.+?)"$/ && print $1."\n"'

mkdir $HOME/bin
cd $HOME/bin
wget --output-document nvim.appimage $neovimurl
ln -s nvim vim

pip install --user --upgrade pynvim
pip3 install --user --upgrade pynvim

cd $HOME/.config
git clone git@github.com:piersy/nvim.git

echo "zsh and nvim installed, run :PlugInstall in nvim to get plugins."
