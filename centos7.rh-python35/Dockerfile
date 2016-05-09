FROM openshift/base-centos7

# This image provides a Python 3.5 environment you can use to run your Python
# applications.

MAINTAINER SoftwareCollections.org <sclorg@redhat.com>

EXPOSE 8080

ENV PYTHON_VERSION=3.5 \
    PATH=$HOME/.local/bin/:$PATH

LABEL io.k8s.description="Platform for building and running Python 3.5 applications" \
      io.k8s.display-name="Python 3.5" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,python,python35,rh-python35"

RUN rpmkeys --import file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7 && \
    yum -y install centos-release-scl && \
    yum-config-manager --enable centos-sclo-rh-testing && \
    INSTALL_PKGS="rh-python35 rh-python35-python-devel rh-python35-python-setuptools rh-python35-python-pip nss_wrapper" && \
    yum install -y --setopt=tsflags=nodocs --nogpgcheck $INSTALL_PKGS && rpm -V $INSTALL_PKGS && \
    yum clean all -y

# Copy the S2I scripts from the specific language image to $STI_SCRIPTS_PATH
COPY ./s2i/bin/ $STI_SCRIPTS_PATH

# Each language image can have 'contrib' a directory with extra files needed to
# run and build the applications.
COPY ./contrib/ /opt/app-root

# In order to drop the root user, we have to make some directories world
# writeable as OpenShift default security model is to run the container under
# random UID.
RUN chown -R 1001:0 /opt/app-root && chmod -R og+rwx /opt/app-root

USER 1001

# Set the default CMD to print the usage of the language image
CMD $STI_SCRIPTS_PATH/usage
