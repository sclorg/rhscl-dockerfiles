Apache HTTP 2.4 Server
======================

The `centos/httpd-24-centos7` image provides an Apache HTTP 2.4 Server. The image can be used as a base image for other applications based on Apache HTTP web server.

To pull the `centos/httpd-24-centos7` image, run the following command as root:
```
docker pull centos/httpd-24-centos7
```

Configuration
-------------

The Apache HTTP Server container image supports the following configuration variable, which can be set by using the `-e` option with the docker run command:

|    Variable name        |    Description                            |
| :---------------------- | ----------------------------------------- |
|  `HTTPD_LOG_TO_VOLUME1` | By default, httpd logs into standard output, so the logs are accessible by using the docker logs command. When `HTTPD_LOG_TO_VOLUME` is set, httpd logs into `/var/log/httpd24`, which can be mounted to host system using the Docker volumes. |
