#!/bin/bash
# 06/01/16
# this script downloads and picks important bits from syslinux 5.10

SYSLINUXSRC="https://www.kernel.org/pub/linux/utils/boot/syslinux/syslinux-5.10.tar.xz"

cd build
curl "$SYSLINUXSRC" | tar xJf - && mv syslinux* syslinux
cd syslinux
cp core/pxelinux.0 ../pxelinux.0
cp com32/menu/vesamenu.c32 ../vesamenu.c32

