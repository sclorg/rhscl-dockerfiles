Software Collection mongodb24 Dockerfile
========================================

How to build this Dockerfile
----------------------------

Building this Dockerfile requires a Red Hat Enterprise Linux 7 host
system with Software Collections entitlements available.

To build the Dockerfile, run:

```
# cd mongodb24
# docker build -t=mongodb24 .
```

General container help
----------------------

Run `docker run mongodb24 container-usage` to get this help.

Run `docker run -ti mongodb24 bash` to obtain interactive shell.

Run `docker exec -ti CONTAINERID bash` to access already running container.

You may try `-e CONT_DEBUG=VAL` with VAL up to 3 to get more verbose debugging
info.


Report bugs to <http://bugzilla.redhat.com>.




