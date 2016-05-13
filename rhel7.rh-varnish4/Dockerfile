FROM rhscl/s2i-base-rhel7:1

# RHSCL rh-varnish4 image.

EXPOSE 8080
EXPOSE 8443

LABEL io.k8s.description="Platform for running Varnish or building Varnish-based application" \
      io.k8s.display-name="Varnish 4" \
      io.openshift.expose-services="8080:http" \
      io.openshift.expose-services="8443:https" \
      io.openshift.tags="builder,varnish,rh-varnish4" \
      BZComponent="rh-varnish4-docker" \
      Name="rhscl_beta/varnish-4-rhel7" \
      Version="4" \
      Release="9" \
      Architecture="x86_64"

ENV VARNISH_CONFIGURATION_PATH=/etc/opt/rh/rh-varnish4/varnish

RUN yum install -y yum-utils gettext hostname && \
    yum-config-manager --enable rhel-server-rhscl-7-rpms && \
    yum-config-manager --enable rhel-7-server-optional-rpms && \
    yum-config-manager --enable rhel-7-server-ose-3.0-rpms && \
    yum install -y --setopt=tsflags=nodocs nss_wrapper && \
    yum install -y --setopt=tsflags=nodocs bind-utils rh-varnish4-* && \
    rm -f /etc/profile.d/lang.sh && \
    rm -f /etc/profile.d/lang.csh && \
    yum clean all

# Copy the S2I scripts from the specific language image to $STI_SCRIPTS_PATH
COPY ./s2i/bin/ $STI_SCRIPTS_PATH

# Each language image can have 'contrib' a directory with extra files needed to
# run and build the applications.
COPY ./contrib/ /opt/app-root

# In order to drop the root user, we have to make some directories world
# writeable as OpenShift default security model is to run the container under
# random UID.
RUN chmod -R a+rwx /opt/app-root/etc && \
    chmod -R a+rwx /var/opt/rh/rh-varnish4 && \
    chmod -R a+rwx /etc/opt/rh/rh-varnish4 && \
    chown -R 1001:0 /opt/app-root && \
    chown -R 1001:0 /var/opt/rh/rh-varnish4 && \
    chown -R 1001:0 /etc/opt/rh/rh-varnish4

USER 1001

# VOLUME ["/etc/opt/rh/rh-varnish4/varnish"]

ENV BASH_ENV=/opt/app-root/etc/scl_enable \
    ENV=/opt/app-root/etc/scl_enable \
    PROMPT_COMMAND=". /opt/app-root/etc/scl_enable"

CMD $STI_SCRIPTS_PATH/usage
