images/apk: repository arch $(wildcard apk/**/*) images/jointargz images/busybox
	$(eval APK := $(shell ipfs ls -- `cat repository`/`cat arch`/ | grep apk-tools-static | tail -n1 | cut -d " " -f1))
	$(eval INIT := $(shell tar -C apk/rootfs -c --mtime 1970-01-01 . | gzip -cn | ipfs add -Q --pin=false))
	ipfs-execute \
		$$(cat images/jointargz) \
		$$(ipfs-mkdir \
			0rootfs.tar.gz $$(cat images/busybox) \
			1apk.tar.gz ${APK} \
			2init.tar.gz ${INIT} \
		) | awk '{print $$1"/result.tar.gz"}' > $@
