Coopr
=====

Deployment
----------

To deploy Coopr, run:

```sh
$ cd py
$ make insert
```

This will built the startup script and deploy a VM named `coopr` which will
install the Coopr binaries, start the services, and load the default
configurations.

Connect to Coopr UI
-------------------

In a separate terminal, run:

```sh
$ cd py
$ make socks-proxy
```

Follow the instructions in the [SOCKS proxy howto](../../../scripts/util/socks-proxy.md)
to connect to the proxy with your web browser.

Open [http://coopr:8100/](http://coopr:8100/) in the browser which is using the
SOCKS proxy.

Log in to Coopr
---------------

The default login credentials are:

* tenant: `superadmin`
* username: `admin`
* password: `admin`

Delete
------

```sh
$ cd py
$ make delete
```
