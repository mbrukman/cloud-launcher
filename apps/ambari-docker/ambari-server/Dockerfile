FROM ambari-common

MAINTAINER Misha Brukman

# Setup Ambari server, silently accepting all default options.
RUN ambari-server setup -s

# Start Ambari server.
RUN chkconfig ambari-server on
RUN ambari-server start

# Expose standard ports for the Ambari server.
EXPOSE 8080 8440 8441
