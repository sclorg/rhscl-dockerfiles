FROM rhel7-local-test

MAINTAINER docker@softwarecollections.org

#RUN yum update -y && yum install -y yum-utils && \
#    yum-config-manager --enable rhel-server-rhscl-7-rpms && \
#    yum-config-manager --enable rhel-7-server-optional-rpms && \
#    yum clean all

RUN yum install -y --setopt=tsflags=nodocs rh-mariadb100 && yum clean all


EXPOSE 3306
ENV HOME            /var/lib/mysql
ENV BASH_ENV        /etc/profile.d/cont-env.sh
ADD ./.bashrc $HOME/.bashrc
ADD ./usr /usr
ADD ./opt /opt
ADD ./my.cnf /etc/opt/rh/rh-mariadb100/my.cnf
ADD ./enablerh-mariadb100.sh /usr/share/cont-layer/common/env/enablerh-mariadb100.sh
ADD ./etc /etc
ADD ./root /root

RUN	/usr/libexec/cont-setup && \
	:

USER mysql

VOLUME ["/var/lib/mysql/data"]

CMD ["cont-mysqld"]

