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
################################################################################
#
# Common functionality to be shared across various types of config handlers.


def ProjectUrl(project):
  return 'https://www.googleapis.com/compute/%(api_version)s/projects/%(project)s' % {
      'api_version': 'v1',
      'project': project,
  }

def ProjectZoneUrl(project, zone):
  return '%(project_url)s/zones/%(zone)s' % {
      'project_url': ProjectUrl(project),
      'zone': zone,
  }

def ProjectGlobalUrl(project):
  return '%(project_url)s/global' % {
      'project_url': ProjectUrl(project),
  }

def MachineTypeToUrl(project, zone, machineType):
  return '%(zone_url)s/machineTypes/%(machineType)s' % {
      'zone_url': ProjectZoneUrl(project, zone),
      'machineType': machineType,
  }

def NetworkToUrl(project, network):
  return '%(project_url)s/networks/%(network)s' % {
      'project_url': ProjectGlobalUrl(project),
      'network': network,
  }
