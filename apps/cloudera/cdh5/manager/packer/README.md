Building Cloudera images with Packer
====================================

[Packer](http://packer.io) can be used to build custom GCE VM images
to enable automated Cloudera Manager Server installation.

Instructions
------------

Note: in the text below, `${CLOUD_LAUNCHER}` refers to the full path of the
top-level directory of this project when you clone the repo; this would
typically be `cloud-launcher`.

1. Install [Packer](https://github.com/mitchellh/packer) from source

1. Create the `account.json` file as described in the
   [Packer GCE builder docs](https://www.packer.io/docs/builders/googlecompute.html).

   Note that this is only necessary if you're not running on a GCE VM with
   `compute` and `devstorage_fullcontrol` scopes.

1. Modify `settings.mk` with your choice of project and zone.

1. Make sure you've also followed the directions in the
   [top-level README.md](../../../../../README.md) of this project;
   in particular:

   * modify `${CLOUD_LAUNCHER}/src/settings.sh` similarly to how you
     modified `settings.mk` with your choice of project and zone and
   * add the credentials to enable creating and deleting Google Cloud Platform
     resources.

1. Build the images using Packer:

   ```bash
   make OS=centos-6 build
   ```

   or, alternatively:

   ```bash
   make OS=rhel-6 build
   ```

   Support for other distributions is in-progress.

1. Deploy VM images with Cloudera Manager pre-installed via:

  1. First, update the agent and server image names if you've changed them in
     the `manager.yaml` or `Makefile` in the `packer` directory

  1. Then, deploy:

     ```bash
     # Uses ../vm/centos6_packer.py as the config file; change options there.
     make OS=centos-6 vm-deploy
     ```

     or, alternatively:

     ```bash
     # Uses ../vm/rhel6_packer.py as the config file; change options there.
     make OS=rhel-6 vm-deploy
     ```

1. Create a [SOCKS proxy](../../../../../scripts/util/socks-proxy.md) to connect
   to one of the VMs in your project, such as one of the VMs you've just
   launched.

1. Launch a browser as described in the SOCKS proxy doc and connect to the VM
   which is running Cloudera Manager Server on port `7180`.

1. Log in with the following credentials:

   * username: `admin`
   * password: `admin`

1. Configure and install Cloudera CDH cluster.

   The available hosts depend on the configuration file being used; by default,
   you should specify `cdh-[0-5]`.

   Note that all VMs support the following credentials for SSH and passwordless
   `sudo` access:

   * username: `cloudera`
   * password: `cloudera`

   This is configured in
   [`../scripts/common/cloudera-user.sh`](../scripts/common/cloudera-user.sh).

1. To delete the VMs once you are done using them, replace the `vm-deploy`
   make target above with `delete`:

   ```bash
   make OS=centos-6 vm-delete
   ```

   or, alternatively:

   ```bash
   make OS=rhel-6 vm-delete
   ```
