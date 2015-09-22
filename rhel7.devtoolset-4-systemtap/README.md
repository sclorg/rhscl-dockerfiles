Software Collection devtoolset-4-systemtap Dockerfile
=====================================================

How to build this Dockerfile
----------------------------

Building this Dockerfile requires a Red Hat Enterprise Linux 7 host
system with Software Collections entitlements available.

To build the Dockerfile, run:

```
# cd devtoolset-4
# docker build -t=devtoolset-4 .
```


devtoolset-4-systemtap Docker Image based on devtoolset-4 Software Collection
=============================================================================

SystemTap is an instrumentation system for systems running Linux.
Developers can write instrumentation scripts to collect data on
the operation of the system.  The base systemtap package contains/requires
the components needed to locally develop and execute systemtap scripts.


Usage
-----

This container is expected to be run as privileged container:

```
docker run --privileged devtoolset-4-systemtap
```



General container help
----------------------

Run `docker run THIS_IMAGE container-usage` to get this help.

Run `docker run -ti THIS_IMAGE bash` to obtain interactive shell.

Run `docker exec -ti CONTAINERID container-entrypoint` to access already running container.

In order to get the container ID after running the image, pass `--cidfile=`
option to the `docker run` command. That will instruct Docker to write
a file with the container ID.

You may try `-e CONT_DEBUG=VAL` with VAL up to 3 to get more verbose debugging
info.


Report bugs to <http://bugzilla.redhat.com>.




