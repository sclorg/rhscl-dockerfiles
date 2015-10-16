FROM centos:centos7

# RHSCL nginx16 image.
#
# Volumes:
#  * /opt/rh/nginx16/root/usr/share/nginx/html - Datastore for nginx
#  * /var/log/nginx16 - Storage for logs when $NGINX_LOG_TO_VOLUME is set
# Environment:
#  * $NGINX_LOG_TO_VOLUME (optional) - When set, nginx will log into /var/log/nginx16

MAINTAINER SoftwareCollections.org <sclorg@redhat.com>

EXPOSE 80
EXPOSE 443

COPY run-*.sh /usr/local/bin/
RUN mkdir -p /var/lib/nginx16
COPY contrib /var/lib/nginx16/

RUN rpmkeys --import file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7 && \
    yum -y --setopt=tsflags=nodocs install https://www.softwarecollections.org/en/scls/rhscl/nginx16/epel-7-x86_64/download/rhscl-nginx16-epel-7-x86_64.noarch.rpm && \
    yum install -y --setopt=tsflags=nodocs gettext hostname bind-utils nginx16 nginx16-nginx && \
    yum clean all

# When bash is started non-interactively, to run a shell script, for example it
# looks for this variable and source the content of this file. This will enable
# the SCL for all scripts without need to do 'scl enable'.
ENV BASH_ENV=/var/lib/nginx16/scl_enable \
    ENV=/var/lib/nginx16/scl_enable \
    PROMPT_COMMAND=". /var/lib/nginx16/scl_enable"


VOLUME ["/opt/rh/nginx16/root/usr/share/nginx/html"]
VOLUME ["/var/log/nginx16"]

ENTRYPOINT ["/usr/local/bin/run-nginx16.sh"]
CMD ["nginx", "-g", "daemon off;"]
