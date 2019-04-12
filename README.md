# debian-setup-steps (NOT FIT FOR PUBLIC CONSUMPTION, THIS IS A WORK IN PROGRESS)
 
The steps currently described are for installing Debain from
firmware-9.8.0-amd64-netinst.iso or firmware-buster-DI-alpha5-amd64-netinst.iso
on a dell xps 15 9570, I couldn't get either to work satisfactorily, so I gave
up and installed ubuntu from
https://github.com/JackHack96/dell-xps-9570-ubuntu-respin instead. This
document serves as a starting point in the case I try to install debian again
at a later date.

The (Environment setup)[#Environment-setup] section is however still useful
since it is independent of Linux distributions and releases.

# Pre-install

## BIOS firmware updates
Start by checking for BIOS firmware updates, if found they may require windows
or dos to be installed, so install them before destroying the existing OS.

If you already destroyed the existing OS then follow these steps:

*Note: lots of people advocate using unetbootin, it didn't work for me with the
binary `unetbootin-linux64-661.bin`. I tested this on 2 laptops and the images
were just not bootable.*

1. You may be able to use fwupd `sudo apt install fwupd` to grab the firmware
   and install it automatically. 
1. If you have a Dell pc you may be able to stick the BIOS exe onto a FAT32
   drive and then apply the update via the flash update option of the boot menu
   (hold F12 on startup for the boot menu). Dell page describing the process
   [here](https://www.dell.com/support/article/uk/en/ukdhs1/sln171755/updating-the-dell-bios-in-linux-and-ubuntu-environments)
1. Have a look at the [debian](https://wiki.debian.org/Firmware/Updates) and
   [arch](https://wiki.archlinux.org/index.php/Flashing_BIOS_from_Linux) pages
   covering this, the arch one has a good looking guide to creating a bootable
   DOS drive (though untested).

## BIOS Tweaks for Dell XPS 15 9570
Needed to configure hard disk to ACHI mode instead of RAID, the hard disks were not being discovered.

# Install

Download the netinstaller with non-free firmware not the basic one, this will
save you a heap of trouble. Find the added non free firmware iso
[here](https://cdimage.debian.org/cdimage/unofficial/non-free/cd-including-firmware)
you will need to click through a few pages to find the right iso for you.

Note: Despite complaining during install that certain firmware files could not
be found, my network card did actually work, so sometimes it's just worth
pressing on to see if stuff works.

Copy it onto a USB drive like so:
```
sudo dd if=firmware-9.8.0-amd64-netinst.iso of=/dev/sdb bs=32MB
```
Note: make sure you are dd ing to the right drive use `sudo fdisk -l` to check which drive is which.

Restart and boot from the USB, despite setting my boot order to have USB first
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
1. Select the free space and create an efi partition at the beginning of the
   drive 1G to be safe or 500MB if you are short on space.
1. Select the free space and create a boot partition, set its use to be 'Ext 4
   journaling file system'.
1. Select the remaining free space and create another partition using all the
   space and set its use to be 'physical volume for encryption'
1. Back on the main screen select 'configure encrypted volumes' and accept the
   propmpt and then choose finish.
1. The installer will write random data all across the drive, this makes free
   space indistinguishable from encrypted data. This process takes some time.
1. Once done select 'Configure the Logical Volume Manager' and write the
   current partitioning scheme to disk.
1. In the Logical Volume Manager create a volume group and all the volumes you
   want i'm going for a swap partition, /home and /.
1. Once done you will now need to select the free space in each of your logical
   voumes and configure its use, so in my case the swap will be swap and the
   rest will be 'Ext4 journaling file system' with the corresponding mount
   points set.
1. Once finished you are done for partitioning!

## Installing the base system

When prompted choose the generic kernel, this ensures that when you upgrade
your kernel can be upgraded automatically.

## Installing GRUB

When I tried to install grub it failed to install on a fully encrypted disk.

The workaround is to drop to the terminal ALT+F2 and edit /target/etc/default/grub to add the line
`GRUB_ENABLE_CRYPTODISK=y`
And then retry the grub install

## Installing Software

Should you install the standard system utilities:
* Probably yes, answered [here](https://unix.stackexchange.com/questions/307600/whats-the-consequences-if-i-dont-install-the-standard-system-utilities-of-de)

# Post install

## Debian fixes

Remove the bell

Add 'xset b off' to `~/.profile` or some file that is executed on startup. You
can use the following to find files sorted by access date which is useful to
see what is being consulted on startup.
```
find . -type f -printf '%a %p\n' | sort -h | less
```

## Environment setup

If you want to share sudo between terminals
create file /etc/sudoers.d/01_local with content `Defaults !tty_tickets`

Download and install chrome https://www.google.com/chrome. I don't store
passwords in chrome so I don't need a keyring integration.

Locate google-chrome.desktop and add `--password-store=basic` to the end of any Exec entries.

ssh-keygen -t rsa -b 3072

Add key to github.

Run the following, setting the user email to use for git global config. (Note
email parameterisation as yet untested) This installs useful packages and
configures zsh and nvim.

```
bash -c "$(
	GIT_USER_EMAIL=<email_for_git_user> ; \
	wget --quiet --output-document - \
	https://raw.githubusercontent.com/piersy/debian-setup-steps/master/dev_env_setup.sh \
	)"
```

Log out and back in.

## Hardware config

I installed firmware-linux-free and firmware-linux-nonfree but didnt see any improvement due to that.

Then I installed the backports kernel with 
sudo apt install -t stretch-backports linux-image-amd64

Configure touch pad using libinput

Useful page from dell support - https://www.dell.com/support/article/uk/en/ukdhs1/sln308258/precision-xps-ubuntu-general-touchpad-mouse-issue-fix?lang=en

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

sudo gedit /usr/share/X11/xorg.conf.d/\*libinput.conf Now find the section that
has the wording - Identifier "libinput touchpad catchall" and type in the
following changes between the lines MatchDevicePath "/dev/input/event\*" and
Driver "libinput":

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

## LightDM configuration

It seems that debian when used with lightdm does not execute ~/.xinitrc

Instead the flow is that lightdm loads a desktop file from /usr/share/xsessions
desktop files can execute only a single command using the Exec entry, if you
want to initialise something (or execute more than one program) at this point
you need to write a script and call it from the Exec entry.

Light dm has a desktop file as well with the Exec entry specifying default
which actually means that light dm will look in ~/.dmrc to find out what
session to load by default.

If you want to initialise something that is going to be shared by all window
managers you can edit/etc/lightdm/lightdm.conf and set display-setup-script or
greeter-setup-script to perform general setup.

## Problems

ACPI was problematic, interesting text here -
https://github.com/torvalds/linux/blob/master/Documentation/acpi/osi.txt

# Useful commands

Find files sorted by access date: 
```
find . -type f -printf '%a %p\n' | sort -h | less
```

Get source code of your kernel:
```
apt-get source linux-image-$(uname -r)
```

Which graphics card are you using?
```
glxinfo | grep render
```
OpenGL renderer entry will give you the answer:

List all the devices, anything without a kernel module is hardware that is not
properly detected.
```
lspci -v
```

# Fonts

I like SF Mono as a font

get a copy here:
https://github.com/ZulwiyozaPutra/SF-Mono-Font

or one with powerline symbols:
https://github.com/artofrawr/powerline-fonts/raw/master/fonts/SFMono/SF%20Mono%20Regular%20Nerd%20Font%20Complete.otf
(as yet untested since gnome terminal does not show patched fonts?)
https://superuser.com/questions/1335155/patched-fonts-not-showing-up-on-gnome-terminal

Or a thread with some useful info on patching SF Mono yourself - https://github.com/powerline/fonts/issues/189

I've included the font config I was using for the SF Mono it should be placed here ~/.config/fontconfig/fonts.conf

Useful commands for working with fonts.

Force reload all fonts:
fc-cache -fv 

View detailed info on all fonts
fc-list -v | less

View the fallback font heirarchy for a font
fc-match -s "SF Mono"

# Compose key

set XKBOPTIONS="compose:ralt" in /etc/default/keyboard

Then run the following to set the compose key for this X session only:
setxkbmap -option compose:ralt

This should go in the script



