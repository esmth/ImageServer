#!/bin/bash
# 06/01/16
# This script will create an image server and build an initrd to flash an image using PXE

# Number of cores
NUMCORES=`cat /proc/cpuinfo | grep processor | wc -l`

# Root of this repository
SROOT=$PWD

# Config files
BUSYBOXCFG="configs/busybox.config"
LINUXCFG="configs/linux.config"
DNSMASQCFG="configs/dnsmasq.conf"
RAMDISKINIT="configs/init"

# Source files
BUSYBOXSRC="https://busybox.net/downloads/busybox-1.24.2.tar.bz2"
LINUXSRC="https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.6.tar.xz"
CURLSRC="https://curl.haxx.se/download/curl-7.49.1.tar.bz2"

# Install required packages for host
installhostpackages(){
	apt-get update
	apt-get install dnsmasq python3 curl
}

# Clean build directory
cleanbuilddirectory(){
	cd $SROOT
	rm -rf build
}

# Prep build directories
prepbuilddirectory(){
	cd $SROOT
	mkdir build
}

# Download and unarchive source
downloadsrc(){
	cd $SROOT
	cd build
	echo '>> Downloading busybox source'
	( curl -# "$BUSYBOXSRC" | tar xjf - && mv busybox* busybox )
	echo '>> Downloading linux source'
	( curl -# "$LINUXSRC"   | tar xJf - && mv linux* linux )
	echo '>> Downloading curl source'
	( curl -# "$CURLSRC"    | tar xjf - && mv curl* curl )
	cd $SROOT
}

# Copy pre downloaded source
copypredownload(){
	cd $SROOT/build
	nice -n 19 tar xf /tmp/busybox-1.24.2.tar.bz2 && mv busybox* busybox
	nice -n 19 tar xf /tmp/linux-4.6.tar.xz && mv linux* linux
	nice -n 19 tar xf /tmp/curl-7.49.1.tar.bz2 && mv curl* curl
	cd $SROOT
}

# Init ram disk skeleton
initramdiskskeleton(){
	mkdir $SROOT/build/initramdisk
	cd build/initramdisk
	mkdir -p {bin,sbin,etc,sys,proc,dev}
	touch etc/mdev.conf
	cd $SROOT
}

# Busybox build
busyboxbuild(){
	cd $SROOT/build/busybox
	make clean
	cp ../../$BUSYBOXCFG .config
	nice -n 19 make -j$NUMCORES
	cp busybox $SROOT/build/initramdisk/bin/busybox
	ln -s busybox $SROOT/build/initramdisk/bin/sh
	cd $SROOT
}

# Linux build
linuxbuild(){
	cd $SROOT/build/linux
	make clean
	cp ../../$LINUXCFG .config
	nice -n 19 make -j$NUMCORES
	cp arch/x86_64/boot/bzImage $SROOT/build/vmlinuz
	cd $SROOT
}

# cURL build
curlbuild(){
	cd $SROOT/build/curl
	make clean
	./configure --without-libssh2 --disable-shared CFLAGS='-static -static-libgcc -Wl,-static -lc'
	nice -n 19 make -j$NUMCORES
	cp src/curl $SROOT/build/initramdisk/bin/curl
	cd $SROOT
}

# Move init file to initramdisk
moveinit(){
	cp $RAMDISKINIT $SROOT/build/initramdisk/init
	chmod +x $SROOT/build/initramdisk/init
}

# Create initrd image
createinitrd(){
	cd $SROOT/build/initramdisk
	find . | cpio -H newc -o > ../initrd.cpio
	cd ..
	echo '>> Compressing ramdisk'
	nice -n 19 gzip -v -9 < initrd.cpio > initrd.img
	cd $SROOT
}

#installhostpackages
cleanbuilddirectory
prepbuilddirectory
downloadsrc
#copypredownload
initramdiskskeleton
busyboxbuild
linuxbuild
curlbuild
moveinit
createinitrd
