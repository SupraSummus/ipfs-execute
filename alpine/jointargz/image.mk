images/jointargz: $(wildcard jointargz/*) images/busybox
	ipfs-execute \
		$$(cat images/busybox) \
		$$(ipfs-mkdir \
			build.sh $$(ipfs add --pin=false -Q -- jointargz/build.sh) \
			rootfs.tar.gz $$(cat images/busybox) \
			init $$(ipfs add --pin=false -Q -- jointargz/init) \
		) \
		sh /input/build.sh | awk '{print $$1"/rootfs.tar.gz"}' > $@
