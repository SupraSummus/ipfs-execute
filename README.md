IPFS execute!
=============

`ipfs_execute.sh` is a simple script that combines sandboxing provided
by [Bubblewrap](https://github.com/projectatomic/bubblewrap) with data
storage provided by [IPFS](https://ipfs.io/). The tool is proof of
concept for "pure computations in IPFS".

`ipfs_execute.sh` fetches description of what to do from IPFS, executes
computation in sandbox and then pushes result back to IPFS.

More in depth description
-------------------------

`ipfs_execute.sh` takes following arguments in order:
 * IPFS path of filesystem snapshot (`.tar.gz` file)
 * IPFS path of argument - it will be mounted at `/input` inside container.
 * arbitrary number of arguments which will be passed to `/sbin/init`

`ipfs_execute.sh` unpacks root fs, mounts input, mounts empty directory
at `/output` and another one at `/tmp`. After that container is executed.
Entry point is `/sbin/init`.

When container finishes whole `/output` is added to IPFS. Final hash is
written to stdout.

`/` and `/input` is mounted read-only. All persistent efects must be
located in `/output` tree. This potentially allows to reuse unpacked
rootfs or input.

Containers don't have access to internet. Output should be
deterministicaly computed from rootfs and input.

Dependencies
------------

* IPFS (daemonized and mounted on `/ipfs`)
* Bubblewrap 1.8
* GNU Make (only if you want to build example images or use install script)
* sh + tar + gzip + some other obvious things

Try it
------

    [jan@kukla:~/ipfs-execute]$ ./ipfs_execute.sh `cat alpine/images/busybox` `cat alpine/repository` sh
    kukla:/# ls /input/
    x86_64
    / # echo blabla > /output/test
    / # exit
    QmeugpFaBp7aafV2uN7GC3E2GbAycnEU3c2Q3FS7mSLbo4

What happened? Image located at path specified in `images/alpine-sh` got
executed with IPFS path specified in `repository` mounted at `/input`.
When container finished `/output` was pushed to IPFS. Let's inspect:

    [jan@kukla:~/ipfs-execute]$ ipfs cat QmeugpFaBp7aafV2uN7GC3E2GbAycnEU3c2Q3FS7mSLbo4/test
    blabla

### Next lets install some packages!

For this we need prepared directory with repository and base rootfs.
Simple tool for that is `ipfs_mkdir.sh`. Usage is as follows:

    ./ipfs_mkdir.sh repository `cat alpine/repository` rootfs.tar.gz `cat alpine/images/busybox` > /tmp/busybox-with-repo
    cat /tmp/busybox-with-repo
    # QmYHTCYxkC12CH39BxHebvFFEfgKaECcxQ78NE7mYk7Prn

We are ready to call `ipfs_execute.sh`.

    ./ipfs_execute.sh `cat alpine/images/apk` `cat /tmp/busybox-with-repo` file > /tmp/alpine-file
    ipfs ls `cat /tmp/alpine-file`
    # QmR4uzVfobf8zEeivQypCgKaDuGAZknvTViwtZbEcSanyr 1280141 rootfs.tar.gz
    ./ipfs_execute.sh `cat /tmp/alpine-file`/rootfs.tar.gz `cat empty` sh

and inside spawned container:

    file /bin/busybox.static
    # /bin/busybox.static: ELF 64-bit LSB shared object, x86-64, version 1 (SYSV), dynamically linked, stripped


### Base/example images

Hashes of example containers are listed in `alpine/images/`.
 * `busybox` - just an unpacke busybox-static alpine package. Init is
   set to call busybox with supplied args.
 * `jointargz` - unpacks all `.tar.gz` files from input into single
   directory and then packs everything.
 * `apk` - alpine linux apk package with init pointing to script that
   installs stuff. This container expects directory with `rootfs.tar.gz`
   and `repository` (dir with alpine repo structure) as argument.

In `repository` there is a hash of alpine repository mirror.

In order to build images you need to have scripts in your path. Scripts
have to be named differently: `ipfs-execute` and `ipfs-mkdir`.
`make install PREFIX=~/.local/bin` will copy them to `~/.local/bin`.

Makefile in `alpine/` dir is just for building images. Do `make -C alpine clean`
to delete prebuilt images and then call `make -C alpine`.

TODOs
-----

 * add `--aspid1` to bubblewrap call.
 * security considerations if mounting `/dev` and `/proc` is safe.
 * RAM, disk, CPU time limits
 * build consistency - don't depend on current time etc
 * reading from FUSE-mounted `/ipfs` is very slow. This is known [issue](https://github.com/ipfs/go-ipfs/issues/2166).
