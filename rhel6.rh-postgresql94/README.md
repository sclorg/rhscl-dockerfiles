Software Collection rh-postgresql94 Dockerfile
==============================================

How to build this Dockerfile
----------------------------

Building this Dockerfile requires a Red Hat Enterprise Linux 7 host
system with Software Collections entitlements available.

To build the Dockerfile, run:

```
# cd rh-postgresql94
# docker build -t=rh-postgresql94 .
```

General container help
----------------------

Run `docker run rh-postgresql94` to get this help.

Run `docker run -ti rh-postgresql94 bash` to obtain interactive shell.

Run `docker exec -ti CONTAINERID bash` to access already running container.

You may try `-e CONT_DEBUG=VAL` with VAL up to 3 to get more verbose debugging
info.


Report bugs to <http://bugzilla.redhat.com>.




