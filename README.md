rhscl-dockerfiles
=================

This repository contains a set of Dockerfiles for various Software
Collections.

The Dockerfiles are intended as examples which can be used to build
more complex containers.

To build a Dockerfile, a Red Hat Enterprise Linux host system is
required, with suitable entitlements enabled.  For more information on
using docker on RHEL, see:

- https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/7.0_Release_Notes/sect-Red_Hat_Enterprise_Linux-7.0_Release_Notes-Linux_Containers_with_Docker_Format-Using_Docker.html

To build a container based on the Dockerfiles provided here, clone the
GitHub repository, then run, e.g:

  # docker build rhel6.httpd24

RHEL6 images can be built on RHEL7 host systems.

For more information about Software Collections, see:

- https://www.softwarecollections.org/en/
- https://access.redhat.com/documentation/en-US/Red_Hat_Software_Collections/
