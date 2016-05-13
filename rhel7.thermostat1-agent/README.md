Thermostat Agent Docker image
=============================

This repository contains Dockerfiles for a Thermostat Agent running in privileged mode
so that Java applications in other containers can be monitored.

Environment variables
---------------------------------

The image recognizes the following environment variables that you can set during
initialization by passing `-e VAR=VALUE` to the Docker run command.

|    Variable name              |    Description                              |
| :---------------------------- | -----------------------------------------   |
|  `THERMOSTAT_AGENT_USERNAME`  | User name for the Thermostat agent to use connecting to storage |
|  `THERMOSTAT_AGENT_PASSWORD`  | Password for connecting to storage          |
|  `THERMOSTAT_CMDC_PORT`       | The port to bind the command channel to     |
|  `THERMOSTAT_CMDC_ADDR`       | The address to bind the command channel to  |
|  `THERMOSTAT_DB_URL`          | The URL for Thermostat storage              |


Usage
---------------------------------

For this, we will assume that you are using the `rhscl/thermostat1-agent-rhel7` image.
If you want to set only the mandatory environment variables, connect to Thermostat
storage exposed via `http://example.com/thermostat/storage` and other containers
running Java apps expose their Hotspot performance data to `/docker/tmp` then execute
the following command:

```
$ docker run -d --privileged --pid host --net host \
                -e THERMOSTAT_AGENT_USERNAME=user -e THERMOSTAT_AGENT_PASSWORD=password \
                -e THERMOSTAT_CMDC_PORT=12000 -e THERMOSTAT_CMDC_ADDR=192.168.0.1 \
                -e THERMOSTAT_DB_URL=http://example.com/thermostat/storage \
                --name thermostat1-agent \
                -v /docker/tmp:/tmp rhscl_beta/thermostat-1-agent-rhel7
```

Usage for Running Java Applications being Monitored in Separate Containers
--------------------------------------------------------------------------

In order for Java applications to be properly monitored by the super privileged
Agent Docker image, containers with Java applications need to:

1. Expose `/tmp/hsperfdata_*` to host's `/docker/tmp` (via -v `/docker/tmp:/tmp`)
2. Mount the volume exposed by the Thermostat agent image. This is necessary so
   that the Thermostat built-in JVM agent for profiling Java apps will be available
   to the container running the Java application.
3. Share the host's network stack. This is needed so that JMX connections work
   cross-container.
4. Share the host's PID space. This is necessary since `hsperfdata_*` is closely
   tied to the PIDs being created for Java applications.

Given that we want to run a Java application using image `hello-world-webapp` and
we'd want this application to get monitored by an instance of the  `thermostat1-agent`
image the application needs to get started using Docker like so:

```
$ docker run -d --pid host \
                --net host \
                --volumes-from=thermostat1-agent \
                --name hello-world \
                -v /docker/tmp:/tmp hello-world-webapp
```
