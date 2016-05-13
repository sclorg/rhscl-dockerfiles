FROM rhel:7.2-released

LABEL io.k8s.description="Platform for building and running Ruby on Rails 4.2 applications" \
      io.k8s.display-name="Ruby on Rails 4.2"

# Labels consumed by Red Hat build service
LABEL BZComponent="rh-ror42-docker" \
      Name="rhscl_beta/ror-42-rhel7" \
      Version="4.2" \
      Release="2" \
      Architecture="x86_64"

# The following is taken from STI base image so this Dockerfile follows the same convetions.
# https://github.com/openshift/sti-base/blob/master/Dockerfile

ENV HOME=/opt/app-root/src \
    PATH=/opt/app-root/src/bin:/opt/app-root/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

COPY contrib/etc/scl_enable /opt/app-root/etc/scl_enable
ENV BASH_ENV=/opt/app-root/etc/scl_enable \
    ENV=/opt/app-root/etc/scl_enable \
    PROMPT_COMMAND=". /opt/app-root/etc/scl_enable"

# Let's install the same as STI images
RUN yum install -y --setopt=tsflags=nodocs \
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

RUN yum-config-manager --enable rhel-server-rhscl-7-rpms && \
    yum-config-manager --enable rhel-7-server-optional-rpms && \
    INSTALL_PKGS="rh-ror42 rh-ruby23-ruby-devel" && \
    yum install -y --setopt=tsflags=nodocs $INSTALL_PKGS && rpm -V $INSTALL_PKGS && \
    yum clean all -y

# Add .gemrc
COPY contrib/.gemrc /opt/app-root/.gemrc

RUN chown -R 1001:1001 /opt/app-root

USER 1001

WORKDIR ${HOME}

# Install the usage script with base image usage informations
COPY contrib/bin/usage /usr/local/bin/usage

# Use entrypoint so path is correctly adjusted already at the time the command
# is searching, so something like docker run IMG python runs binary from SCL
COPY contrib/bin/container-entrypoint /usr/bin/container-entrypoint

# Set the default CMD to print the usage of the language image
ENTRYPOINT ["container-entrypoint"]
CMD ["usage"]
