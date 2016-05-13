FROM rhel:7.2-released
# Thermostat Agent Image.
#
# Volumes:
#  * /opt/rh/thermostat1/root/usr/share/thermostat
# Environment:
#  * $THERMOSTAT_CMDC_PORT      - The command channel listen port.
#  * $THERMOSTAT_CMDC_ADDR      - The command channel listen address.
#  * $THERMOSTAT_AGENT_USERNAME - User name for the thermostat agent to use
#                                 for connecting to storage.
#  * $THERMOSTAT_AGENT_PASSWORD - Password for the thermostat agent to use
#                                 for connecting to storage.
#  * $THERMOSTAT_DB_URL         - The storage URL to connect to.

ENV THERMOSTAT_VERSION=1.4 \
    HOME=/root

LABEL io.k8s.description="A monitoring and serviceability tool for OpenJDK." \
      io.k8s.display-name="Thermostat Agent 1.4"

# Labels consumed by Red Hat build service
LABEL BZComponent="thermostat1-agent-docker" \
      Name="rhscl/thermostat-1-agent-rhel7" \
      Version="1.4" \ 
      Release="8" \
      Architecture="x86_64"

ENV THERMOSTAT_CMDC_ADDR 127.0.0.1
ENV THERMOSTAT_CMDC_PORT 12000
ENV THERMOSTAT_DB_URL http://127.0.0.1:8999/thermostat/storage
ENV THERMOSTAT_HOME /opt/rh/thermostat1/root/usr/share/thermostat
ENV USER_THERMOSTAT_HOME /root/.thermostat

EXPOSE $THERMOSTAT_CMDC_PORT

RUN yum install -y yum-utils && \
    yum-config-manager --enable rhel-server-rhscl-7-rpms && \
    yum-config-manager --enable rhel-7-server-optional-rpms && \
    yum install -y --setopt=tsflags=nodocs thermostat1 && \
    yum erase -y java-1.8.0-openjdk-headless && \
    yum clean all
COPY thermostat-user-home-config ${USER_THERMOSTAT_HOME}
ADD root /

# Get prefix path and path to scripts rather than hard-code them in scripts
ENV CONTAINER_SCRIPTS_PATH=/usr/share/container-scripts/thermostat \
    ENABLED_COLLECTIONS=thermostat1

# When bash is started non-interactively, to run a shell script, for example it
# looks for this variable and source the content of this file. This will enable
# the SCL for all scripts without need to do 'scl enable'.
ENV BASH_ENV=${CONTAINER_SCRIPTS_PATH}/scl_enable \
    ENV=${CONTAINER_SCRIPTS_PATH}/scl_enable \
    PROMPT_COMMAND=". ${CONTAINER_SCRIPTS_PATH}/scl_enable"

VOLUME ${THERMOSTAT_HOME}

WORKDIR ${THERMOSTAT_HOME}

ENTRYPOINT ["container-entrypoint"]
CMD [ "run-thermostat-agent" ]
