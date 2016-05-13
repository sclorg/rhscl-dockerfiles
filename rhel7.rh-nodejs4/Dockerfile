#FROM openshift/base-rhel7
#FROM rhscl/s2i-base-rhel7:1
FROM rhscl/s2i-base-rhel7

# This image provides a Node.JS environment you can use to run your Node.JS
# applications.

EXPOSE 8080

ENV NODEJS_VERSION 4.4

LABEL io.openshift.s2i.scripts-url=image:///usr/libexec/s2i \
      io.s2i.scripts-url=image:///usr/libexec/s2i

ENV BASH_ENV=/opt/app-root/etc/scl_enable \
    ENV=/opt/app-root/etc/scl_enable \
    PROMPT_COMMAND=". /opt/app-root/etc/scl_enable"
# Set the default CMD to print the usage of the language image CMD $STI_SCRIPTS_PATH/usage

LABEL summary="Platform for building and running Node.js 4.4 applications" \
      io.k8s.description="Platform for building and running Node.js 4.4 applications" \
      io.k8s.display-name="Node.js 4.4" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,nodejs,nodejs4" \
      com.redhat.dev-mode="DEV_MODE:false" \
      com.redhat.deployments-dir="/opt/app-root/src" \
      com.redhat.dev-mode.port="DEBUG_PORT:5858"

# Labels consumed by Red Hat build service
#LABEL com.redhat.component="rh-nodejs4-docker" \
#      name="openshift3/nodejs-4-rhel7" \
#      version="4.4" \
#      release="1" \
#      architecture="x86_64"

LABEL BZComponent="rh-nodejs4-docker" \
      Name="rhscl/nodejs-4-rhel7" \
      Version="4.4" \
      Release="7" \
      Architecture="x86_64"

RUN yum-config-manager --enable rhel-server-rhscl-7-rpms && \
    yum-config-manager --enable rhel-7-server-optional-rpms && \
    yum-config-manager --disable epel >/dev/null || : && \
    INSTALL_PKGS="rh-nodejs4 rh-nodejs4-npm rh-nodejs4-nodejs-nodemon" && \
    yum install -y --setopt=tsflags=nodocs $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum clean all -y

# Copy the S2I scripts from the specific language image to $STI_SCRIPTS_PATH
COPY ./s2i/bin/ $STI_SCRIPTS_PATH

# Each language image can have 'contrib' a directory with extra files needed to
# run and build the applications.
COPY ./contrib/ /opt/app-root

# Drop the root user and make the content of /opt/app-root owned by user 1001
RUN chown -R 1001:0 /opt/app-root
USER 1001

# Set the default CMD to print the usage of the language image
CMD $STI_SCRIPTS_PATH/usage
