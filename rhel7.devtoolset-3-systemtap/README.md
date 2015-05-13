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

General container help
----------------------

Run `docker run  --privileged devtoolset-3-systemtap` to get this help.

Run `docker run -ti  --privileged devtoolset-3-systemtap bash` to obtain interactive shell.

Run `docker exec -ti  --privileged CONTAINERID bash` to access already running container.

You may try `-e CONT_DEBUG=VAL` with VAL up to 3 to get more verbose debugging
info.


Report bugs to <http://bugzilla.redhat.com>.




