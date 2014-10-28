import ambari_base
from gce import *

GCE.setDefaults(
    project='curious-lemming-42',
    zone='us-central1-a',
)

resources = ambari_base.AmbariCluster(
    numAgents=5,
    sourceImage='centos6-ambari',
    agentInitScript='../scripts/centos6/packer-agent-init.gen.sh',
    serverInitScript='../scripts/centos6/packer-server-init.gen.sh',
)
