FROM rhscl/s2i-base-rhel7:1

# This image provides a Perl 5.20 environment you can use to run your Perl applications.
EXPOSE 8080

# Image metadata
ENV PERL_VERSION=5.20

LABEL io.k8s.description="Platform for building and running Perl 5.20 applications" \
      io.k8s.display-name="Apache 2.4 with mod_perl/5.20" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,perl,perl520"

# Labels consumed by Red Hat build service
LABEL Name="rhscl/perl-520-rhel7" \
      BZComponent="rh-perl520-docker" \
      Version="5.20" \
      Release="12.4" \
      Architecture="x86_64"

# TODO: Cleanup cpanp cache after cpanminus is installed?
RUN yum-config-manager --enable rhel-server-rhscl-7-rpms && \
    yum-config-manager --enable rhel-7-server-optional-rpms && \
    INSTALL_PKGS="rh-perl520 rh-perl520-perl-devel rh-perl520-mod_perl rh-perl520-perl-CPAN" && \
    yum install -y --setopt=tsflags=nodocs  $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum clean all

# Copy the S2I scripts from the specific language image to $STI_SCRIPTS_PATH
COPY ./s2i/bin/ $STI_SCRIPTS_PATH

# Each language image can have 'contrib' a directory with extra files needed to
# run and build the applications.
COPY ./contrib/ /opt/app-root

# In order to drop the root user, we have to make some directories world
# writeable as OpenShift default security model is to run the container under
# random UID.
RUN mkdir -p /opt/app-root/etc/httpd.d && \
    sed -i -f /opt/app-root/etc/httpdconf.sed /opt/rh/httpd24/root/etc/httpd/conf/httpd.conf  && \
    chmod -R og+rwx /opt/rh/httpd24/root/var/run/httpd /opt/app-root/etc/httpd.d && \
    chown -R 1001:0 /opt/app-root

USER 1001

# Enable the SCL for all bash scripts.
ENV BASH_ENV=/opt/app-root/etc/scl_enable \
    ENV=/opt/app-root/etc/scl_enable \
    PROMPT_COMMAND=". /opt/app-root/etc/scl_enable"

# Set the default CMD to print the usage of the language image
CMD $STI_SCRIPTS_PATH/usage
