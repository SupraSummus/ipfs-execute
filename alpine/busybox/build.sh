#!/bin/sh
set -e -x

# make tempdir
function cleanup {
	# cleanup
	rm -rf $D
}
trap cleanup EXIT
D=$(mktemp -d)

# obtain latest version of busybox-static
V=$(ipfs ls -- $1/$2/ | grep busybox-static | tail -n1 | cut -d " " -f1)

# extract and add custom init file
ipfs cat -- $V | tar -xz -C $D
mkdir $D/sbin
cp init $D/sbin/init

# remove timestamps - to ensure build result independent of time
touch -d 1970-01-01 $D/sbin/init
touch -d 1970-01-01 $D/sbin
touch -d 1970-01-01 $D

# copress and add to ipfs
# gzip should not add time and name metadata: thus flag -n
P=$(tar -c -C $D . | gzip -cn | ipfs add -Q --pin=false)

# run building container
ipfs-execute $P $(ipfs-mkdir rootfs.tar.gz $P) | \
	awk '{print $1"/rootfs.tar.gz"}'
