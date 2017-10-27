images/busybox: repository arch $(wildcard busybox/*)
	cd busybox; ./build.sh `cat ../repository` `cat ../arch` > ../$@
