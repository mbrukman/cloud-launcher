import ambari_base
from gce import *

GCE.setDefaults(
    project='curious-lemming-42',
    zone='us-central1-a',
)

resources = ambari_base.AmbariCluster(
    agentInitScript='../scripts/centos6/agent-init.gen.sh',
    serverInitScript='../scripts/centos6/server-init.gen.sh',
    sourceImage='centos-6-latest',
)
