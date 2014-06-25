Deploy
======

Install the [Google APIs Client Library for Python](https://developers.google.com/api-client-library/python/).

Build the startup scripts for the instances:

```bash
make -s -C scripts/init
```

From the top-level project directory, run:

```bash
./run.sh insert
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
env SERVER=ambari-server-0 ./scripts/util/forward-port.sh
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
