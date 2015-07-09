FROM centos:centos6

MAINTAINER docker@softwarecollections.org

RUN yum -y --setopt=tsflags=nodocs install https://www.softwarecollections.org/en/scls/rhscl/mysql55/epel-6-x86_64/download/rhscl-mysql55-epel-6-x86_64.noarch.rpm && \
    yum clean all

RUN yum install -y --setopt=tsflags=nodocs mysql55 hostname gettext which && yum clean all


EXPOSE 3306

ENV	MYSQL_VERSION=5.5 \
	HOME=/var/lib/mysql \
	BASH_ENV=/etc/profile.d/cont-env.sh

LABEL	openshift.io/tags="database,mysql,mysql55"  \
	k8s.io/display-name="MySQL 5.5"  \
	openshift.io/expose-services="3306:mysql"  \
	k8s.io/description="MySQL is a multi-user, multi-threaded SQL database server" 

ADD ./.bashrc $HOME/.bashrc
ADD ./usr /usr
ADD ./my.cnf /opt/rh/mysql55/root/etc/my.cnf
ADD ./enablemysql55.sh /usr/share/cont-layer/common/env/enablemysql55.sh
ADD ./etc /etc
ADD ./root /root

RUN	/usr/libexec/cont-setup && \
	:

USER 27

VOLUME ["/var/lib/mysql/data"]

ENTRYPOINT ["/usr/bin/container-entrypoint"]

CMD ["cont-mysqld"]

