FROM centos:centos6

MAINTAINER docker@softwarecollections.org

RUN yum -y --setopt=tsflags=nodocs install https://www.softwarecollections.org/en/scls/rhscl/nodejs010/epel-6-x86_64/download/rhscl-nodejs010-epel-6-x86_64.noarch.rpm && \
    yum clean all

RUN yum install -y --setopt=tsflags=nodocs nodejs010 \
    autoconf \
    automake \
    bsdtar \
    findutils \
    gcc-c++ \
    gdb \
    gettext \
    git \
    libcurl-devel \
    libxml2-devel \
    libxslt-devel \
    lsof \
    make \
    mysql-devel \
    mysql-libs \
    openssl-devel \
    patch \
    postgresql-devel \
    procps-ng \
    scl-utils \
    sqlite-devel \
    tar \
    unzip \
    wget \
    which \
    yum-utils \
    zlib-devel \
 && yum clean all


EXPOSE 8080

ENV	NODEJS_VERSION=0.10 \
	BASH_ENV=/etc/profile.d/cont-env.sh

LABEL	openshift.io/tags="builder,nodejs,nodejs010"  \
	k8s.io/display-name="Node.js 0.10"  \
	openshift.io/expose-services="8080:http"  \
	k8s.io/description="Platform for building and running Node.js 0.10 applications" 

ADD ./enablenodejs010.sh /usr/share/cont-layer/common/env/enablenodejs010.sh
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

