RHSCL docker images charter
===========================

This document should serve as agreement what users may expect from docker images based on RHSCL packages.

**This is currently a proposal to be discussed primarily between RHSCL maintainers and OpenShift, one of the main customers of RHSCL docker images.**


Common requirements for all RHSCL docker images
-----------------------------------------------
The following information is valid for all RHSCL dockerfiles.

### Base images

What will be used in the docker images as the base image:

* `FROM rhel7` is used for RHEL-7 based images
* `FROM centos:centos7` is used for centos-7 based images
* `FROM rhel6` is used for RHEL-6 based images
* `FROM centos:centos6` is used for centos-6 based images

There is a special image called [sti-base](https://github.com/openshift/sti-base) that is used as base image for all RHSCL images that support [source-to-image](https://github.com/openshift/source-to-image/) building strategy.

For such images the `FROM` tag looks like this:

* `FROM openshift/base-rhel7` is used for RHEL-7 based images
* `FROM openshift/base-centos7` is used for centos-7 based images

### Repositories enabled in the image

For installing necessary packages, the following repositories are enabled for RHEL-based images:
````
RUN yum install -y yum-utils && \
    yum-config-manager --enable rhel-server-rhscl-7-rpms && \
    yum-config-manager --enable rhel-7-server-optional-rpms
````

These repos will be enabled for CentOS images:
```
RUN rpmkeys --import file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
    (+ copr repository RPM packages for all necessary Software Collections that are installed)
```


### Labels and temporary environment variables:

For Kubernetes purposes, the images define the following labels:
```
LABEL io.k8s.description="PostgreSQL is an advanced Object-Relational database management system" \
      io.k8s.display-name="PostgreSQL 9.4"
```
Format of these labels is not specified and author of the Dockerfile should use reasonable strings to describe the image.

For OpenShift purposes, the images define the following labels:
```
LABEL io.openshift.expose-services="5432:postgresql" \
      io.openshift.tags="database,postgresql,postgresql94,rh-postgresql94"
```
These values are comma-separated tags that serve mainly for searching purposes.


### Enabling the collection:

When using Software Collection packages inside the container, we want to have the collectoin enabled everytime we enter the container. This task is more complicated than it seems from the first look, because collection is enabled by tool `scl` that dynamically changes environment variables, so those variables cannot be changed statically using `ENV` tag in the Dockerfile.

The bellow is an example how this issue is addressed with defining a simple `ENTRYPOINT` and couple of special environment variables. The example shows enabling the `mysql55` Software Collection.

First we need to have a shell script that will be sourced to change the environment. This script will include the `scl` call like this (scl_enable.sh):
```
source scl_source enable mysql55
```
This file is installed into some reasonable path in the dockerfile:
```
ADD scl_source.sh /usr/share/conteiner-layer/environment/scl_source.sh
```

Then we need to define a very simple `ENTRYPOINT` like this:
```
#!/bin/bash
set -eu
cmd="$1"; shift
exec $cmd "$@"
```
and install it in the image as `/usr/bin/container-entrypoint`:
```
ADD bin/container-entrypoint /usr/bin/container-entrypoint
ENTRYPOINT ["container-entrypoint"]
```

When running the docker image with just 'bash' as command non-interactively, bash reads content of the environment variable `BASH_ENV` and executes its content. When running interactively, the Bash executes the file specified in environment variable `ENV`. Some other corner cases are not covered by either of the use cases, so there is a small trick used -- environment variable `PROMPT_COMMAND` is set but script included in this variable only executes `scl_enable.sh` and doesn't change the prompt itself. 

So, in order to enable software collection in the image everytime, set the following environment variables must be set in the Dockerfile:
```
ENV BASH_ENV=/usr/share/conteiner-layer/environment/scl_source.sh \
    ENV=/usr/share/conteiner-layer/environment/scl_source.sh \
    PROMPT_COMMAND=". /usr/share/conteiner-layer/environment/scl_source.sh"
```

In order to not repeat environment assignement everytime the prompt is printed, we need to unset the variables in the `scl_enable.sh` script, so the complete content of this script is:
```
unset BASH_ENV PROMPT_COMMAND ENV
source scl_source enable mysql55
```

In order to check whether the software collection is enabled, you can use `scl_enabled` tool, that prints `0` if the software collection given as argument is enabled:
```
docker run -ti mysql55 bash
docker> scl_enabled mysql55
docker> echo $?
0
```

The only use case where we're still not able to enable software collection is when somebody runs a non-shell binary using `docker exec` like this:
```
docker run -d --name myapp mysql55
docker exec -ti myapp python
>>> import os
>>> print os.environ['PATH']
/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin
```
The example above shows that `PATH` variable is not adjusted, which means the software collection is not enabled. The reason is that the entrypoint is not run in this case. The solution is to enable the software collection by running before `python` binary:
```
docker run -d --name myapp mysql55
docker exec -ti myapp sh -ic python
>>> import os
>>> print os.environ['PATH']
/opt/rh/rh-mysql56/root/usr/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
```


Common requirements for all S2I images
-----------------------------------------------------------

The following are requirements for S2I images, which are usually language stacks containers (php, python, ruby, nodejs, perl).

### Devel packages that should be installed:

In order to be able to build some modules from upstream repository, some devel packages are usually necessary. The following list may be the same for all language stack dockerfiles.

```bash
RUN yum install -y --setopt=tsflags=nodocs \
    autoconf \
    automake \
    bsdtar \
    epel-release \
    findutils \
    gcc-c++ \
    gdb \
    gettext \
    git \
    libcurl-devel \
    libxml2-devel \
    libxslt-devel \
    lsof \
    make \
    mariadb-devel \
    mariadb-libs \
    openssl-devel \
    patch \
    postgresql-devel \
    procps-ng \
    scl-utils \
    sqlite-devel \
    tar \
    unzip \
    wget \
    which \
    yum-utils \
    zlib-devel && \
    yum clean all -y
```

### default user and its home directory

The application shouldn't run as root, so we need to create a user for containers that don't provide a specific user yet. (some packages like deamons do provide those users already, so those should be used)

```
ENV HOME /opt/app-root/src
# Setup the 'default' user that is used for the build execution and for the
# application runtime execution by default.
RUN mkdir -p ${HOME} && \
    useradd -u 1001 -r -g 0 -d ${HOME} -s /sbin/nologin \
            -c "Default Application User" default && \
    chown -R 1001:0 /opt/app-root
```

### Defualt path

Users want to run applications in the home directory directly, so we need to have the working directory be in `PATH` variable:
```
ENV PATH=/opt/app-root/src/bin:/opt/app-root/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
```

### Exposing ports

If there is a port that is usually used for development or production, this port should be exposed in the Dockerfile. Common port that users usually use should be used in Dockerfile.

### php dockerfile:
* extra packages: `rh-php56` `rh-php56-php` `rh-php56-php-mysqlnd` `rh-php56-php-pgsql` `rh-php56-php-bcmath` `rh-php56-php-gd` `rh-php56-php-intl` `rh-php56-php-ldap` `rh-php56-php-mbstring` `rh-php56-php-pdo` `rh-php56-php-pecl-memcache` `rh-php56-php-process` `rh-php56-php-soap` `rh-php56-php-opcache` `rh-php56-php-xml` `rh-php56-php-pecl-xdebug`
* `EXPOSE` 8080


### python dockerfile:
* extra packages: `rh-python34` `rh-python34-python-devel` `rh-python34-python-setuptools` `rh-python34-python-pip` `nss_wrapper`
* `EXPOSE` 8080


### ruby dockerfile:
* collections: `rh-ruby22` `nodejs010`
* extra packages: `rh-ruby22` `rh-ruby22-ruby-devel` `rh-ruby22-rubygem-rake` `v8314` `rh-ruby22-rubygem-bundler` `nodejs010`
* `EXPOSE` 8080


### rails dockerfile:
* collections: `rh-ror41` `rh-ruby22` `nodejs010`
* extra packages: `rh-ruby22` `rh-ruby22-ruby-devel` `rh-ruby22-rubygem-rake` `v8314` `rh-ruby22-rubygem-bundler` `rh-ror41 nodejs010`
* `EXPOSE` 8080


### nodejs dockerfile:
* `EXPOSE` 8080


### perl dockerfile:
* `EXPOSE` 8080
* extra packages: `rh-perl520-devel` `perl516-mod_perl` `perl516-perl-CPANPLUS` `tar`


### passenger dockerfile:
* `EXPOSE` 8080
* install `rh-ruby22` `rh-ruby22-ruby-devel` `rh-ruby22-rubygem-rake` `v8314` `rh-ruby22-rubygem-bundler` `rh-ror41-rubygem-rack` `nodejs010` `rh-passenger40-mod_passenger` `rh-passenger40-ruby22` `httpd24`
* When `HTTPD_LOG_TO_VOLUME` environment variable is set, httpd logs into `/var/log/httpd24`

Common requirements for daemons
-------------------------------
After running the container without any command, the daemon is run using exec (no other process is forking to run the daemon) -- this is necessary to pass signals properly.

Daemon is listening on 0.0.0.0 by default.

Data directory (if any) that is expected to be mounted shouldn't be home directory of user, since there may be more stuff that we don't want to mount. So in some cases we use `data/` subdirectory for data themselves (and VOLUME)

Documentation for mounting data directory should include `:Z` modificator to mount the volume as non-shared

Daemon log errors to `stdout` or `stderr`, so the logs are shown in the `docker log` output.

### Extending the docker images by creating a new layered image:

TBD

### Config files modification:

When possible, config files should be modified by creating another layer (container with the original used as BASE)

For ad-hoc changing the values it is then possible to change the config file by mounting a volume (directory or file). For example for mysql the configuration may be changed for every run this way:
```
docker run -v /mine/my.cnf:/etc/my.cnf mysql
```

For kubernetes environment, where mounting configuration is not easy currently, docker containers may accept environment variables, that will (if defined) cause adding appropriate option to the appropriate config file during start.

The environment variables for adjusting configuration will have common prefix for every configuration file, for example:

* `POSTGRESQL_` for `postgresql.conf`
* `MYSQL_` for `my.cnf`
* `MONGODB_` for `mongod.conf`

### mariadb/mysql dockerfiles:

* `mysql` user must have UID 27, GID 27
* Binaries that must be available in the shell: `mysqld`, `mysql`, `mysqladmin`
* Available commands within container:
  * `run-mysqld` (default CMD)
* `EXPOSE` 3306
* Directory for data (specified as VOLUME): `/var/lib/mysql/data`
* Config file: `/etc/my.cnf`, `/etc/my.cnf.d` are links to `/var/lib/mysql/my.cnf` and `/var/lib/mysql/my.cnf.d`
  * will be writable by `mysql` user, so they may be rewritten by process running under `mysql` user
  * will also be writable by user when running docker with arbitrary user specified. When only UID is specified, GID is 0, so we allow to write into the config all users from group 0.
  * option variables will be written into `/var/lib/mysql/my.cnf.d/platform.cnf`, but only when specified
  * `/var/lib/mysql/my.cnf` will include `!include /etc/my.cnf.d`
* Deamon runs as `mysql` user by default (`USER` directive)
* Daemon logs into `stdout`
* Socket file: not necessary, if proofed otherwise, `/var/lib/mysql/mysql.sock` will be used
* Environment variables:
  * `MYSQL_USER` - Database user name
  * `MYSQL_PASSWORD` - User's password
  * `MYSQL_DATABASE` - Name of the database to create
  * `MYSQL_ROOT_PASSWORD` - Password for the 'root' MySQL account
  * either root_password or user+password+database must be set if running with empty datadir, combination of both is also valid
  * If container is run second time and `MYSQL_PASSWORD` or `MYSQL_ROOT_PASSWORD` is used, the password will be changed.
* Configuration variables:
  * MYSQL_LOWER_CASE_TABLE_NAMES=${MYSQL_LOWER_CASE_TABLE_NAMES:-0}
  * MYSQL_MAX_CONNECTIONS=${MYSQL_MAX_CONNECTIONS:-151}
  * MYSQL_FT_MIN_WORD_LEN=${MYSQL_FT_MIN_WORD_LEN:-4}
  * MYSQL_FT_MAX_WORD_LEN=${MYSQL_FT_MAX_WORD_LEN:-20}
  * MYSQL_AIO=${MYSQL_AIO:-1}
* Replication: TBD


### postgresql dockerfile:

* Binaries that must be available in the shell: `psql`, `postmaster`, `pg_ctl`
* Available commands within container:
  * `run-postgresql` (default CMD)
* `EXPOSE` 5432
* Directory for data (VOLUME): `/var/lib/pgsql/data` ($PGDATA)
* Config file:
  * `$PGDATA/postgresql.conf`
  * `$PGDATA/pg_hba.conf`
* Daemon runs as `postgres` (`USER` directive)
* Startup log at `/var/lib/pgsql/pgstartup.log`
* Log directory: `$PGDATA/pg_log`
* `pg_hba.conf` allows to log in from addresses `0.0.0.0` and `::/0` using `md5`
* Environment variables:
  * `POSTGRESQL_USER`
  * `POSTGRESQL_PASSWORD`
  * `POSTGRESQL_DATABASE`
  * `POSTGRESQL_ADMIN_PASSWORD`
  * either root_password or user+password+database may be set if running with empty datadir, combination of both is also valid
  * If container is run second time and `POSTGRESQL_PASSWORD` or `POSTGRESQL_ADMIN_PASSWORD` is used, the password will be changed.


### mongodb dockerfile:

* Binaries that must be available in the shell: mongo, mongod, mongos (installed packages: `<collection>`, `<collection>-mongodb`)
* Available commands within container:
  * `run-mongod` (default CMD)
* `EXPOSE` 27017 (http://docs.mongodb.org/v2.6/reference/default-mongodb-port/)
* Directory for data (specified as VOLUME): `/var/lib/mongodb/data`
* Config files:
  * `/etc/mongod.conf`
  * `/etc/mongos.conf`
  * those will be writable by `mongodb` user, so they may be rewritten by process running under `mongodb` user
* Daemon runs as `mongodb` (USER directive)
* Log file directory (specified as VOLUME): `/var/log/mongodb/` but by default the daemon put logs into `stdout` or `stderr`
* Environment variables:
  * `MONGODB_USER`
  * `MONGODB_PASSWORD`
  * `MONGODB_DATABASE`
  * `MONGODB_ADMIN_PASSWORD`
  * if either `MONGODB_USER`+`MONGODB_PASSWORD`+`MONGODB_DATABASE` or `MONGODB_ADMIN_PASSWORD` is set, then the authentication is enabled.
  * If container is run second time and `MONGODB_PASSWORD` or `MONGODB_ADMIN_PASSWORD` is used, the password will be changed.


### httpd dockerfile:

* `EXPOSE` 80, 443
* Config dir: `/etc/httpd`
* Daemon runs as `root`
* Log file: `/var/log/httpd/` but by default the daemon put logs into `stdout` or `stderr`
* extra packages: `bind-utils` `httpd24` `httpd24-mod_ssl`

