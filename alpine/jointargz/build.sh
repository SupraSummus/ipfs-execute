tar -xzmf /input/rootfs.tar.gz -C /tmp

cp /input/init /tmp/sbin/init
chmod +x /tmp/sbin/init

tar -cm -C /tmp . | gzip -cn > /output/rootfs.tar.gz
