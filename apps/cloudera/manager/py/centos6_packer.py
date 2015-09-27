#!/usr/bin/python
#
# Copyright 2015 Google Inc.
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
# Deployment for Cloudera Manager Server + Agent cluster using custom CentOS 6
# images built using Packer.
#
##########################################################################

import manager_base
from gce import *

GCE.setDefaults(
    project='curious-lemmings-42',
    zone='us-central1-a',
)

resources = manager_base.ClouderaCluster(
    numAgents=5,
    sourceImage='centos-6-v20141218-cloudera',
    agentInitScript='../scripts/centos-6/path-a/packer-agent-start.gen.sh',
    serverInitScript='../scripts/centos-6/path-a/packer-server-start.gen.sh',
)
