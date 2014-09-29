Deploy
======

First, build the startup scripts for the instances by running the following
command from this directory:

```bash
make -s -C scripts/init
```

To deploy Ambari, run the following command from the top-level directory:

```bash
src/cloud_launcher.sh --config apps/hortonworks/hdp2/centos6/vm/ambari.py insert
```

To see other flags, run:

```bash
src/cloud_launcher.sh --help
```

Accessing Ambari
----------------

* run a [local SOCKS proxy](../../../../scripts/util/socks-proxy.md) and configure
  your browser to use it

* open [http://ambari-server:8080/](http://ambari-server:8080) to continue the
  installation and monitor the cluster once installed

You will be able to access any of the hosts in your deployment via your browser
directly while you are using the SOCKS proxy as described in the instructions.

Installation
------------

The default login credentials are:

* username: admin
* password: admin

These can be changed after you set up the cluster.

The agent hostname pattern:

```
ambari-agent-[0-4].c.${PROJECT}.internal
```

adjust this pattern as needed, e.g., change the '4' to N-1 where N is the number
of agent instances in your deployment.
