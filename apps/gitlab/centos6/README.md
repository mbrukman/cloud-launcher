Quick start
===========

Then, build the startup scripts for the instances by running the following
command from this directory:

```bash
make -s -C scripts/init
```

To deploy GitLab, run the following command from the top-level directory:

```bash
src/cloud_launcher.sh --config apps/gitlab/centos6/vm/gitlab.py insert
```

To see other flags, run:

```bash
src/cloud_launcher.sh --help
```

Accessing
---------

Forward the port from localhost over SSH to the Ambari instance. From the
top-level project directory, run:

```bash
env REMOTE_PORT=80 LOCAL_PORT=8080 SERVER=gitlab ./scripts/util/forward-port.sh
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
