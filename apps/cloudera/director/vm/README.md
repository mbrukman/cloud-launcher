# Cloudera Director

By default, instructions below will deploy a VM with CentOS. To use RHEL
instead, add `OS=rhel-6` to the `make` command line.

To deploy Cloudera Director on Google Compute Engine, do the following:

```sh
make create-vm
```

Then, if you want to create a port-forwarding server, use:

```sh
make port-fwd
```

and connect to http://localhost:7189/ . Alternatively, if you want to use the
SOCKS proxy, run:

```sh
make socks-proxy
```

and then open a browser configured to use the proxy. If you have Google Chrome
installed, you can run:

```sh
make chrome-with-proxy
```

to run a new instance of Google Chrome with a separate profile which will
connect to the proxy. If you have not modified the name of the VM instance
(defaults to `cloudera-director`), Chrome will automatically open the landing
page for Cloudera Director at http://cloudera-director:7189/ .

To delete the VM instance, run:

```sh
make delete-vm
```
