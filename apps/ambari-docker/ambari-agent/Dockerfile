FROM ambari-common

MAINTAINER Misha Brukman

# Automatically start Ambari agent.
RUN chkconfig ambari-agent on

ADD rootfs/root/ambari-agent-setup.sh
          /root/ambari-agent-setup.sh

ADD rootfs/root/ambari-agent-run.sh
          /root/ambari-agent-run.sh

# Setup Ambari Agent and restart it to pick up the config changes.
ENTRYPOINT /root/ambari-agent-run.sh
