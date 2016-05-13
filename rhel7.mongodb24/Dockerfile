FROM rhel:7.2-released
# MongoDB image for OpenShift.
#
# Volumes:
#  * /var/lib/mongodb/data - Datastore for MongoDB
# Environment:
#  * $MONGODB_USER - Database user name
#  * $MONGODB_PASSWORD - User's password
#  * $MONGODB_DATABASE - Name of the database to create
#  * $MONGODB_ADMIN_PASSWORD - Password of the MongoDB Admin

ENV MONGODB_VERSION=2.4 \
    HOME=/var/lib/mongodb

LABEL io.k8s.description="MongoDB is a scalable, high-performance, open source NoSQL database." \
      io.k8s.display-name="MongoDB 2.4" \
      io.openshift.expose-services="27017:mongodb" \
      io.openshift.tags="database,mongodb,mongodb24"

# Labels consumed by Red Hat build service
LABEL BZComponent="openshift-mongodb-docker" \
      Name="openshift3/mongodb-24-rhel7" \
      Version="2.4" \
      Release="27"

EXPOSE 27017

# Due to the https://bugzilla.redhat.com/show_bug.cgi?id=1206151,
# the whole /var/lib/mongodb/ dir has to be chown-ed.
RUN yum install -y yum-utils && \
    yum-config-manager --enable rhel-server-rhscl-7-rpms && \
    yum-config-manager --enable rhel-7-server-optional-rpms && \
    INSTALL_PKGS="bind-utils gettext iproute rsync tar v8314 mongodb24-mongodb mongodb24" && \
    yum install -y --setopt=tsflags=nodocs $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum clean all && \
    mkdir -p /var/lib/mongodb/data && chown -R mongodb.0 /var/lib/mongodb/ && \
    # Loosen permission bits to avoid problems running container with arbitrary UID
    chmod -R a+rwx /opt/rh/mongodb24/root/var/lib/mongodb && \
    chmod -R g+rwx /var/lib/mongodb

# Get prefix path and path to scripts rather than hard-code them in scripts
ENV CONTAINER_SCRIPTS_PATH=/usr/share/container-scripts/mongodb \
    MONGODB_PREFIX=/opt/rh/mongodb24/root/usr \
    ENABLED_COLLECTIONS=mongodb24

# When bash is started non-interactively, to run a shell script, for example it
# looks for this variable and source the content of this file. This will enable
# the SCL for all scripts without need to do 'scl enable'.
ENV BASH_ENV=${CONTAINER_SCRIPTS_PATH}/scl_enable \
    ENV=${CONTAINER_SCRIPTS_PATH}/scl_enable \
    PROMPT_COMMAND=". ${CONTAINER_SCRIPTS_PATH}/scl_enable"

ADD root /

# Container setup
RUN touch /etc/mongod.conf && chown mongodb:0 /etc/mongod.conf && /usr/libexec/fix-permissions /etc/mongod.conf

VOLUME ["/var/lib/mongodb/data"]

USER 184

ENTRYPOINT ["container-entrypoint"]
CMD ["run-mongod"]
