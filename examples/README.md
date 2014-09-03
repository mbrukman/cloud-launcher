Examples
========

Before trying any of the examples, follow the setup procedures in the
[top-level README](../README.md).

How to run
----------

Once you have properly set up your environment, from this directory, run:

```bash
../src/cloud_launcher.sh --config hello_world.py list
```

to see what instances will be created. Then, launch them with:

```bash
../src/cloud_launcher.sh --config hello_world.py insert
```

You can go to the [Google Developer Console](https://cloud.google.com/console)
to monitor your deployment, SSH to your instance to manage it, install packages,
etc.

Finally, clean up your deployment:

```bash
../src/cloud_launcher.sh --config hello_world.py delete
```

That's it! Now you can try running one of the
[available applications](../apps/README.md) or configure and deploy your own.
