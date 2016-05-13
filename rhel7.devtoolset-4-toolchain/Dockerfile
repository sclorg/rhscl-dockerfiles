FROM rhel:7.2-released
MAINTAINER Marek Polacek <polacek@redhat.com>

LABEL io.k8s.description="Platform for building applications using Red Hat Developer Toolset 4" \
      io.k8s.display-name="Developer Toolset 4 Toolchain"

LABEL BZComponent="devtoolset-4-toolchain-docker"
LABEL Name="rhscl_beta/devtoolset-4-toolchain-rhel7"
LABEL Version="4"
LABEL Release="10.1"
LABEL Architecture="x86_64"

RUN yum-config-manager --enable rhel-server-rhscl-7-rpms && \
    yum-config-manager --enable rhel-7-server-optional-rpms && \
    yum-config-manager --disable epel >/dev/null || : && \
    yum install -y --setopt=tsflags=nodocs devtoolset-4-gcc devtoolset-4-gcc-c++ devtoolset-4-gcc-gfortran devtoolset-4-gdb && \
    yum clean all -y


# Each language image can have 'contrib' a directory with extra files needed to
# run and build the applications.
COPY ./contrib/ /opt/app-root

ENV HOME=/opt/app-root/src \
    PATH=/opt/app-root/src/bin:/opt/app-root/bin:/opt/rh/devtoolset-4/root/usr/bin/:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN mkdir -p ${HOME} && \
    groupadd -r default -f -g 1001 && \
    useradd -u 1001 -r -g default -d ${HOME} -s /sbin/nologin \
    -c "Default Application User" default && \
    chown -R 1001:1001 /opt/app-root && \
    chmod u+x /opt/app-root/bin/usage

USER 1001

WORKDIR ${HOME}

# Use entrypoint so path is correctly adjusted already at the time the command
# is searching, so something like docker run IMG gcc runs binary from SCL.
ADD contrib/bin/container-entrypoint /usr/bin/container-entrypoint

# Install the usage script with base image usage informations
ADD contrib/bin/usage /usr/local/bin/usage

ADD contrib/etc/scl_enable /opt/app-root/etc/scl_enable

# Enable the SCL for all bash scripts.
ENV BASH_ENV=/opt/app-root/etc/scl_enable \
    ENV=/opt/app-root/etc/scl_enable \
    PROMPT_COMMAND=". /opt/app-root/etc/scl_enable"

# Set the default CMD to print the usage of the language image
ENTRYPOINT ["container-entrypoint"]
CMD ["usage"]
