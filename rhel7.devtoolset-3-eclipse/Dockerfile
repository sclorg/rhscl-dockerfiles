FROM rhel7

MAINTAINER docker@softwarecollections.org

RUN yum update -y && yum install -y yum-utils && \
    yum-config-manager --enable rhel-server-rhscl-7-rpms && \
    yum-config-manager --enable rhel-7-server-optional-rpms && \
    yum clean all

RUN yum install -y --setopt=tsflags=nodocs devtoolset-3-gcc devtoolset-3-gcc-c++ devtoolset-3-gcc-gfortran devtoolset-3-gdb devtoolset-3-ide && yum clean all



ENV BASH_ENV        /etc/profile.d/cont-env.sh

ADD ./cont-env.sh /root/.bashrc
ADD ./cont-env.sh /etc/profile.d/cont-env.sh
ADD ./functions.sh /usr/share/cont-layer/common/
ADD ./enabledevtoolset-3.sh /usr/share/cont-layer/common/env.d/

