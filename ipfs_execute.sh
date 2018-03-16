#!/bin/sh
set -e

function rm_very_force {
	rm -rf "$1" 2> /dev/null || $(chmod -R u+w "$1" && rm -rf "$1")
}

function cleanup {
	# cleanup
	fusermount -u input || true
	rm_very_force rootfs
	rm_very_force input
	rm_very_force tmp
	rm_very_force output
}

trap cleanup EXIT

# parse args
rootfs="$1"
input="$2"
shift 2

# get and unpack root fs
mkdir rootfs
ipfs cat -- "$rootfs" | tar -xz -C rootfs --warning=no-timestamp

# make required dirs
mkdir input
mkdir tmp
mkdir output

# mount input
ipfs-api-mount --background $(ipfs resolve -r -- "$input") input

# run task in bubblewrap
set +e
env -i `which bwrap` \
	--unshare-all \
	--as-pid-1 \
	--uid 0 \
	--gid 0 \
	--die-with-parent \
	--hostname sandbox \
	--bind rootfs / \
	--ro-bind input /input \
	--bind output /output \
	--bind tmp /tmp \
	--proc /proc \
	--dev /dev \
	--remount-ro / \
	/sbin/init $@ 1>&2
set -e

# push result to ipfs
ipfs add -r -Q --pin=false -- output
