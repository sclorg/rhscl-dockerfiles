FROM rhel7

MAINTAINER docker@softwarecollections.org

RUN yum update -y && yum install -y yum-utils && \
    yum-config-manager --enable rhel-server-rhscl-7-rpms && \
    yum-config-manager --enable rhel-7-server-optional-rpms && \
    yum clean all

RUN yum install -y --setopt=tsflags=nodocs rh-postgresql94 && yum clean all


EXPOSE 5432
ENV BASH_ENV        /etc/profile.d/cont-env.sh
ADD ./enablerh-postgresql94.sh /usr/share/cont-layer/common/env/enablerh-postgresql94.sh
ADD ./usr /usr
ADD ./etc /etc
ADD ./root /root

CMD ["container-usage"]

