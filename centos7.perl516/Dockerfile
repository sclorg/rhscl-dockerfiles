FROM openshift/base-centos7

# This image provides a Perl 5.16 environment you can use to run your Perl applications.
MAINTAINER SoftwareCollections.org <sclorg@redhat.com>

EXPOSE 8080

# Image metadata
ENV PERL_VERSION=5.16 \
    PATH=$PATH:/opt/rh/perl516/root/usr/local/bin

LABEL io.k8s.description="Platform for building and running Perl 5.1.6 applications" \
      io.k8s.display-name="Apache 2.4 with mod_perl/5.1.6" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,perl,perl516"

# TODO: Cleanup cpanp cache after cpanminus is installed?
RUN yum install -y \
    https://www.softwarecollections.org/en/scls/rhscl/httpd24/epel-7-x86_64/download/rhscl-httpd24-epel-7-x86_64.noarch.rpm \
    https://www.softwarecollections.org/en/scls/rhscl/perl516/epel-7-x86_64/download/rhscl-perl516-epel-7-x86_64.noarch.rpm && \
    yum install -y --setopt=tsflags=nodocs httpd24 perl516 perl516-mod_perl perl516-perl-CPANPLUS && \
    yum clean all && \
    scl enable perl516 -- cpanp 's conf prereqs 1; s save system' && \
    scl enable perl516 -- cpanp 's conf allow_build_interactivity 0; s save system'

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

# Set the default CMD to print the usage of the language image
CMD $STI_SCRIPTS_PATH/usage
