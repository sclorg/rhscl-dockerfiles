FROM rhel6

MAINTAINER docker@softwarecollections.org

RUN yum update -y && yum install -y yum-utils && \
    yum-config-manager --enable rhel-server-rhscl-6-rpms && \
    yum-config-manager --enable rhel-6-server-optional-rpms && \
    yum clean all

RUN yum install -y --setopt=tsflags=nodocs httpd24 python33 python33-mod_wsgi && yum clean all


EXPOSE 80
EXPOSE 443

ENV BASH_ENV        /etc/profile.d/cont-env.sh

ADD ./cont-env.sh /root/.bashrc
ADD ./cont-env.sh /etc/profile.d/cont-env.sh
ADD ./functions.sh /usr/share/cont-layer/common/
ADD ./enablehttpd24.sh /usr/share/cont-layer/common/env.d/


