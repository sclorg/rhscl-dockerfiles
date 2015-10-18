Ruby on Rails 4.1 platform image
================================

The rhscl/ror-41-rhel7 container image provides a Ruby on Rails 4.1 platform for building and running applications. It contains Ruby 2.2, Ruby on Rails 4.1, and Node.js 0.10 preinstalled.


Usgae
-----
The image is to aimed to be used as base image for various layered application images.

To pull the rhscl/ror-41-rhel7 image, run the following command as root:
```
docker pull registry.access.redhat.com/rhscl/ror-41-rhel7
```

To create a layered container image that uses this image as base, create a Dockerfile as the following:
```
FROM registry.access.redhat.com/rhscl/ror-41-rhel7
ADD your-app /opt/app-root/src
CMD ...
```

Configuration
-------------

No further configuration is required; this image contains and enables the rh-ruby22, rh-ror41, and nodejs010 Software Collections. For automatic S2I builds, use the Ruby container available as `rhscl/ruby-22-rhel7`.
