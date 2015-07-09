FROM centos:centos7

MAINTAINER docker@softwarecollections.org

RUN yum -y --setopt=tsflags=nodocs install https://www.softwarecollections.org/en/scls/rhscl/mongodb24/epel-7-x86_64/download/rhscl-mongodb24-epel-7-x86_64.noarch.rpm && \
    yum clean all

RUN yum install -y --setopt=tsflags=nodocs mongodb24 mongodb24-mongodb && yum clean all


EXPOSE 27017
EXPOSE 28017

ENV	MONGODB_VERSION=2.4 \
	HOME=/var/lib/mongodb \
	BASH_ENV=/etc/profile.d/cont-env.sh

LABEL	openshift.io/tags="database,mongodb,mongodb24"  \
	k8s.io/display-name="MongoDB 2.4"  \
	openshift.io/expose-services="27017:mongodb"  \
	k8s.io/description="MongoDB is a scalable, high-performance, open source NoSQL database." 

ADD ./.bashrc $HOME/.bashrc
ADD ./cont-mongod /usr/bin/cont-mongod
ADD ./cont-mongos /usr/bin/cont-mongos
ADD ./mongod.conf /etc/mongod.conf
ADD ./mongos.conf /etc/mongos.conf
ADD ./init-users.sh /usr/share/cont-layer/mongodb/init.d/init-users.sh
ADD ./base-functions.sh /usr/share/cont-layer/mongodb/common/base-functions.sh
ADD ./enablemongodb24.sh /usr/share/cont-layer/common/env/enablemongodb24.sh
ADD ./usr /usr
ADD ./etc /etc
ADD ./root /root

RUN	mkdir -p /var/lib/mongodb/data /var/run/mongodb && \
	chown -R mongodb:mongodb /var/lib/mongodb/ /var/run/mongodb /etc/mongod.conf /etc/mongos.conf && \
	restorecon -R /var/lib/mongodb/ && \
	:

USER 184

VOLUME /var/lib/mongodb/data

ENTRYPOINT ["/usr/bin/container-entrypoint"]

CMD ["cont-mongod"]

