Deploy
======

First, build the startup scripts for the instances by running the following
command from this directory:

```bash
make -s -C scripts/init
```

To deploy Ambari, run the following command from the top-level directory:

```bash
./run.sh --config apps/hortonworks/hdp2/centos6/ambari.py insert
```

To see other flags, run:

```bash
./run.sh --help
```

Accessing Ambari
----------------

Forward the port from localhost over SSH to the Ambari instance. From the
top-level project directory, run:

```bash
env SERVER=ambari-server ./scripts/util/forward-port.sh
```

See the script for how to change local or remote ports.

Access Ambari via [http://localhost:8080/](http://localhost:8080) to continue
the installation.

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
