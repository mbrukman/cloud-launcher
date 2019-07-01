# http://wiki.centos.org/Cloud/Docker
FROM centos:centos6

MAINTAINER Misha Brukman

# Add the Hortonworks repository to download Ambari.
#
# Downloaded from:
# http://public-repo-1.hortonworks.com/AMBARI-1.x/repos/centos6/ambari.repo
ADD rootfs/etc/yum.repos.d/ambari.repo \
          /etc/yum.repos.d/ambari.repo

RUN yum --quiet -y install epel-release
RUN yum --quiet -y install ambari-agent
RUN yum --quiet -y install ambari-server
