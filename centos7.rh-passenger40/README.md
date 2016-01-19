Phusion Passenger® 4.0 web server and application server
========================================================

The `centos/passenger-40-centos7` image provides a Phusion Passenger 4.0 application server configured with Apache httpd web server. It also provides a Ruby 2.2 platform for building and running applications. Node.js 0.10 is preinstalled for assets compilation.

To pull the `centos/passenger-40-centos7` image, run the following command as root:
```
docker pull centos/passenger-40-centos7
```

Configuration
-------------
No further configuration is required; this image contains and enables the `rh-ruby22`, `rh-ror41`, `nodejs010`, `rh-passenger40`, and `httpd24` Software Collections. It is especially designed to support automatic S2I builds.


Usage
---------------------
To build a simple [puma-sample-app](https://github.com/sclorg/rhscl-dockerfiles/tree/master/centos7.rh-passenger40/test/puma-test-app) application
using standalone [S2I](https://github.com/openshift/source-to-image) and then run the
resulting image with [Docker](http://docker.io) execute:

```
$ s2i build https://github.com/sclorg/rhscl-dockerfiles.git --context-dir=centos7.rh-passenger40/test/puma-test-app/ centos/passenger-40-centos7 puma-sample-app
$ docker run -p 8080:8080 puma-sample-app
```

**Accessing the application:**
```
$ curl 127.0.0.1:8080
```

