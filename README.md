IPFS execute!
=============

`ipfs-execute` is a simple script that combines sandboxing provided
by [Bubblewrap](https://github.com/projectatomic/bubblewrap) with data
storage provided by [IPFS](https://ipfs.io/). The tool is proof of
concept for "pure computations in IPFS".

`ipfs-execute` fetches description of what to do from IPFS, executes
computation in sandbox and then pushes result back to IPFS.

More in depth description
-------------------------

`ipfs-execute` takes following arguments in order:
 * IPFS path of filesystem snapshot (`.tar.gz` file)
 * IPFS path of argument - it will be mounted at `/input` inside container.
 * arbitrary number of arguments which will be passed to `/sbin/init`

`ipfs-execute` unpacks root fs, mounts input, mounts empty directory
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

* IPFS (daemonized)
* Bubblewrap 2.0
* [ipfs-api-mount](https://github.com/SupraSummus/ipfs-api-mount)
* sh + tar + gzip + some other obvious things
* GNU Make (only if you want to build example images or use install script)
* [ipfs-shell-utlis](https://github.com/SupraSummus/ipfs-shell-utils) (only if you want to build example images)

Try it
------

    [jan@aaa ipfs-execute]$ ipfs-execute $(cat examples/busybox) $(cat examples/alpine_repository) sh
    / # ls /input
    aarch64  armhf    x86_64
    / # echo blabla > /output/test
    / # exit
    QmeugpFaBp7aafV2uN7GC3E2GbAycnEU3c2Q3FS7mSLbo4

What happened? Image located at path specified in `examples/busybox` got
executed with IPFS path specified in `examples/alpine_repository`
mounted at `/input`. When container finished `/output` was pushed to
IPFS. Let's inspect:

    [jan@kukla:~/ipfs-execute]$ ipfs cat QmeugpFaBp7aafV2uN7GC3E2GbAycnEU3c2Q3FS7mSLbo4/test
    blabla

### Next lets install some packages!

For this we need prepared directory with repository and base rootfs.
I'll use `ipfs-mkdir` from [ipfs-shell-utils](https://github.com/SupraSummus/ipfs-shell-utils),
but you can do it different way. `ipfs-mkdir` usage is as follows:

    ipfs-mkdir repository $(cat examples/alpine_repository) rootfs.tar.gz $(cat examples/busybox) > /tmp/busybox-with-repo
    cat /tmp/busybox-with-repo
    # QmVLwnKjWMrxXdRdqwvR5h94uUdT2vqyWCypSWv2TDno98

We are ready to call `ipfs-execute`.

    ipfs-execute $(cat examples/apk) $(cat /tmp/busybox-with-repo) file > /tmp/alpine-file
    ipfs ls $(cat /tmp/alpine-file)
    # QmcNqqRByj6kbw11sbjxXrBASECh2JRg63W6iw3FGezJkU 1280118 rootfs.tar.gz
    ipfs-execute $(cat /tmp/alpine-file)/rootfs.tar.gz $(cat examples/empty) sh

and inside spawned container:

    file /bin/busybox.static
    # /bin/busybox.static: ELF 64-bit LSB shared object, x86-64, version 1 (SYSV), dynamically linked, stripped

### Example images

Hashes and build scripts of example containers are listed in `examples/`.
 * `busybox` - just an unpacked busybox-static alpine package. Init is
   set to call busybox with supplied args.
 * `apk` - alpine linux apk package with init pointing to script that
   installs stuff. This container expects directory with `rootfs.tar.gz`
   and `repository` (dir with alpine repo structure) as argument.

In order to build images you need to have scripts in your path.
`make install PREFIX=~/.local/bin` will copy them to `~/.local/bin`.

Makefile in `examples/` dir is just for building images. Do `make -C examples clean`
to delete prebuilt images and then call `make -C examples`.

TODOs
-----

 * security considerations if mounting `/dev` and `/proc` is safe.
 * RAM, disk, CPU time limits
 * build consistency - don't depend on current time etc
