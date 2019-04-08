# debian-setup-steps

Debian Stretch

It seems that debian when used with lightdm does not execute ~/.xinitrc

Instead the flow is that lightdm loads a desktop file from /usr/share/xsessions desktop files can execute only a single command using the Exec entry, if you wan't to initialise something (or execute more than one program) at this point you need to write a script and call it from the Exec entry.

Light dm has a desktop file as well with the Exec entry specifying default hich actually means that light dm will look in ~/.dmrc to find out what session to load by defalut.

If you want to initialise something that is going to be shared by all window managers you can edit/etc/lightdm/lightdm.conf and set display-setup-script or greeter-setup-script to perform general setup.

Adding custom drivers

# Preinstall

## Bios firmware updates
Start by checking for bios firmware updates, if found they may require windows
or dos to be installed, so install them before destroying the existing os.

If you already destroyed the existing OS then follow these steps:

*Note: lots of people advocate using unetbootin, it didn't work for me with the
binary `unetbootin-linux64-661.bin`. I tested this on 2 laptops and the images
were just not bootable.*

1. You may be able to use fwupd `sudo apt install fwupd` to grab the firmware
   and install it automatically. 
1. If you have a Dell pc you may be able to stick the bios exe onto a FAT32
   drive and then apply the update via the flash update option of the boot menu
   (hold F12 on startup for the boot menu). Dell page describing the process
   [here](https://www.dell.com/support/article/uk/en/ukdhs1/sln171755/updating-the-dell-bios-in-linux-and-ubuntu-environments)
1. Have a look at the [debian](https://wiki.debian.org/Firmware/Updates) and
   [arch](https://wiki.archlinux.org/index.php/Flashing_BIOS_from_Linux) pages
   covering this, the arch one has a good looking guide to createing a bootable
   dos drive (though untested).

## Bios Tweaks for Dell XPS 15 9570
Needed to configure hard disk to achi mode instead of raid, the hard disks were not being discovered.

# Install

Download the netinstaller with non-free firmware not the basic one, this will
save you a heap of trouble. Find the added non free firmware iso
[here](https://cdimage.debian.org/cdimage/unofficial/non-free/cd-including-firmware)
you will need to click through a few pages to find the right iso for you.

Copy it onto a usb drive like so:
```
sudo dd if=firmware-9.8.0-amd64-netinst.iso of=/dev/sdb bs=32MB
```
Note: make sure you are dd ing to the right drive use `sudo fdisk -l` to check which drive is which.

Restart and boot from the usb, despite setting my boot order to have usb first
my XPS 15 seemed to ignore it so I just booted with the F12.

Useful keys to know:
* ALT+F2 -> terminal
* ALT+F4 -> logs
* ALT+F1 -> the installer

Select Advanced Options > Expert install.

Bring up the [debian
handbook](https://debian-handbook.info/browse/stable/sect.installation-steps.html)
it will answer most questions you may have during installation.

## Partitioning

*Note: Sizes in the debian installer are listed in MB GB and TB as oppsed to MiB GiB and TiB.*

Very useful videos covering partitioning for encrypted disks in case you get
stuck [part1](https://www.youtube.com/watch?v=etzJAG_H5F8)
[part2](https://www.youtube.com/watch?v=yJdBIigQcVw)

What type partition table:
* If you need to dual boot Windows and Linux, then msdos.
* Linux style systems only, then gpt.

**These steps are for a gpt partition table**
1. Select the drive to partition, follow the prompts to erase all partitions.
1. Choose gpt partition table type.
1. Select the free space and create an efi partition at the beginning of the drive 1G to be safe or 500MB if you are short on space.
//1. Select the free space and create a boot partition, set its use to be 'Ext 4 journaling file system'.
1. Select the remaining free space and create another partition using all the space and set its use to be 'physical volume for encryption'
1. Back on the main screen select 'configure encrypted volumes' and accept the propmpt and then choose finish.
1. The installer will write random data all across the drive, this makes free space indistinguishable from encrypted data. This process takes some time.
1. Once done select 'Configure the Logical Volume Manager' and write the current partitioning scheme to disk.
1. In the Logical Volume Manager create a volume group and all the volumes you
   want i'm going for a swap partition, /home and /.
1. Once done you will now need to select the free space in each of your logical
   voumes and configure its use, so in my case the swap will be swap and the
   rest will be 'Ext4 journaling file system' with the corresponding mount
   points set.
1. Once finished you are done for partitioning!

## Installing the base system

When prompted choose the generic kernel, this ensures that when you upgrade
your kernel can be updgraded automatically.

## Installing GRUB

When I tried to install grub it failed
We need to create a boot partition ext4 unencrypted at '/boot' and then use the
rest of the space as physical drive for encryption. Inside which we can
configure as many partitions as we want using lvm.

> Configure encrypted volumes

At this point the partitions will be written to the disk, takes a while.

> Configure the Logical Volume Manager

Note: Despite complaining that certain firmware files could not be found, my newtwork card did actually work, so sometimes it's just worth pressing on to see if stuff works.

-----

In fact I did install grub by dropping to the terminal ALT+F2 and editing /target/etc/default/grub to add the line
`GRUB_ENABLE_CRYPTODISK=y`
And then retrying the grub install

## Installing Software

Should you install the standard system utilities:
* Probably yes, answered [here](https://unix.stackexchange.com/questions/307600/whats-the-consequences-if-i-dont-install-the-standard-system-utilities-of-de)

# Post install

Share sudo between terminals
create file /etc/sudoers.d/01_local with content `Defaults !tty_tickets`

install packages i need

sudo apt install
git
locate
fwupd // handles firmware updates automatically
tree
htop
checkinstall
python-pip3 // for installing pynvim
python-pip // for installing pynvim
xclip // to allow copying between vim and clipboard
zsh
inxi // outputs system stats useful for high level investigations
acpitool // useful for digging into acpi config
silversearcher-ag

download and install chrome https://www.google.com/chrome/

locate google-chrome.desktop and add `--password-store=basic` to the end of any Exec entries

I had two on my machine

/home/piers/.local/share/xfce4/helpers/google-chrome.desktop
/usr/share/applications/google-chrome.desktop

The first seemed to have no effect, so I had to go for the second.

ssh-keygen -t rsa -b 3072

Add key to github

mkdir $HOME/projects
cd $HOME/projects
git clone git@github.com:piersy/dotfiles.git
cd $HOME
ln -s .zshrc projects/.zshrc
chsh -s $(which zsh)

log out and back in


get neovim https://github.com/neovim/neovim/releases

put it in

mkdir $HOME/bin
cd $HOME/bin
mv $HOME/Downloads/nvim.appimage $HOME/bin/nvim
ln -s nvim vim
pip install --user --upgrade pynvim
pip3 install --user --upgrade pynvim

cd $HOME/.config

git clone git@github.com:piersy/nvim.git

now open vim and run :PlugInstall then close and open vim and you should have enverything setup.

Remove the bell

Add 'xset b off' to ~/.profile

I wasn't sure where to put the command but i looked at the files sorted by access time using
find files sorted by access date really useful for discovering what files are consulted on startup
find . -type f -printf '%a %p\n' | sort -h | less

## Hardware config

I installed firmware-linux-free and firmware-linux-nonfree but didnt see any improvement due to that.

Then I installed the backports kernel with 
sudo apt install -t stretch-backports linux-image-amd64

apt-get source linux-image-$(uname -r) // get the source for your linux distro, useful in solving some issues.

Configure touch pad using libinput

useful page from dell support - https://www.dell.com/support/article/uk/en/ukdhs1/sln308258/precision-xps-ubuntu-general-touchpad-mouse-issue-fix?lang=en

My config was here `/usr/share/X11/xorg.conf.d/40-libinput.conf`

Now find the section that has the wording - Identifier "libinput touchpad
catchall" and add your options between the lines MatchDevicePath
"/dev/input/event\*" and Driver "libinput":

I set these options

Option "Tapping" "True"
Option "AccelProfile" "adaptive"
Option "AccelSpeed" "0.8"
Option "DisableWhileTyping" "True"
Option "TappingButtonMap" "lrm"



Set pointer acceleration

to look at input devices 

xinput list

To set a prop with xinput

xinput --set-prop 'SynPS/2 Synaptics TouchPad' 'libinput Accel Speed' 1.0

sudo gedit /usr/share/X11/xorg.conf.d/*libinput.conf
Now find the section that has the wording - Identifier "libinput touchpad catchall" and type in the following changes between the lines MatchDevicePath "/dev/input/event*" and Driver "libinput":

Option "Tapping" "True"
Option "TappingDrag" "True"
Option "DisableWhileTyping" "True"
Option "AccelProfile" "adaptive"
Option "AccelSpeed" "0.4"
Option "SendEventsMode" "disabled-on-external-mouse"

lightdm stop having to type username - https://wiki.debian.org/LightDM#Enable_user_list

I edited /usr/share/lightdm/lightdm.conf.d/01_debian.conf but it didnt seem to work.

No sound

use lspci -v to list all the devices, anything without a kernel module is
hardware that is not properly detected.

## Problems



ACPI
interesting text here - https://github.com/torvalds/linux/blob/master/Documentation/acpi/osi.txt

Which graphics card are you using?
```
glxinfo | grep render
```
OpenGL renderer entry will give you the answer:

