Note
====

This is a work-in-progress and has not been verified to work yet.


Quick start
===========

In the commands below, `$CLOUD_LAUNCHER` refers to the root directory of this
project.

Then, build the startup scripts for the instances by running the following
command from this directory:

```bash
make -s -C scripts/init
```

To deploy GitLab, run:

```bash
$CLOUD_LAUNCHER/src/cloud_launcher.sh --config py/gitlab.py insert
```

To see other flags, run:

```bash
$CLOUD_LAUNCHER/src/cloud_launcher.sh --help
```

Accessing
---------

Forward the port from localhost over SSH to the Ambari instance:

```bash
env REMOTE_PORT=80 LOCAL_PORT=8080 SERVER=gitlab $CLOUD_LAUNCHER/scripts/util/forward-port.sh
```

Access GitLab via [http://localhost:8080/](http://localhost:8080) to continue
the installation.


Installation
------------

The default login credentials are:

* username: root
* password: 5iveL!fe


Config
------

You can edit `scripts/init/install-gitlab.sh` and change the following line:

```
external_url 'http://gitlab.example.com'
```

to specify the hostname you will deploy GitLab under.
