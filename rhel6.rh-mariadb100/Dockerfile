FROM rhel6

MAINTAINER docker@softwarecollections.org

RUN yum update -y && yum install -y yum-utils && \
    yum-config-manager --enable rhel-server-rhscl-6-rpms && \
    yum-config-manager --enable rhel-6-server-optional-rpms && \
    yum clean all

RUN yum install -y --setopt=tsflags=nodocs rh-mariadb100 && yum clean all


EXPOSE 3306

ENV BASH_ENV        /etc/profile.d/cont-env.sh
ENV HOME            /var/lib/mysql

ADD ./cont-env.sh /root/.bashrc
ADD ./cont-env.sh /etc/profile.d/cont-env.sh
ADD ./functions.sh /usr/share/cont-layer/common/
ADD ./enablerh-mariadb100.sh /usr/share/cont-layer/common/env.d/
ADD ./.bashrc $HOME/.bashrc
ADD ./cont-mysqld /usr/bin/cont-mysqld
ADD ./my.cnf /opt/rh/mariadb55/root/etc/my.cnf
ADD ./10-base.sh /usr/share/cont-layer/mysql/post-init.d/10-base.sh
ADD ./20-config-env.sh /usr/share/cont-layer/mysql/post-init.d/20-config-env.sh
ADD ./cont-setup /usr/libexec/cont-setup

RUN	/usr/libexec/cont-setup && \
	:

USER mysql

VOLUME ["/var/lib/mysql/data"]

CMD ["cont-mysqld"]


