all: busybox apk

clean:
	rm -rf busybox apk

busybox: $(wildcard src/busybox/*) alpine_repository alpine_arch
	./src/busybox/build.sh `cat alpine_repository` `cat alpine_arch` > $@

apk: $(wildcard src/apk/*) alpine_repository alpine_arch busybox
	ipfs-execute \
		$$(cat busybox) \
		$$(ipfs-mkdir \
			rootfs.tar.gz $$(cat busybox) \
			repository $$(cat alpine_repository) \
			src $$(ipfs add -r -Q --pin=false src/apk) \
		) sh /input/src/build.sh $$(cat alpine_arch) | \
		awk '{print $$1"/rootfs.tar.gz"}' > $@
