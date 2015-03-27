FROM rhel6
MAINTAINER docker@softwarecollections.org
RUN yum update -y && yum clean all
RUN yum install -y yum-utils && yum clean all
RUN yum-config-manager --enable rhel-server-rhscl-6-rpms
RUN yum-config-manager --enable rhel-6-server-optional-rpms
RUN yum install -y --setopt=tsflags=nodocs rh-passenger40 rh-passenger40-ruby22 && yum clean all

ADD ./enablerh-passenger40.sh /etc/profile.d/
