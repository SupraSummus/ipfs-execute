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
at `/output`. After that container is executed. Entry point is `/sbin/init`.

When container finishes whole `/output` is added to IPFS. Final hash is
written to stdout.

Dependencies
------------

* IPFS (deamonized and mounted on `/ipfs`)
* Bubblewrap 1.8
* sh + tar + gzip + some other obvious things

Try it
------

    [jan@kukla:~/ipfs-execute]$ ./ipfs_execute.sh `cat images/alpine-sh` `cat repository`
    kukla:/# ls /input/
    v3.6
    kukla:/# ls /input/v3.6/community/x86_64/librd*
    /input/v3.6/community/x86_64/librdkafka-0.9.5-r0.apk      /input/v3.6/community/x86_64/librdkafka-dev-0.9.5-r0.apk

What happened? Image located at path specified in `images/alpine-sh` got
executed with IPFS path specified in `repository` mounted at `/input`.

### Next lets install some packages!

For this we need prepared directory with repository and base rootfs.
Lets use `ipfs files` subcommand.

    ipfs files mkdir /test
    ipfs files cp /ipfs/`cat repository`/v3.6/main /test/repo
    ipfs files cp /ipfs/`cat images/alpine-sh` /test/rootfs.tar.gz

Hash of prepared input can be obtained with `ipfs files stat --hash /test`.
Sample output is `QmPEe5AFNacXem1TuQCYsJeCEk4erb5Z3nuRCEn3ibtvQA`.
We are ready to call `ipfs_execute.sh`.

    ./ipfs_execute.sh `cat images/apk` `ipfs files stat --hash /test` gcc > alpine-gcc
    ifps ls `cat alpine-gcc`
    # QmeQX49G8qsxpcsYDuXoz5PnHnhnkrQRKth8ww7VG2ZpZV 33236061 rootfs.tar.gz
    ./ipfs_execute.sh `cat alpine-gcc`/rootfs.tar.gz `cat empty`

and inside spawned container:

    gcc --version
    # gcc (Alpine 6.3.0) 6.3.0
    # ...


### Base/example images

Hashes of example containers are listed in `images/`.
 * `alpine` is unmodified alpine linux. It doesn't start yet because of
   init expecting to be called as PID 1. To be fixed.
 * `alpine-sh` - modified version of alpine linux. Init is replaced with sh.
 * `apk` - alpine linux with init pointing to script that installs
   stuff. This container expects directory with `rootfs.tar.gz` and
   `repo` (dir with alpine repo structure) as argument.

In `repository` there is a hash of alpine repository mirror.
In `empty` there is a hash of empty dir.

Makefile is just for building images. Do `make clean` to delete prebuilt
images and then call `make`.

TODOs
-----

 * add `--aspid1` to bubblewrap call.
 * security considerations if mounting `/dev` and `/proc` is safe.
 * RAM, disk, CPU time limits
