from gce import *
import rabbitmq_base

GCE.setDefaults(
    project='curious-lemming-42',
    zone='us-central1-a',
)

resources = rabbitmq_base.RabbitMQ_Cluster(
    sourceImage='backports-debian-7-wheezy-latest',
    startupScript='../scripts/debian7/latest/rabbitmq.gen.sh',
)
