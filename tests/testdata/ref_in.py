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
# Sample use case of references in a Python-style config.

from gce import *

GCE.setDefaults(
    project='curious-lemming-42',
    zone='us-central1-a',
)

master = Compute.instance(
    name='vm-master',
    disks=[
        Disk.boot(
            autoDelete=true,
            initializeParams=Disk.initializeParams(
                sourceImage='centos-6-v20140415',
            ),
        ),
    ],
)

workers = [Compute.instance(
    name='vm-worker-%d' % i,
    disks=[
        Disk.boot(
            autoDelete=true,
            initializeParams=Disk.initializeParams(
                sourceImage='centos-6-v20140415',
            ),
        ),
    ],
    metadata=Metadata.create(
        # Note the symbolic reference to `master.name`, defined above.
        items=Metadata.item('master', master.name)
    )
) for i in range(0, 1)]

resources = [master] + workers
