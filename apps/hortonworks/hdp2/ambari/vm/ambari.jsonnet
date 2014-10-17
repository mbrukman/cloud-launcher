// Copyright 2014 Google Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////
//
// Ambari server + agent deployment.

local gce = import "../../../../../src/gce.jsonnet";

{
    zone:: "us-central1-b",
    serverMachineTypeName:: "n1-standard-1",
    agentMachineTypeName:: "n1-standard-4",
    numAgents:: 5,

    server:: gce.Instance { 
        name: "ambari-server",
        machineTypeName:: $.serverMachineTypeName,
        zoneName:: $.zone,
        metadataMap:: {
            "startup-script": gce.StripComments(std.join("\n", [
                importstr "../scripts/init/ambari-repo-init.sh",
                importstr "../scripts/init/ambari-server-install.sh",
                importstr "../scripts/init/ambari-server-setup.sh",
                importstr "../scripts/init/ambari-server-start.sh",
            ])), 
        },
        disks: [
            gce.BootDisk {
                owner:: $.server,
                image:: gce.MakeUrl(["centos-cloud", "global", "images", "centos-6-v20140415"])
            }
        ],
    },

    agent(i):: gce.Instance {
        local agent = self,
        name: "ambari-agent-%d" % [i],
        machineTypeName:: $.agentMachineTypeName,
        zoneName:: $.zone,
        metadataMap:: {
            "ambari-server": "ambari-server",
            "startup-script": gce.StripComments(std.join("\n",[
                importstr "../../../../common/fdisk.sh",
                importstr "../scripts/init/ambari-repo-init.sh",
                importstr "../scripts/init/ambari-agent-install.sh",
                importstr "../scripts/init/ambari-agent-setup.sh",
                importstr "../scripts/init/ambari-agent-start.sh",
            ])),
        },
        disks: [ $.server.disks[0] + { owner:: agent, sizeGb:: 500, } ],
    },

    resources: [$.server] + [ $.agent(i) for i in std.range(0, $.numAgents - 1) ]
}
