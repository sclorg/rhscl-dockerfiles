FROM openshift/base-centos7

# This image provides a Perl 5.20 environment you can use to run your Perl applications.
MAINTAINER SoftwareCollections.org <sclorg@redhat.com>

EXPOSE 8080

# Image metadata
ENV PERL_VERSION=5.20

LABEL io.k8s.description="Platform for building and running Perl 5.20 applications" \
      io.k8s.display-name="Apache 2.4 with mod_perl/5.20" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,perl,perl520"

# TODO: Cleanup cpanp cache after cpanminus is installed?
RUN yum install -y \
    https://www.softwarecollections.org/en/scls/rhscl/httpd24/epel-7-x86_64/download/rhscl-httpd24-epel-7-x86_64.noarch.rpm \
    https://www.softwarecollections.org/en/scls/rhscl/rh-perl520/epel-7-x86_64/download/rhscl-rh-perl520-epel-7-x86_64.noarch.rpm && \
    yum install -y --setopt=tsflags=nodocs make rh-perl520 rh-perl520-devel rh-perl520-mod_perl rh-perl520-perl-CPAN && \
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
