FROM rhel6

MAINTAINER docker@softwarecollections.org

RUN yum install -y --setopt=tsflags=nodocs yum-utils && \
    yum-config-manager --enable rhel-server-rhscl-6-rpms && \
    yum-config-manager --enable rhel-6-server-optional-rpms && \
    yum clean all

RUN yum install -y --setopt=tsflags=nodocs postgresql92 && yum clean all


EXPOSE 5432

ENV	POSTGRESQL_VERSION=9.2 \
	HOME=/var/lib/pgsql \
	BASH_ENV=/etc/profile.d/cont-env.sh

LABEL	openshift.io/tags="database,postgresql,postgresql92"  \
	k8s.io/display-name="PostgreSQL 9.2"  \
	openshift.io/expose-services="5432:postgresql"  \
	k8s.io/description="PostgreSQL is an advanced Object-Relational database management system" 

ADD ./.bashrc $HOME/.bashrc
ADD ./usr /usr
ADD ./var /var
ADD ./cont-setup /usr/libexec/cont-setup
ADD ./enablepostgresql92.sh /usr/share/cont-layer/common/env/enablepostgresql92.sh
ADD ./etc /etc
ADD ./root /root

RUN	/usr/libexec/cont-setup && \
	:

USER 26

VOLUME ["/var/lib/pgsql/data"]

ENTRYPOINT ["/usr/bin/container-entrypoint"]

CMD ["cont-postgresql-cmd"]


