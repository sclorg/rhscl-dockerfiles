FROM openshift3/sti-base

# This image provides a Ruby 2.2 environment you can use to run your Ruby
# applications.

EXPOSE 8080

ENV RUBY_VERSION 2.2

LABEL io.k8s.description="Platform for building and running Ruby 2.2 applications" \
      io.k8s.display-name="Ruby 2.2" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,ruby,ruby22"

# Labels consumed by Red Hat build service
LABEL BZComponent="rh-ruby22-docker" \
      Name="rhscl/ruby-22-rhel7" \
      Version="2.2" \
      Release="6" \
      Architecture="x86_64"

RUN yum-config-manager --enable rhel-server-rhscl-7-rpms && \
    yum-config-manager --enable rhel-7-server-optional-rpms && \
    yum install -y --setopt=tsflags=nodocs rh-ruby22 rh-ruby22-ruby-devel rh-ruby22-rubygem-rake v8314 rh-ruby22-rubygem-bundler nodejs010 && \
    yum clean all -y

# Copy the STI scripts from the specific language image to /usr/local/sti
COPY ./s2i/bin/ /usr/local/sti

# Each language image can have 'contrib' a directory with extra files needed to
# run and build the applications.
COPY ./contrib/ /opt/app-root

RUN chown -R 1001:1001 /opt/app-root

USER 1001

# Set the default CMD to print the usage of the language image
CMD ["usage"]
