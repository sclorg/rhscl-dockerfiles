Software Collection rh-mysql56 Dockerfile
=========================================


Build
-----

Building this Dockerfile requires a Red Hat Enterprise Linux 7 host
system with Software Collections entitlements available.

To build the Dockerfile run the following command in this directory:

```
docker build .
```


Run
---

Without specifying any commands on the command line, the mysqld daemon is run

```
docker run -d --name mysql_database -p 3306:3306 rh-mysql56
```

It is recommended to use run the container with mounted data directory everytime.
This example shows how to run the container with `/host/data` directory mounted
and so the database will store data into this directory on host:

```
docker run -d --name mysql_database -v /host/data:/var/lib/mysql/data rh-mysql56
```

To pass arguments that are used for initializing the database if it is not yet initialized, define them as environment variables

```
docker run -d --name mysql_database -e MYSQL_USER=user -e MYSQL_PASSWORD=pass -e MYSQL_DATABASE=db -p 3306:3306 rh-mysql56
```

To run Bash in the built Docker image, run

```
docker run -t -i rh-mysql56 /bin/bash
```

To connect to running container, run

```
docker exec -t -i rh-mysql56 bash
```

Environment variables and volumes
----------------------------------

The image recognizes following environment variables that you can set during
initialization, by passing `-e VAR=VALUE` to the Docker run command.

|    Variable name       |    Description                            |
| :--------------------- | ----------------------------------------- |
|  `MYSQL_USER`          | User name for MySQL account to be created |
|  `MYSQL_PASSWORD`      | Password for the user account             |
|  `MYSQL_DATABASE`      | Database name                             |
|  `MYSQL_ROOT_PASSWORD` | Password for the root user (optional)     |


You can also set following mount points by passing `-v /host:/container` flag to docker.

|  Volume mount point      | Description          |
| :----------------------- | -------------------- |
|  `/var/lib/mysql/data`   | MySQL data directory |

