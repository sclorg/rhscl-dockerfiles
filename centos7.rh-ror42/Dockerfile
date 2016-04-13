FROM centos:centos7

MAINTAINER SoftwareCollections.org <sclorg@redhat.com>

LABEL io.k8s.description="Platform for building and running Ruby on Rails 4.2 applications" \
      io.k8s.display-name="Ruby on Rails 4.2"

# The following is taken from STI base image so this Dockerfile follows the same convetions.
# https://github.com/openshift/sti-base/blob/master/Dockerfile

ENV HOME=/opt/app-root/src \
    PATH=/opt/app-root/src/bin:/opt/app-root/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

ADD contrib/etc/scl_enable /opt/app-root/etc/scl_enable
ENV BASH_ENV=/opt/app-root/etc/scl_enable \
    ENV=/opt/app-root/etc/scl_enable \
    PROMPT_COMMAND=". /opt/app-root/etc/scl_enable"

# Let's install the same as STI images
RUN rpmkeys --import file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7 && \
    yum install -y --setopt=tsflags=nodocs \
  autoconf \
  automake \
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


# This image provides a Ruby on Rails 4.2 environment you can use to run your Rails
# applications.

EXPOSE 8080

ENV RAILS_VERSION 4.2

RUN yum -y install centos-release-scl && \
    yum-config-manager --enable centos-sclo-rh-testing && \
    INSTALL_PKGS="rh-ruby23 rh-ruby23-ruby-devel rh-ruby23-rubygem-rake rh-ruby23-rubygem-bundler rh-ror42 rh-nodejs4" && \
    yum install -y --setopt=tsflags=nodocs --nogpgcheck $INSTALL_PKGS && rpm -V $INSTALL_PKGS && \
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
