# debian-setup-steps

Debian Stretch

It seems that debian when used with lightdm does not execute ~/.xinitrc

Instead the flow is that lightdm loads a desktop file from /usr/share/xsessions desktop files can execute only a single command using the Exec entry, if you wan't to initialise something (or execute more than one program) at this point you need to write a script and call it from the Exec entry.

Light dm has a desktop file as well with the Exec entry specifying default hich actually means that light dm will look in ~/.dmrc to find out what session to load by defalut.

If you want to initialise something that is going to be shared by all window managers you can edit/etc/lightdm/lightdm.conf and set display-setup-script or greeter-setup-script to perform general setup.

Adding custom drivers

Install

Needed to configure hard disk to achi mode instead of raid, the hard disks were not being discovered.

Download the netinstaller with non-free firmware not the basic one, this will save you a hea of trouble. Find the added non free firmware iso here https://cdimage.debian.org/cdimage/unofficial/non-free/cd-including-firmware/ you will need to click through a few pages to find the right iso for you.



and copy it onto a usb drive like so:
```
sudo dd if=debian-9.8.0-amd64-netinst.iso of=/dev/sdb bs=32MB
```
Note: make sure you are dd ing to the right drive use `sudo fdisk -l` to check which drive is which.


Note: Despite complaining that certain firmware files could not be found, my newtwork card did actually work, so sometimes it's just worth pressing on to see if stuff works.


