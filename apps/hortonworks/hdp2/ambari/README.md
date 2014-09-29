Ambari
======

**NOTE:** this directory is a work-in-progress for a modular installation of Ambari for
different OS distributions.

To try it out on CentOS 6:

1. build the init scripts

  ```bash
  make -s -C scripts/centos6
  ```

1. launch the cluster

  ```bash
  ${CLOUD_LAUNCHER}/src/cloud_launcher.sh --config vm/centos6.py insert
  ```

1. continue with the [other instructions](../centos6/)
   to use a SOCKS proxy, configure Ambari, and install Hadoop cluster
