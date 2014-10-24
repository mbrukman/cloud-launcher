Building Ambari images with Packer
==================================

[Packer](http://packer.io) can be used to build and customize GCE VM images
to preinstall Ambari agent and server packages once so that it does not have to
be redone for every agent and server deployment.

Instructions
------------

1. Install [Packer](https://github.com/mitchellh/packer) from source

1. Build the necessary shell scripts to be used for building images and
   deploying Ambari later:

   ```bash
   make -s -C ../scripts/centos6
   ```

1. Update variables in `ambari.yaml` as necessary. In particular, you **must**
   set the Google Cloud Storage bucket to the name of a bucket you own, because
   these are globally-unique names.

   Consider creating a bucket with the same name as your project, e.g.,
   `curious-lemming-42` as that is easy to correlate to a project and is likely
   to not be already taken.

1. Build the images using Packer:

   ```bash
   make build
   ```

1. Deploy Ambari with `../vm/centos6_packer.py`:

  1. First, update the agent and server image names if you've changed them in
     the `ambari.yaml` or `Makefile` in the `packer` directory

  1. Then, deploy Ambari:

     ```bash
     ${CLOUD_LAUNCHER}/src/cloud_launcher.sh --config ../vm/centos6_packer.py insert
     ```
