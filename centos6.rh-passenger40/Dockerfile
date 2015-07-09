FROM centos:centos6

MAINTAINER docker@softwarecollections.org

RUN yum -y --setopt=tsflags=nodocs install https://www.softwarecollections.org/en/scls/rhscl/rh-passenger40/epel-6-x86_64/download/rhscl-rh-passenger40-epel-6-x86_64.noarch.rpm && \
    yum clean all

RUN yum install -y --setopt=tsflags=nodocs rh-passenger40 rh-passenger40-ruby22 && yum clean all



ENV	BASH_ENV=/etc/profile.d/cont-env.sh


ADD ./enablerh-passenger40.sh /usr/share/cont-layer/common/env/enablerh-passenger40.sh
ADD ./usr /usr
ADD ./etc /etc
ADD ./root /root

ENV HOME /home/default
RUN     groupadd -r default -f -g 1001 && \
        useradd -u 1001 -r -g default -d ${HOME} -s /sbin/nologin \
                        -c "Default Application User" default

USER 1001

ENTRYPOINT ["/usr/bin/container-entrypoint"]

CMD ["container-usage"]

