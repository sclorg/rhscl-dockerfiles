FROM openshift/base-rhel7

# This image provides a Ruby 2.0 environment you can use to run your Ruby
# applications.

EXPOSE 8080

ENV RUBY_VERSION 2.0

LABEL io.k8s.description="Platform for building and running Ruby 2.0 applications" \
      io.k8s.display-name="Ruby 2.0" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,ruby,ruby20"

# Labels consumed by Red Hat build service
LABEL BZComponent="openshift-sti-ruby-docker" \
      Name="openshift3/ruby-20-rhel7" \
      Version="2.0" \
      Release="2" \
      Architecture="x86_64"

RUN yum install -y --setopt=tsflags=nodocs ruby200 ruby200-ruby-devel ruby200-rubygem-rake v8314 ror40-rubygem-bundler nodejs010 && \
    yum clean all -y

# Copy the S2I scripts from the specific language image to $STI_SCRIPTS_PATH
COPY ./s2i/bin/ $STI_SCRIPTS_PATH

# Each language image can have 'contrib' a directory with extra files needed to
# run and build the applications.
COPY ./contrib/ /opt/app-root

RUN chown -R 1001:0 /opt/app-root

USER 1001

# Set the default CMD to print the usage of the language image
CMD $STI_SCRIPTS_PATH/usage
