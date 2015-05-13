Software Collection devtoolset-3-systemtap Dockerfile
=====================================================

How to build this Dockerfile
----------------------------

Building this Dockerfile requires a Red Hat Enterprise Linux 7 host
system with Software Collections entitlements available.

To build the Dockerfile, run:

```
# cd devtoolset-3
# docker build -t=devtoolset-3 .
```


devtoolset-3-systemtap Docker Image based on devtoolset-3 Software Collection
=============================================================================

SystemTap is an instrumentation system for systems running Linux.
Developers can write instrumentation scripts to collect data on
the operation of the system.  The base systemtap package contains/requires
the components needed to locally develop and execute systemtap scripts.


Usage
-----

This container is expected to be run as privileged container:

```
docker run --privileged devtoolset-3-systemtap
```



General container help
----------------------

Run `docker run THIS_IMAGE container-usage` to get this help.

Run `docker run -ti THIS_IMAGE bash` to obtain interactive shell.

Run `docker exec -ti CONTAINERID bash` to access already running container.

You may try `-e CONT_DEBUG=VAL` with VAL up to 3 to get more verbose debugging
info.


Report bugs to <http://bugzilla.redhat.com>.




