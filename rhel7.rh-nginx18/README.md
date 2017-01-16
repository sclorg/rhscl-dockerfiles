Nginx 1.8 server and a reverse proxy server docker image
========================================================

The `rhscl/nginx-18-rhel7` image provides an nginx 1.8 server and a reverse proxy server. The image can be used as a base image for other applications based on nginx 1.8 web server.


To pull the `rhscl/nginx-18-rhel7` image, run the following command as root:
```
docker pull rhscl/nginx-18-rhel7
```

S2I build support
-------------
Nginx configuration can be extended using S2I tool.
S2I build folder structure:

|    Folder name         |    Description                            |
| :--------------------- | ----------------------------------------- |
|  ./nginx-cfg/*.conf    | Should contain all nginx configuration we want to include into image |
|  ./src/                | Should contain nginx application source code |

Execution:

        s2i build --context-dir=. rhscl/nginx-18-rhel7 your-image-name


Configuration
-------------
The nginx container image supports the following configuration variable, which can be set by using the `-e` option with the docker run command:


|    Variable name       |    Description                            |
| :--------------------- | ----------------------------------------- |
|  `NGINX_LOG_TO_VOLUME` | By default, nginx logs into standard output, so the logs are accessible by using the docker logs command. When `NGINX_LOG_TO_VOLUME` is set, nginx logs into `/var/log/nginx16`, which can be mounted to host system using the Docker volumes. |
