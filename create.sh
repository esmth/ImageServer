#!/bin/bash
# 06/01/16
# This script will create an image server and build an initrd to flash an image using PXE

# Number of cores
NUMCORES=`cat /proc/cpuinfo | grep processor | wc -l`

# Install required packages for host
apt-get update
apt-get install dnsmasq python3 curl

# Config files
BUSYBOXCFG=""
LINUXCFG=""
DNSMASQCFG=""
RAMDISKINIT=""

# Get source for client linux build
BUSYBOXSRC=""
LINUXSRC=""
CURLSRC=""

# Prep build directories
mkdir /tmp/build
cd /tmp/build
(curl $BUSYBOXSRC | tar xfC busybox)
(curl $LINUXSRC | tar xfC linux)
(curl $CURLSRC | tar xfC curl)

# Init ram disk skeleton
mkdir initramdisk
mkdir {bin,sbin,sys,proc,dev,tmp} ##NEED MORE??

# Busybox build
cd busybox
cp $BUSYBOXCFG .config
make -j$NUMCORES
make DESTDIR=../initramdisk install
