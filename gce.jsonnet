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
// GCE utility classes

{
    local proj = std.env("GCP_PROJECT"),
    local gce = self,

    StripComments(str)::
        local lines = std.split(str, "\n");
        local keep_line(line) =
            local aux(line, i) =
                local c = line[i];
                if i >= std.length(line) then
                    true
                else if c == " " || c == "\t" then
                    local i2 = i+1;
                    if std.force(i2) then
                        aux(line, i2)
                    else
                        null
                else 
                    c != "#" || (i + 1 < std.length(line) && line[i + 1] == "!");
            aux(line, 0);
        local no_comments = std.filter(keep_line, lines);
        std.join("\n", no_comments),

    MakeUrl(parts)::
        local base = "https://www.googleapis.com/compute/v1/projects";
        std.join("/", [base] + parts),

    Instance:: {
        local instance = self,
        project:: proj,
        zone: gce.MakeUrl([proj, "zones", self.zoneName]),
        machineType: "%s/machineTypes/%s" % [self.zone, self.machineTypeName],
        metadata: {
            items:
                local m = instance.metadataMap;
                [ { key: k, value: m[k] } for k in std.objectFields(m) ]
        },
        networkInterfaces: [
            {
                accessConfigs: [
                    {
                        name: "External NAT",
                        type: "ONE_TO_ONE_NAT"
                    }
                ],
                network: gce.MakeUrl([proj, "global", "networks", "default"]),
            }
        ],
        serviceAccounts: [
            {
                email: "default",
                scopes: [
                    "https://www.googleapis.com/auth/devstorage.full_control",
                    "https://www.googleapis.com/auth/compute"
                ]
            }
        ],
    },

    BootDisk:: {
        local disk = self,
        autoDelete: true,
        boot: true,
        deviceName: "disk-0",
        sizeGb:: 10,
        initializeParams: {
            diskName: "%s-disk-0" % [disk.owner.name],
            sourceImage: disk.image,
            diskSizeGb: disk.sizeGb,
        },
        mode: "READ_WRITE",
        type: "PERSISTENT",
    }
}
