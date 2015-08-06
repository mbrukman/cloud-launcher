# Securely connecting to Google Compute Engine

When running a web service on a publicly-accessible machine such as a Google
Compute Engine VM with an external IP, it's important to not send or receive sensitive
information from the server in plain text, such as via plain HTTP.

Sensitive information could include information such as login credentials,
commands to create or destroy resources or files, or even logs or output of
processes running on the VM.

In other words, the entire communication between your host and the deployed VM
should be over a secure, encrypted connection.

There are several options to enable secure communication between your desktop or
laptop and a VM running on Google Compute Engine:

* [Port forwarding over SSH](#port-forwarding-over-ssh)
* [SOCKS proxy over SSH](#socks-proxy-over-ssh)
* [HTTPS and SSL](#https-and-ssl)
* [VPN](#vpn)

HTTPS/SSL and VPN are both advanced topics; users are encouraged to explore port
forwarding or SOCKS proxy approaches first as they are easier and require little
to no setup or configuration.

## Port forwarding over SSH

To forward a single port from your desktop to a VM on Google Compute Engine, you
can use the `gcloud` command to start a server on a given local port which will
forward all traffic to a remote host over an SSH connection.

To use this, first ensure that you know what VM instance and port are providing
the service you would like to connect to securely. Then, run the command:

```bash
gcloud compute ssh ${VM} \
    --project ${PROJECT} \
    --zone ${ZONE} \
    --ssh-flag="-L ${LOCAL_PORT}:localhost:${REMOTE_PORT}"
```

where:

* `${VM}` is the name of the instance you would like to connect to
* `${PROJECT}` is your Google Cloud Platform project
* `${ZONE}` is the zone your VM is running in
* `${LOCAL_PORT}` is the port you would like to listen on locally
* `${REMOTE_PORT}` is the port on the server you would like to connect to

For example, let's assume that `${LOCAL_PORT}` is 2222 and `${REMOTE_PORT}` is
8888. That means that if you open http://localhost:2222/ in your browser, the
HTTP connection will go over the SSH tunnel you have just created over to your
remote host and connect to the host identified as `${VM}` via SSH and then
connect to port 8888 on the same machine, but over an encrypted, secure SSH
connection.

The `gcloud` command will create and maintain an SSH connection, and this
approach will only work while it is active. As soon as you exit the SSH session
that `gcloud` creates, http://localhost:2222/ will stop working.

If you want to create more than one port forwarding rule, you can either specify
them on a single command line by repeating the flags, e.g.,

```bash
gcloud compute ssh ${VM} \
    --project ${PROJECT} \
    --zone ${ZONE} \
    --ssh-flag="-L ${LOCAL_PORT_1}:localhost:${REMOTE_PORT_1}" \
    --ssh-flag="-L ${LOCAL_PORT_2}:localhost:${REMOTE_PORT_2}"
```

or run a new `gcloud` command each time to create a separate tunnel. Note that
you can't add or remove port forwarding from an existing connection without
exiting and re-establishing the connection from scratch.

## SOCKS proxy over SSH

To connect to a number of different hosts in your cloud deployment, the easiest
way is to change your browser to do the lookups directly from your network in
the cloud. This lets you use the short name of the hosts instead of looking up
each host's IP address, opening up ports for each service, or creating an SSH
tunnel for each (host, port) pair.

### Overview

The approach we use here is as follows:

1. set up a single SSH tunnel to one of the hosts on the network, and create a
   SOCKS proxy on that host

1. change the browser configuration to do all the lookups via that SOCKS proxy
   host

Note that since you're tunneling *all* traffic via that host, you don't want to
browse the web in general using that browser or that specific profile, as you
will be using your cloud host's bandwidth for this.

In general, you might want to use a separate browser profile and switch to it
when necessary.

### Start the SOCKS proxy

```bash
gcloud compute ssh {{VM}} \
    --project {{PROJECT}} \
    --zone {{ZONE}} \
    --ssh-flag="-D" \
    --ssh-flag="{{PORT}}" \
    --ssh-flag="-N"
```

where:

* `{{VM}}` is the name of the instance you would like to connect to
* `{{PROJECT}}` is your Google Cloud Platform project
* `{{ZONE}}` is the zone your VM is running in
* `{{PORT}}` is the port you would like to listen on locally on `localhost`

Note that in this case, you don't need to specify a remote port, because a SOCKS
proxy does not bind to any specific remote port: any connection you make via the
SOCKS proxy will be resolved relative to the host you connect to.

This means that you will be able to connect to any other VM on the same network
as the `{{VM}}` you connected to just by using its short name, and you will be
able to connect to any port on those VMs.

This approach is much more flexible than the simple port-forwarding method, but
will also require you to change the settings in your web browser to utilize the
proxy.

Next, configure your browser to use the proxy.

### Chrome setup for SOCKS proxy

Chrome uses system-wide proxy settings by default, so we need to specify a
different proxy using command-line flags. Launching Chrome by default creates an
instance of an already-running profile, so to enable us to run multiple copies
of Chrome simultaneously, one which is using the proxy and others which are not,
we need a new profile.

Here's how to launch Chrome using a new directory as the profile (Chrome will
create the directory if it doesn't already exist):

* Linux

  ```bash
  /usr/bin/google-chrome \
      --user-data-dir="$HOME/chrome-proxy-profile" \
      --proxy-server="socks5://localhost:{{PORT}}"
  ```

* Mac OS X:

  ```bash
  "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
      --user-data-dir="$HOME/chrome-proxy-profile" \
      --proxy-server="socks5://localhost:{{PORT}}"
  ```

* Windows:

  ```
  "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" \
      --user-data-dir="%USERPROFILE%\chrome-proxy-profile" \
      --proxy-server="socks5://localhost:{{PORT}}"
  ```

Be sure to set `{{PORT}}` to the same value that you used in the `gcloud`
command earlier.

### Firefox setup for SOCKS proxy

Before changing these settings, you may want to
[create a new Firefox profile](https://support.mozilla.org/en-US/kb/profile-manager-create-and-remove-firefox-profiles).
Otherwise, it will affect all instances of Firefox to use that host as a proxy,
which is very likely not what you want.

Once you have Firefox running with a separate profile, you can set up the SOCKS
proxy:

1. open Preferences

1. under the "Network" tab, in the "Connections" section, click on "Settings"

1. choose the option "Manual proxy configuration"

  1. in the "SOCKS Host" section, fill in `localhost` as the host and the port
     you selected when you ran the `gcloud` command earlier

  1. choose "SOCKS v5"

  1. check the box "Remove DNS"

  1. leave all other entries blank

1. press "OK" and close the Preferences dialog box

## HTTPS and SSL

This is an advanced topic which requires the user to do the following:

* register a domain name
* acquire an SSL certificate
* create Google Compute Engine VMs and register them with DNS, e.g., by using
  Google Cloud DNS
* run a web server or reverse proxy, install the SSL certificate and configure
  SSL
* forward specific URLs from the web server to the custom HTTP service, or proxy
  transparently to backends

If you have set up SSL-serving domains before, it should be straightforward to
do the same with Google Compute Engine. If you are new to this, consider using
one of the alternative methods above instead, namely
[port-forwarding](#port-forwarding-over-ssh) or
[SOCKS proxy](#socks-proxy-over-ssh).

## VPN

For details on setting up, configuring, and using VPN with Google Compute
Engine, please refer to the
[Google Cloud VPN](https://cloud.google.com/compute/docs/vpn) documentation.
