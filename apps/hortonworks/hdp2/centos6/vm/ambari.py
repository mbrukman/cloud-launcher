# Copyright 2014 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
################################################################################
#
# Ambari server + agent deployment.

GCE.setDefaults(
    project='curious-lemming-42',
    zone='us-central1-a',
)

server = Compute.instance(
    name='ambari-server',
    machineType='n1-standard-1',
    disks=[
      Disk.boot(
        autoDelete=true,
        initializeParams=Disk.initializeParams(
          sourceImage='centos-6-v20140415',
        ),
      ),
    ],
    metadata=Metadata.create(
      items=[
        Metadata.startupScript('../scripts/init/ambari-server-init.gen.sh'),
      ],
    ),
  )

agents = [Compute.instance(
    name='ambari-agent-%d' % i,
    machineType='n1-standard-4',
    disks=[
      Disk.boot(
        autoDelete=true,
        initializeParams=Disk.initializeParams(
          sourceImage='centos-6-v20140415',
          diskSizeGb=500,
        ),
      ),
    ],
    metadata=Metadata.create(
      items=[
        Metadata.item('ambari-server', server.name),
        Metadata.startupScript('../scripts/init/ambari-agent-init.gen.sh'),
      ],
    ),
  ) for i in range(0, 5)
]

resources = [server] + agents
