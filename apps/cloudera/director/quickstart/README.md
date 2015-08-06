Cloudera Director on Google Cloud Platform
==========================================

1. First, create a Google Compute Engine VM instance and install Cloudera
   Director in a single step:

  ```bash
  gcloud compute instances create {{VM}} \
      --project {{PROJECT}} \
      --zone {{ZONE}} \
      --machine-type n1-standard-1 \
      --image centos-6 \
      --metadata startup-script-url=https://git.io/cloudera-director-startup-script
  ```

  where:

  * `{{VM}}` is the name of the VM instance to create, e.g., `cloudera-director`
  * `{{PROJECT}}` is your project name, e.g., `curious-lemming-42`
  * `{{ZONE}}` is a Google Compute Engine zone, e.g., `us-central1-f`
  * the [URL for the startup script](https://git.io/cloudera-director-startup-script)
    points to the raw version of [`director.sh`](director.sh) in this directory

  You can monitor the console of your VM to see when the Cloudera Director is
  ready to accept requests either via the [Developers
  Console](https://cloud.google.com/console) at the following URL:

  ```
  https://console.developers.google.com/project/{{PROJECT}}/compute/instancesDetail/zones/{{ZONE}}/instances/{{VM}}/console#end
  ```

  or via the command-line:

  ```bash
  gcloud compute instances get-serial-port-output {{VM}} \
      --project {{PROJECT}} \
      --zone {{ZONE}}
  ```

2. Once you see the following line in the serial output:

   ```
   Cloudera Director is now ready.
   ```

   you can create a [SOCKS proxy](https://github.com/mbrukman/cloud-launcher/blob/master/howto/secure-connection.md#socks-proxy-over-ssh)
   to establish a secure connection to Cloudera Director on Google Compute
   Engine.

   Then, follow the directions in that howto to configure your web browser to
   use that secure connection to access Cloudera Director and other software
   that will be deployed alongside, such as Cloudera Manager and the Hadoop
   stack.
