Building Cloudera-compatible images with Packer
===============================================

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
     ${CLOUD_LAUNCHER}/src/cloud_launcher.sh --config ../vm/centos6_packer.py insert
     ```

     or, alternatively:

     ```bash
     ${CLOUD_LAUNCHER}/src/cloud_launcher.sh --config ../vm/rhel6_packer.py insert
     ```

1. Create a [SOCKS proxy](../../../../../scripts/util/socks-proxy.md) to connect
   to one of the VMs in your project, such as one of the VMs you've just
   launched.

1. Launch a browser as described in the SOCKS proxy doc and connect to the VM
   which is running Cloudera Manager Server at port `7180`.

1. Log in with the following credentials:

   * username: `admin`
   * password: `admin`

1. Configure and install Cloudera CDH cluster.

1. To delete the VMs once you are done using them, replace the `insert` command
   above with `delete`.
