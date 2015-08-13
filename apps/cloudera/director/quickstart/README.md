Cloudera Director on Google Cloud Platform
==========================================

Installing Cloudera Director on Google Compute Engine VM
--------------------------------------------------------

1. First, create a Google Compute Engine VM instance and install Cloudera
   Director in a single step:

  ```bash
  gcloud compute instances create {{VM}} \
      --project {{PROJECT}} \
      --zone {{ZONE}} \
      --machine-type n1-standard-1 \
      --scopes compute-rw \
      --image centos-6 \
      --metadata-from-file startup-script=director.sh
  ```

  where:

  * `{{VM}}` is the name of the VM instance to create, e.g., `cloudera-director`
  * `{{PROJECT}}` is your
    [project id](https://cloud.google.com/storage/docs/projects?hl=en#projectid),
    e.g., `curious-lemming-42`
  * `{{ZONE}}` is a Google Compute Engine zone, e.g., `us-central1-f`
  * the [`director.sh`](director.sh) script is located in this directory

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

Manual installation
-------------------

To manually install Cloudera Director, you can follow the steps in the
[director.sh](director.sh) script for a CentOS 6 base image, or see [these
instructions](http://www.cloudera.com/content/cloudera/en/documentation/cloudera-director/latest/topics/director_install_server.html)
for other supported operating systems.

Using Cloudera Director to deploy Hadoop clusters
-------------------------------------------------

If you are running Cloudera Director on a Google Compute Engine VM instance
within the same Google Cloud Platform project that will contain your Cloudera
clusters, you can have the plugin automatically retrieve credentials from the
environment. You simply need to ensure that the instance was created with
[Read-write access to Compute Engine methods](https://cloud.google.com/compute/docs/authentication)
 enabled, which is done via `--scopes compute-rw` in the `gcloud` command
above.

If you are running Cloudera Director outside of Google Compute Engine, or in a
different Google Cloud Platform project, you will need to obtain a JSON key:

* Point your browser at your [Google Developers Console](https://console.developers.google.com/).
* Navigate to: Projects -> {your-project-name} -> APIs & auth -> APIs
* Enable the Google Compute Engine API.
* Navigate to: Projects -> {your-project-name} -> APIs & auth -> Credentials.
* Select Add credentials -> Service account
* Ensure "JSON" option is enabled.
* Click "Create" button.
* Dismiss "New public/private key pair" popup with "OK" button.
* Note the location of your newly-downloaded .json file.

You will need to upload this JSON file to Director to enable it to authenticate
with Google Compute Engine for that project.
