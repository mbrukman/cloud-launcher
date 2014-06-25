Overview
========

Scripts for handling persistent disks on GCE (creating, attaching, deleting).

Usage
-----

Run all the commands from the root directory of the project.

Create, attach, and mount large disks to each instance:

```bash
scripts/disk/disk_ctl.sh create      # will affect all ambari-agent-* instances
scripts/disk/disk_ctl.sh attach      # will affect all ambari-agent-* instances
```

Now, mount them all:

```bash
scripts/disk/disk_util.sh push_all   # will copy the script to each instance
scripts/disk/disk_util.sh mount_all  # will mount each disk on each instance
```
