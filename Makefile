all: images/alpine images/apk images/alpine-sh

clean:
	rm images/*

images/alpine:
	$(eval D := $(shell mktemp -d))
	cd $D; wget http://dl-cdn.alpinelinux.org/alpine/v3.6/releases/x86_64/alpine-minirootfs-3.6.2-x86_64.tar.gz
	cd $D; echo "df4bf81fdafdc72b32ad455c23901935fdfe5815993612ba7a2df4bae79d97ca  alpine-minirootfs-3.6.2-x86_64.tar.gz" | \
		sha256sum -c
	mkdir $D/rootfs
	tar -xz --exclude=./dev/* -f $D/alpine-minirootfs-3.6.2-x86_64.tar.gz -C $D/rootfs
	tar -C $D/rootfs -cz . | ipfs add -Q --pin=false > $@
	rm -rf $D

images/apk: images/alpine
	$(eval D := $(shell mktemp -d))
	ipfs cat `cat images/alpine` | tar -xz -C $D
	cp -r --remove-destination src/apk/* $D
	tar -C $D -cz . | ipfs add -Q --pin=false > $@
	rm -rf $D

images/alpine-sh: images/alpine
	$(eval D := $(shell mktemp -d))
	ipfs cat `cat images/alpine` | tar -xz -C $D
	cp -r --remove-destination src/alpine-sh/* $D
	tar -C $D -cz . | ipfs add -Q --pin=false > $@
	rm -rf $D
