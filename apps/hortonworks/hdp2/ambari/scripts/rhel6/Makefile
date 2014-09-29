COMMON = ../common

include ../common/common.mk

# RHEL reuses the repo and install commands from CentOS 6.
repo-init.sh: ../centos6/repo-init.sh
	@ cp -f $< $@

agent-install.sh: ../centos6/agent-install.sh
	@ cp -f $< $@

server-install.sh: ../centos6/server-install.sh
	@ cp -f $< $@
