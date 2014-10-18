Ambari
======

Deploy on CentOS 6
------------------

1. build the init scripts

  ```bash
  make -s -C scripts/centos6
  ```

1. launch the cluster

  ```bash
  ${CLOUD_LAUNCHER}/src/cloud_launcher.sh --config vm/centos6.py insert
  ```

Accessing Ambari
----------------

1. run a [local SOCKS proxy](../../../../scripts/util/socks-proxy.md), e.g.,

   ```bash
   ${CLOUD_LAUNCHER}/scripts/util/socks-proxy.sh --server ambari-server
   ```

   to use the default port (`9000`) and the project and zone as configured in
   `${CLOUD_LAUNCHER}/src/settings.sh`. Run:

   ```bash
   ${CLOUD_LAUNCHER}/scripts/util/socks-proxy.sh --help
   ```

   to see the available flags that you can use to customize the proxy.

1. configure your browser to use the proxy;
   see instructions for
   [Chrome](../../../../scripts/util/socks-proxy.md#chrome) and
   [Firefox](../../../../scripts/util/socks-proxy.md#firefox)

1. open [http://ambari-server:8080/](http://ambari-server:8080) to continue the
   installation and monitor the cluster once installed

You will be able to access any of the hosts in your deployment via your browser
directly while you are using the SOCKS proxy as described in the instructions.

Installation
------------

The default login credentials are:

* username: `admin`
* password: `admin`

These can be changed after you set up the cluster.

The agent hostname pattern:

```
ambari-agent-[0-4].c.${PROJECT}.internal
```

adjust this pattern as needed, e.g., change the '4' to N-1 where N is the number
of agent instances in your deployment.

Select "Perform manual registration on hosts and do not use SSH" and continue.

Deleting the deployment
-----------------------

Once you're done working with your cluster, you can remove it entirely with a
single command:

```bash
${CLOUD_LAUNCHER}/src/cloud_launcher.sh --config vm/centos6.py delete
```

Note that this procedure is irreversible; please be sure to save any data
produced to a durable storage medium, such as Google Cloud Storage, before
destroying the cluster.
