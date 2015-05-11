FROM rhel6

MAINTAINER docker@softwarecollections.org

RUN yum update -y && yum install -y yum-utils && \
    yum-config-manager --enable rhel-server-rhscl-6-rpms && \
    yum-config-manager --enable rhel-6-server-optional-rpms && \
    yum clean all

RUN yum install -y --setopt=tsflags=nodocs rh-java-common && yum clean all


ENV BASH_ENV        /etc/profile.d/cont-env.sh
ADD ./enablerh-java-common.sh /usr/share/cont-layer/common/env/enablerh-java-common.sh
ADD ./usr /usr
ADD ./etc /etc
ADD ./root /root


