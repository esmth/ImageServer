# ImageServer
This will eventually contain scripts to create and maintain an image server to 'image' computers using PXE.

#./buildinitrd.sh
This will build and download curl, linux, and busybox and create a bootable linux kernel image and an init ram disk that will boot the client (to be cloned) PCs.

#./startserver.sh
This script starts dnsmasq with the included config file. A tftp and dhcp server is created for a PXE boot environment.


