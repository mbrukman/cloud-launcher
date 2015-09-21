# Deploy a VM with Docker

See below for how to deploy a Docker-capable VM with a given OS distribution.

Once you have deployed a VM with a particular OS, you can connect to it via SSH
using either the Google Developers Console, or by using [`gcloud compute
ssh`](https://cloud.google.com/sdk/gcloud/reference/compute/ssh).

The name of the VM instance is specified in a configuration file in this
directory, whose name is `<name-of-config>.py`.

## CentOS 7

    make CONFIG=centos-7 insert

## Delete a VM

For any given VM configuration, replace the `insert` command with `delete` to
delete the VM.
