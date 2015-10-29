# Deploying Cloudera Director with Puppet

First, use `gcloud` (part of [Google Cloud SDK](https://cloud.google.com/sdk/))
to login and get credentials:

```bash
gcloud auth login
```

Then, set the default Google Cloud Platform project:

```bash
gcloud config set project {{PROJECT}}
```

Puppet will implicitly use this project to deploy, because it actually runs
`gcloud` commands under the covers to create and delete VM instances.

```bash
make apply CONFIG=centos6.pp
```

This will download the Puppet GCE integration module, build the startup script,
and bring up the VM. You can edit parameters such as `zone` and `machine_type`
in the file.

To deploy on RHEL 6, use the `rhel6.pp` file instead.

To delete the instance, modify the config as follows:

```diff
- ensure => present,
+ ensure => absent,
```

and rerun the `make apply` command above.
