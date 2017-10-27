#!/bin/sh
set -e
D=$(mktemp -d)
V=$(ipfs ls -- $1/$2/ | grep busybox-static | tail -n1 | cut -d " " -f1)
ipfs cat -- $V | tar -xz -C $D
mkdir $D/sbin
cp init $D/sbin/init
P=$(tar -c --mtime 1970-01-01 -C $D . | gzip -cn | ipfs add -Q --pin=false)
rm -rf $D
ipfs_execute.sh $P $(ipfs_mkdir.sh rootfs.tar.gz $P) | \
	awk '{print $1"/rootfs.tar.gz"}'
