FROM rhel7-local-test

MAINTAINER docker@softwarecollections.org

#RUN yum update -y && yum install -y yum-utils && \
#    yum-config-manager --enable rhel-server-rhscl-7-rpms && \
#    yum-config-manager --enable rhel-7-server-optional-rpms && \
#    yum clean all

RUN yum install -y --setopt=tsflags=nodocs rh-perl520 && yum clean all


ENV BASH_ENV        /etc/profile.d/cont-env.sh
ADD ./enablerh-perl520.sh /usr/share/cont-layer/common/env/enablerh-perl520.sh
ADD ./usr /usr
ADD ./etc /etc
ADD ./root /root

