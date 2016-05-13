FROM rhscl/s2i-base-rhel7:1

# RHSCL httpd24 image.
#
# Volumes:
#  * /opt/rh/httpd24/root/var/www - Datastore for httpd
#  * /var/log/httpd24 - Storage for logs when $HTTPD_LOG_TO_VOLUME is set
# Environment:
#  * $HTTPD_LOG_TO_VOLUME (optional) - When set, httpd will log into /var/log/httpd24

# Labels consumed by Red Hat build service
LABEL io.k8s.description="Platform for running httpd or building httpd-based application" \
      io.k8s.display-name="httpd 2.4.18" \
      io.openshift.expose-services="8080:http" \
      io.openshift.expose-services="8443:https" \
      io.openshift.tags="builder,httpd,httpd24" \
      Component="httpd24-docker" \
      Name="rhscl_beta/httpd-24-rhel7" \
      Version="2.4" \
      Release="28" \
      BZComponent="httpd24-docker" \
      Architecture="x86_64"


EXPOSE 80
EXPOSE 443
EXPOSE 8080
EXPOSE 8443

ENV HTTPD_CONFIGURATION_PATH=/opt/app-root/etc/httpd.d

COPY run-*.sh /usr/local/bin/
RUN mkdir -p /var/lib/httpd24
COPY ./contrib/ /var/lib/httpd24/
COPY ./s2i/bin/ $STI_SCRIPTS_PATH
COPY ./contrib/ /opt/app-root

RUN yum install -y yum-utils gettext hostname && \
    yum-config-manager --enable rhel-server-rhscl-7-rpms && \
    yum-config-manager --enable rhel-7-server-optional-rpms && \
    yum-config-manager --enable rhel-7-server-ose-3.0-rpms && \
    yum install -y --setopt=tsflags=nodocs nss_wrapper && \
    yum install -y --setopt=tsflags=nodocs bind-utils httpd24 httpd24-mod_ssl && \
    yum clean all

# When bash is started non-interactively, to run a shell script, for example it
# looks for this variable and source the content of this file. This will enable
# the SCL for all scripts without need to do 'scl enable'.
ENV BASH_ENV=/var/lib/httpd24/scl_enable \
    ENV=/var/lib/httpd24/scl_enable \
    PROMPT_COMMAND=". /var/lib/httpd24/scl_enable"

RUN mkdir -p /opt/app-root/etc/httpd.d && \
    chmod -R a+rwx /opt/rh/httpd24/root/etc/httpd/conf && \
    chmod -R a+rwx /opt/rh/httpd24/root/etc/httpd/conf.d && \
    chmod -R a+r   /etc/pki/tls/certs/localhost.crt && \
    chmod -R a+r   /etc/pki/tls/private/localhost.key && \
    chmod -R a+rwx /opt/app-root/etc && \
    chmod -R a+rwx /opt/rh/httpd24/root/var/run/httpd && \
    chown -R 1001:0 /opt/app-root

VOLUME ["/opt/rh/httpd24/root/var/www"]
VOLUME ["/var/log/httpd24"]

# USER 1001

ENTRYPOINT ["/usr/local/bin/run-httpd24.sh"]
CMD ["httpd", "-DFOREGROUND"]
