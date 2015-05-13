FROM rhel7

MAINTAINER docker@softwarecollections.org

RUN yum update -y && yum install -y yum-utils && \
    yum-config-manager --enable rhel-server-rhscl-7-rpms && \
    yum-config-manager --enable rhel-7-server-optional-rpms && \
    yum clean all

RUN yum install -y --setopt=tsflags=nodocs rh-ruby22 && yum clean all


ENV BASH_ENV        /etc/profile.d/cont-env.sh
ADD ./enablerh-ruby22.sh /usr/share/cont-layer/common/env/enablerh-ruby22.sh
ADD ./usr /usr
ADD ./etc /etc
ADD ./root /root

CMD ["container-usage"]

