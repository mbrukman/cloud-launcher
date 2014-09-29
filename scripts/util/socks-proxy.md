Setting up a SOCKS proxy
========================

To connect to a number of different hosts in your cloud deployment, the easiest
way is to change your browser to do the lookups directly from your network in
the cloud. This lets you use the short name of the hosts instead of looking up
each host's IP address, opening up ports for each service, or creating an SSH
tunnel for each (host, port) pair.

Overview
--------

The approach we use here is as follows:

1. set up a single SSH tunnel to one of the hosts on the network, and create a
   SOCKS proxy on that host

1. change the browser configuration to do all the lookups via that SOCKS proxy
   host

Note that since you're tunneling *all* traffic via that host, you don't want to
browse the web in general using that browser or that specific profile, as you
will be using your cloud host's bandwidth for this.

In general, you might want to use a separate browser for this, or create a
separate profile and switch to it when necessary.

Common setup
------------

If you have already modified `$CLOUD_LAUNCHER/src/settings.sh` to launch your
application using Cloud Launcher, you can proceed simply as follows:

```bash
$CLOUD_LAUNCHER/scripts/util/socks-proxy.sh --server "<vm-instance>"
```

If you haven't, or if you would like to connect to a host in a different project
or zone, specify them explicitly:

```bash
$CLOUD_LAUNCHER/scripts/util/socks-proxy.sh \
    --project "<project"> --zone "<zone>" \
    --server "<vm-instance>"
```

The script will print out necessary information for the config below, including
the default port; you can override it with: `--port <port>` on the command line.

Chrome
------

Chrome uses system-wide proxy settings by default, so we need to specify a
different proxy using command-line flags. Launching Chrome by default creates an
instance of an already-running profile, so to enable us to run multiple copies
of Chrome simultaneously, one which is using the proxy and others which are not,
we need a new profile.

First, create a directory to hold the profile, e.g.:

```bash
mkdir $HOME/chrome-proxy-profile
```

Then, launch Chrome using this directory as the profile:

* Linux

  ```bash
  /usr/bin/google-chrome \
      --user-data-dir="$HOME/chrome-proxy-profile" \
      --proxy-server="socks5://localhost:9000"
  ```

* Mac OS X:

  ```bash
  "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
      --user-data-dir="$HOME/chrome-proxy-profile" \
      --proxy-server="socks5://localhost:9000"
  ```

Be sure to modify the proxy port if you've changed from the default `9000`.

Firefox
-------

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
     as provided in the output of the script when it starts up

  1. choose "SOCKS v5"

  1. check the box "Remove DNS"

  1. leave all other entries blank

1. press "OK" and close the Preferences dialog box
