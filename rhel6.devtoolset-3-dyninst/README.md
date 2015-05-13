Software Collection devtoolset-3-dyninst Dockerfile
===================================================

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

Run `docker run devtoolset-3-dyninst` to get this help.

Run `docker run -ti devtoolset-3-dyninst bash` to obtain interactive shell.

Run `docker exec -ti CONTAINERID bash` to access already running container.

You may try `-e CONT_DEBUG=VAL` with VAL up to 3 to get more verbose debugging
info.


Report bugs to <http://bugzilla.redhat.com>.




