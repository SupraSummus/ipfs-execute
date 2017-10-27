#!/bin/sh
set -e

function cleanup {
	# cleanup
	rm -rf rootfs output
}
trap cleanup EXIT

# parse args
rootfs="$1"
input="$2"
shift 2

# get and unpack root fs
mkdir rootfs
ipfs cat -- "$rootfs" | tar -xz -C rootfs --warning=no-timestamp

# make output dir
mkdir output

# run task in bubblewrap
env -i `which bwrap` \
	--unshare-all \
	--uid 0 \
	--gid 0 \
	--bind rootfs / \
	--ro-bind "`ipfs resolve -- $input`" /input \
	--bind output /output \
	--tmpfs /tmp \
	--proc /proc \
	--dev /dev \
	--remount-ro / \
	/sbin/init $@ 1>&2

# push result to ipfs
ipfs add -r -Q --pin=false -- output
