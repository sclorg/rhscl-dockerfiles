FROM centos:centos7

MAINTAINER SoftwareCollections.org <sclorg@redhat.com>

LABEL io.k8s.description="Platform for building and running Ruby on Rails 4.1 applications" \
      io.k8s.display-name="Ruby on Rails 4.1"

# The following is taken from STI base image so this Dockerfile follows the same convetions.
# https://github.com/openshift/sti-base/blob/master/Dockerfile

ENV HOME=/opt/app-root/src \
    PATH=/opt/app-root/src/bin:/opt/app-root/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

ADD contrib/etc/scl_enable /opt/app-root/etc/scl_enable
ENV BASH_ENV=/opt/app-root/etc/scl_enable \
    ENV=/opt/app-root/etc/scl_enable \
    PROMPT_COMMAND=". /opt/app-root/etc/scl_enable"

# Let's install the same as STI images
RUN yum install -y --setopt=tsflags=nodocs \
  autoconf \
  automake \
  bsdtar \
  epel-release \
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
  mariadb-devel \
  mariadb-libs \
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
  zlib-devel && \
  yum clean all -y && \
  mkdir -p ${HOME} && \
  groupadd -r default -f -g 1001 && \
  useradd -u 1001 -r -g default -d ${HOME} -s /sbin/nologin \
      -c "Default Application User" default && \
  chown -R 1001:1001 /opt/app-root


# This image provides a Ruby on Rails 4.1 environment you can use to run your Rails
# applications.

EXPOSE 8080

ENV RAILS_VERSION 4.1

RUN rpmkeys --import file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7 && \
    yum -y --setopt=tsflags=nodocs install https://www.softwarecollections.org/en/scls/rhscl/rh-passenger40/epel-7-x86_64/download/rhscl-rh-passenger40-epel-7-x86_64.noarch.rpm && \
    yum -y --setopt=tsflags=nodocs install https://www.softwarecollections.org/en/scls/rhscl/rh-ruby22/epel-7-x86_64/download/rhscl-rh-ruby22-epel-7-x86_64.noarch.rpm && \
    yum -y --setopt=tsflags=nodocs install https://www.softwarecollections.org/en/scls/rhscl/v8314/epel-7-x86_64/download/rhscl-v8314-epel-7-x86_64.noarch.rpm && \
    yum -y --setopt=tsflags=nodocs install https://www.softwarecollections.org/en/scls/rhscl/rh-ror41/epel-7-x86_64/download/rhscl-rh-ror41-epel-7-x86_64.noarch.rpm && \
    yum -y --setopt=tsflags=nodocs install https://www.softwarecollections.org/en/scls/rhscl/nodejs010/epel-7-x86_64/download/rhscl-nodejs010-epel-7-x86_64.noarch.rpm && \
    yum install -y --setopt=tsflags=nodocs rh-ruby22 rh-ruby22-ruby-devel rh-ruby22-rubygem-rake v8314 rh-ruby22-rubygem-bundler rh-ror41 nodejs010 && \
    yum clean all -y

# Add .gemrc
ADD contrib/.gemrc /opt/app-root/.gemrc

RUN chown -R 1001:1001 /opt/app-root

USER 1001

WORKDIR ${HOME}

# Install the usage script with base image usage informations
ADD contrib/bin/usage /usr/local/bin/usage

# Use entrypoint so path is correctly adjusted already at the time the command
# is searching, so something like docker run IMG python runs binary from SCL
ADD contrib/bin/container-entrypoint /usr/bin/container-entrypoint

# Set the default CMD to print the usage of the language image
ENTRYPOINT ["container-entrypoint"]
CMD ["usage"]
