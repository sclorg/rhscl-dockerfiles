FROM centos:centos7

MAINTAINER SoftwareCollections.org <sclorg@redhat.com>

RUN yum -y --setopt=tsflags=nodocs install https://www.softwarecollections.org/en/scls/rhscl/devtoolset-4/epel-7-x86_64/download/rhscl-devtoolset-4-epel-7-x86_64.noarch.rpm && \
    yum clean all

RUN yum install -y --setopt=tsflags=nodocs devtoolset-4 && yum clean all



ENV	BASH_ENV=/etc/profile.d/cont-env.sh


ADD ./enabledevtoolset-4.sh /usr/share/cont-layer/common/env/enabledevtoolset-4.sh
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

