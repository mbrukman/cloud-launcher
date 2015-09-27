# Deploy a VM with Docker

See below for how to deploy a Docker-capable VM with a given OS distribution.

Once you have deployed a VM with a particular OS, you can connect to it via SSH
using either the Google Developers Console, or by using [`gcloud compute
ssh`](https://cloud.google.com/sdk/gcloud/reference/compute/ssh).

The name of the VM instance is specified in a configuration file in this
directory, whose name is `<name-of-config>.py`.

For any given VM configuration, to delete the instance, replace the `insert`
command with `delete`.

## CentOS 7

    make OS=centos-7 insert

## Ubuntu 14.04

    make OS=ubuntu-1404 insert

## Ubuntu 15.04

    make OS=ubuntu-1504 insert
