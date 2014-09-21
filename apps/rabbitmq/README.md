RabbitMQ
========

Debian 7
--------

First, build the startup script:

```bash
make -s -C ../scripts/debian7/latest
```

Optionally, modify parameters in [`vm/debian7.py`](vm/debian7.py); see
[`vm/rabbitmq_base.py`](vm/rabbitmq_base.py) for available parameters.

Then, deploy the RabbitMQ cluster:

```bash
$CLOUD_LAUNCHER/src/cloud_launcher.sh --config vm/debian7.py insert
```
