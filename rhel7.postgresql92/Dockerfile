FROM rhel7

MAINTAINER docker@softwarecollections.org

RUN yum update -y && yum install -y yum-utils && \
    yum-config-manager --enable rhel-server-rhscl-7-rpms && \
    yum-config-manager --enable rhel-7-server-optional-rpms && \
    yum clean all

RUN yum install -y --setopt=tsflags=nodocs postgresql92 && yum clean all


EXPOSE 5432
ENV HOME            /var/lib/pgsql
ENV BASH_ENV        /etc/profile.d/cont-env.sh
ADD ./.bashrc /var/lib/pgsql/.bashrc
ADD ./usr /usr
ADD ./var /var
ADD ./cont-setup /usr/libexec/cont-setup
ADD ./enablepostgresql92.sh /usr/share/cont-layer/common/env/enablepostgresql92.sh
ADD ./etc /etc
ADD ./root /root

RUN	/usr/libexec/cont-setup && \
	:

USER postgres

VOLUME ["/var/lib/pgsql/data"]

ENTRYPOINT ["/usr/bin/cont-entry"]

CMD ["cont-postgresql-cmd"]

