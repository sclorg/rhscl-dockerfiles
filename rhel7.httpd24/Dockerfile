FROM rhel7.1

# RHSCL httpd24 image.
#
# Volumes:
#  * /opt/rh/httpd24/root/var/www - Datastore for httpd
#  * /var/log/httpd24 - Storage for logs when $HTTPD_LOG_TO_VOLUME is set
# Environment:
#  * $HTTPD_LOG_TO_VOLUME (optional) - When set, httpd will log into /var/log/httpd24

# Labels consumed by Red Hat build service
LABEL Component="httpd24-docker" \
      Name="rhscl/httpd-24-rhel7" \
      Version="2.4" \
      Release="8" \
      BZComponent="httpd24-docker" \
      Architecture="x86_64"


EXPOSE 80
EXPOSE 443

COPY run-*.sh /usr/local/bin/
RUN mkdir -p /var/lib/httpd24
COPY contrib /var/lib/httpd24/

RUN yum install -y yum-utils gettext hostname && \
    yum-config-manager --enable rhel-server-rhscl-7-rpms && \
    yum-config-manager --enable rhel-7-server-optional-rpms && \
    yum install -y --setopt=tsflags=nodocs bind-utils httpd24 httpd24-mod_ssl && \
    yum clean all

# When bash is started non-interactively, to run a shell script, for example it
# looks for this variable and source the content of this file. This will enable
# the SCL for all scripts without need to do 'scl enable'.
ENV BASH_ENV=/var/lib/httpd24/scl_enable \
    ENV=/var/lib/httpd24/scl_enable \
    PROMPT_COMMAND=". /var/lib/httpd24/scl_enable"


VOLUME ["/opt/rh/httpd24/root/var/www"]
VOLUME ["/var/log/httpd24"]

ENTRYPOINT ["/usr/local/bin/run-httpd24.sh"]
CMD ["httpd", "-DFOREGROUND"]
