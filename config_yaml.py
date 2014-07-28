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
# Config processing and expansion.

import copy
import json
import os
import sys
import yaml

# Local imports
import common
import vm_images


class ConfigExpander(object):

  def __init__(self, **kwargs):
    self.__kwargs = {}
    for key, value in kwargs.iteritems():
      self.__kwargs[key] = value

  def __ZoneUrl(self):
    return common.ProjectZoneUrl(self.__kwargs['project'], self.__kwargs['zone'])

  def __MachineTypeToUrl(self, machineType):
    return common.MachineTypeToUrl(
        self.__kwargs['project'], self.__kwargs['zone'], machineType)

  def __NetworkToUrl(self, network):
    # TODO(mbrukman): make this an auto-generated globally-unique name?
    return common.NetworkToUrl(self.__kwargs['project'], network)

  def __ZoneToUrl(self, zone):
    return common.ProjectZoneUrl(self.__kwargs['project'], zone)

  def ExpandFile(self, file_name):
    with open(file_name) as input_yaml:
      config = yaml.safe_load(input_yaml)

    # Expand the configuration.
    # * convert numReplicas > 1 into multiple specs
    # * convert machineType from a short name to a URL
    # * convert network from a short name to a URL
    # * convert sourceImage from name to URL
    # * convert zone from a name to a URL
    # * read files if specified in startupScript

    expanded_config = []
    for instance in config:
      if 'machineType' in instance:
        machineType = instance['machineType']
        if not common.IsUrl(machineType):
          instance['machineType'] = self.__MachineTypeToUrl(machineType)

      if 'metadata' in instance:
        metadata = instance['metadata']
        if 'items' in metadata:
          items = metadata['items']
          for item in items:
            if item['value'].startswith('%file'):
              item['value'] = common.ReadReferencedFileToString(
                  file_name, item['value'])

      if 'networkInterfaces' in instance:
        networkInterfaces = instance['networkInterfaces']
        for networkIntf in networkInterfaces:
          network_name = networkIntf['network']
        if not common.IsUrl(network_name):
          networkIntf['network'] = self.__NetworkToUrl(network_name)

      if 'zone' in instance:
        zone = instance['zone']
        if not common.IsUrl(zone):
          instance['zone'] = self.__ZoneToUrl(zone)
      else:
        instance['zone'] = self.__ZoneUrl()

      if 'disks' in instance:
        for disk in instance['disks']:
          if 'initializeParams' in disk:
            initializeParams = disk['initializeParams']

            # Translate sourceImage base name -> URL, if not already a URL.
            if 'sourceImage' in initializeParams:
              sourceImage = initializeParams['sourceImage']
              if not common.IsUrl(sourceImage):
                disk['initializeParams']['sourceImage'] = vm_images.ImageShortNameToUrl(sourceImage)

    # convert numReplicas > 1 into multiple specs, updating the config
    for instance in config:
      numReplicas = 1
      if 'numReplicas' in instance:
        numReplicas = instance['numReplicas']
        del instance['numReplicas']

      for replicaId in range(0, numReplicas):
        replica_copy = copy.deepcopy(instance)

        # Allow the user to have some string substitutions in the name.
        replica_copy['name'] = replica_copy['name'] % {
            'env_user': os.getenv('USER'),
        }
        # Update the name to '<instance-name>-<replica-id>'.
        replica_copy['name'] = '%s-%d' % (replica_copy['name'], replicaId)

        # Update the PD name to '<instance-name>-<replica-id>-disk-<disk-id>'.
        if 'disks' in replica_copy:
          disks = replica_copy['disks']
          for diskId, disk in enumerate(replica_copy['disks']):
            if 'initializeParams' in disk:
              initializeParams = disk['initializeParams']
              if 'diskName' not in initializeParams:
                initializeParams['diskName'] = '%s-disk-%d' % (replica_copy['name'], diskId)

            if 'source' in disk:
              source = disk['source']
              if not common.IsUrl(source):
                # Find the right zone for the disk, with fallbacks in the following order:
                # * specified for the disk explicitly
                # * specified for the instance explicitly
                # * specified as a flag to this process
                zone = None
                if 'zone' in disk:
                  zone = disk['zone']
                elif 'zone' in replica_copy:
                  zone = replica_copy['zone']
                else:
                  zone = self.__kwargs['zone']

                # Convert zone name to URL, if necessary.
                if common.IsUrl(zone):
                  zone_url = zone
                else:
                  zone_url = self.__ZoneToUrl(zone)

                source_url = '%(zone_url)s/disks/%(disk)s' % {
                    'zone_url': zone_url,
                    'disk': source,
                }
                source_url = source_url % {
                    'instance_name': replica_copy['name'],
                }
                disk['source'] = source_url

            if 'deviceName' not in disk:
              disk['deviceName'] = 'disk-%d' % diskId

        expanded_config.append(replica_copy)

    return expanded_config


def main(argv):
  if len(argv) < 2:
    sys.stderr.write('Missing YAML file as argument\n')
    sys.exit(1)

  expander = ConfigExpander(project='dummy-project', zone='dummy-zone')
  config = expander.ExpandFile(argv[1])
  print json.dumps(config, indent=2, separators=(',', ': '))


if __name__ == '__main__':
  main(sys.argv)
