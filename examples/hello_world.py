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
# An example deployment.

from gce import Compute, Disk, Metadata

hello = Compute.instance(
    name='hello-world',
    machineType='f1-micro',
    disks=[
        Disk.boot(
            autoDelete=true,
            initializeParams=Disk.initializeParams(
                sourceImage='centos-6-latest',
            ),
        ),
    ],
    metadata=Metadata.create(
        items=[
            Metadata.item('greeting', 'hello'),
        ],
    ),
)

resources = [hello]
