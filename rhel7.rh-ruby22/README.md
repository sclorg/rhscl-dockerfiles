Software Collection rh-ruby22 Dockerfile
========================================

How to build this Dockerfile
----------------------------

Building this Dockerfile requires a Red Hat Enterprise Linux 7 host
system with Software Collections entitlements available.

To build the Dockerfile, run:

```
# cd rh-ruby22
# docker build -t=rh-ruby22 .
```

General container help
----------------------

Run `docker run rh-ruby22` to get this help.

Run `docker run -ti rh-ruby22 bash` to obtain interactive shell.

Run `docker exec -ti CONTAINERID bash` to access already running container.

You may try `-e CONT_DEBUG=VAL` with VAL up to 3 to get more verbose debugging
info.


Report bugs to <http://bugzilla.redhat.com>.




