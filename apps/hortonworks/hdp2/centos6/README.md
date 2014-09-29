Deploy
======

First, build the startup scripts for the instances by running the following
command from this directory:

```bash
make -s -C scripts/init
```

To deploy Ambari, run the following command:

```bash
${CLOUD_LAUNCHER}/src/cloud_launcher.sh --config vm/ambari.py insert
```

To see other flags, run:

```bash
${CLOUD_LAUNCHER}/src/cloud_launcher.sh --help
```

where `${CLOUD_LAUNCHER}` points to the root of this repo.

Accessing Ambari
----------------

* run a [local SOCKS proxy](../../../../scripts/util/socks-proxy.md) and configure
  your browser to use it, e.g.,

  ```bash
  ${CLOUD_LAUNCHER}/scripts/util/socks-proxy.sh --server ambari-server
  ```

  to use the default port and the project and zone as configured in
  `${CLOUD_LAUNCHER}/src/settings.sh`

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

Select "Perform manual registration on hosts and do not use SSH" and continue.
