#!/usr/bin/python
#
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
##########################################################################
#
# Sample use case of the constructors in resources.py .

from gce import GCE, Compute, Disk, Metadata

GCE.setDefaults(
    project='curious-lemming-42',
    zone='us-central1-a',
)

resources = [
    Compute.instance(
        name='vm-%d' % i,
        disks=[
            Disk.boot(
                autoDelete=true,
                initializeParams=Disk.initializeParams(
                    sourceImage='centos-6-v20140415',
                ),
            ),
        ],
        metadata=Metadata.create(
            items=[Metadata.startupScript('startup-script.sh')],
        ),
    ) for i in range(0, 3)
]
