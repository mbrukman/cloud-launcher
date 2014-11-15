Ambari
======

Deploy on CentOS 6
------------------

Choose one of the modes below for building and launching the cluster.

### Mode A: via pre-built VM images (recommended)

By pre-building the VM images, you do the intial work of downloading the Ambari
agent and server packages once during VM image construction, which speeds up the
installation because Ambari is available as soon as the VM boots.

Thus, whether you're bringing up 5 or 500 instances, it will be much faster to
start the cluster or add new nodes. To use this mode of installation, follow the
instructions in the [`packer`](packer/) directory.

### Mode B: via dynamically-built VM images

In this mode of installation, the VM boots and executes a script to download and
install Ambari agent and server packages, along with their prerequisites (such
as Java), so while there is no upfront work, the time to get to a working Ambari
cluster is longer than in the prebuilt VM image approach above.

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

The agent hostname pattern is:

```
ambari-agent-[0-4].c.${PROJECT}.internal
```

Adjust this pattern as needed, e.g., change the `4` to _N-1_ where _N_ is the
number of agent instances in your deployment.

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
