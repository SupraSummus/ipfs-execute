images/empty:
	tar -c --files-from /dev/null | gzip -n | ipfs add -Q --pin=false > $@
