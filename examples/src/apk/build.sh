#!/bin/sh
set -e -x

# extract rootfs
tar -xz -C /tmp -f /input/rootfs.tar.gz

# obtain apk tools version
APK=$(ls /input/repository/$1/ | grep apk-tools-static)

# extract apk tools
tar -xz -C /tmp -f /input/repository/$1/$APK

# copy init
cp /input/src/init /tmp/sbin/init
chmod +x /tmp/sbin/init

# compress rootfs
tar -c -C /tmp . | gzip -nc > /output/rootfs.tar.gz
