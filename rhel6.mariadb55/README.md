Software Collection mariadb55 Dockerfile
========================================

How to build this Dockerfile
----------------------------

Building this Dockerfile requires a Red Hat Enterprise Linux 7 host
system with Software Collections entitlements available.

To build the Dockerfile, run:

```
# cd mariadb55
# docker build -t=mariadb55 .
```


MariaDB 5.5 Docker Image based on mariadb55 Software Collection
===============================================================

MariaDB 5.5 is a multi-user, multi-threaded SQL database server. It is a
client/server implementation consisting of a server daemon (mysqld)
and many different client programs and libraries. This docker image contains
the MariaDB 5.5 server and some accompanying files and directories.

The Docker image includes packages from Software Collections (SCL).
For more information about Software Collections, see
http://softwarecollections.org.


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


Usage
---------------------------------

To just run the dameon and not store the database in a host directory,
you need to execute the following command:

```
# docker run --name=mariadb55 -d -p 3306:3306 <THIS_IMAGE>
```

If you want to set only environment variables to create a database and not store
the database in a host directory, you need to execute the following command:

```
# docker run -d --name mysql_database -e MYSQL_USER=user -e MYSQL_PASSWORD=pass -e MYSQL_DATABASE=db -p 3306:3306 <THIS_IMAGE>
```

This will create a container named `mysql_database` running MySQL with database
`db` and user with credentials `user:pass`. Port 3306 will be exposed and mapped
to host.

If you want your database to be persistent across container executions,
also add a `-v /host/db/path:/var/lib/mysql/data` argument. This is going to be
the MySQL data directory.

If the database directory is not initialized, the container script will first
run [`mysql_install_db`](https://dev.mysql.com/doc/refman/5.5/en/mysql-install-db.html)
during start and setup necessary database users and passwords. After the database is
initialized, or if it was already present, `mysqld` is executed and will run as PID 1.

You can stop the detached container by running `docker stop mysql_database`.


MySQL root user
---------------
The root user has no password set by default, only allowing local connections.
You can set it by setting `MYSQL_ROOT_PASSWORD` environment variable when initializing
your container. This will allow you to login to the root account remotely. Local
connections will still not require password.



General container help
----------------------

Run `docker run THIS_IMAGE container-usage` to get this help.

Run `docker run -ti THIS_IMAGE bash` to obtain interactive shell.

Run `docker exec -ti CONTAINERID bash` to access already running container.

You may try `-e CONT_DEBUG=VAL` with VAL up to 3 to get more verbose debugging
info.


Report bugs to <http://bugzilla.redhat.com>.




