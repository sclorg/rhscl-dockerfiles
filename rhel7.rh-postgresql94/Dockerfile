FROM rhel7
MAINTAINER docker@softwarecollections.org  
RUN yum update -y && yum clean all
RUN yum install yum-utils -y && yum clean all
RUN yum-config-manager --enable rhel-server-rhscl-7-rpms
RUN yum-config-manager --enable rhel-7-server-optional-rpms
RUN yum install -y --setopt=tsflags=nodocs rh-postgresql94 && yum clean all

EXPOSE 5432

ADD ./enablerh-postgresql94.sh /etc/profile.d/
