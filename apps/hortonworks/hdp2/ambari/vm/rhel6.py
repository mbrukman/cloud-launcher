import ambari_base
from gce import *

GCE.setDefaults(
    project='curious-lemming-42',
    zone='us-central1-a',
)

resources = ambari_base.AmbariCluster(
    agentInitScript='../scripts/rhel6/agent-init.gen.sh',
    serverInitScript='../scripts/rhel6/server-init.gen.sh',
    sourceImage='rhel-6-latest',
)
