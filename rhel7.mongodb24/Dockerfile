FROM rhel7-local-test

MAINTAINER docker@softwarecollections.org

#RUN yum update -y && yum install -y yum-utils && \
#    yum-config-manager --enable rhel-server-rhscl-7-rpms && \
#    yum-config-manager --enable rhel-7-server-optional-rpms && \
#    yum clean all

RUN yum install -y --setopt=tsflags=nodocs mongodb24 mongodb24-mongodb && yum clean all


EXPOSE 27017
EXPOSE 28017
ENV HOME            /var/lib/mongodb
ENV BASH_ENV        /etc/profile.d/cont-env.sh
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

USER mongodb

VOLUME /var/lib/mongodb/data

CMD ["cont-mongod"]

