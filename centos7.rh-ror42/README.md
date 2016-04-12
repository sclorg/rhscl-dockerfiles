Ruby on Rails 4.2 platform image
================================

The centos/ror-42-centos7 container image provides a Ruby on Rails 4.2 platform for building and running applications. It contains Ruby 2.3, Ruby on Rails 4.2, and Node.js 4.2.3 preinstalled.


Usgae
-----
The image is to aimed to be used as base image for various layered application images.

To pull the centos/ror-42-centos7 image, run the following command as root:
```
docker pull centos/ror-42-centos7
```

To create a layered container image that uses this image as base, create a Dockerfile as the following:
```
FROM centos/ror-42-centos7
ADD your-app /opt/app-root/src
CMD ...
```

Configuration
-------------

No further configuration is required; this image contains and enables the rh-ruby23, rh-ror42, and nodejs4 Software Collections. For automatic S2I builds, use the Ruby container available as `centos/ruby-23-centos7`.
