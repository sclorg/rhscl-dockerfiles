[outdated] rhscl-dockerfiles
============================

:exclamation: **Outdated Notice**

This repository contains just very simple and often outdated
and unmaintained Dockerfiles for various Software
Collections, which were developed as first containers based on Software
Collections.

The Dockerfiles were intended as examples which can be used to build
more complex containers.

However, over the time some more mature containers were developed and are now maintained in separate repositories under https://github.com/sclorg. Please, find particular repository there instead. For listing all containers under that organization, see https://github.com/sclorg?q=-container.

For those who decided to build a Dockerfile anyway, a Red Hat Enterprise Linux host system is
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
