all: \
	images/empty \
	images/busybox \
	images/jointargz \
	images/apk

clean:
	rm images/*

include $(shell find . -maxdepth 2 -name '*.mk')
