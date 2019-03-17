# debian-setup-steps

Debian Stretch

It seems that debian when used with lightdm does not execute ~/.xinitrc

Instead the flow is that lightdm loads a desktop file from /usr/share/xsessions desktop files can execute only a single command using the Exec entry, if you wan't to initialise something (or execute more than one program) at this point you need to write a script and call it from the Exec entry.

Light dm has a desktop file as well with the Exec entry specifying default hich actually means that light dm will look in ~/.dmrc to find out what session to load by defalut.

If you want to initialise something that is going to be shared by all window managers you can edit/etc/lightdm/lightdm.conf and set display-setup-script or greeter-setup-script to perform general setup.
