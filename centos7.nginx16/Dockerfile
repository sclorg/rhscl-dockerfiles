FROM centos:centos7

MAINTAINER docker@softwarecollections.org

RUN yum -y --setopt=tsflags=nodocs install https://www.softwarecollections.org/en/scls/rhscl/nginx16/epel-7-x86_64/download/rhscl-nginx16-epel-7-x86_64.noarch.rpm && \
    yum clean all

RUN yum install -y --setopt=tsflags=nodocs nginx16 && yum clean all


EXPOSE 80
EXPOSE 443

ENV	BASH_ENV=/etc/profile.d/cont-env.sh


ADD ./enablenginx16.sh /usr/share/cont-layer/common/env/enablenginx16.sh
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

