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
import vm_images


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

class ConfigExpander(object):

  def __init__(self, **kwargs):
    self.__kwargs = {}
    for key, value in kwargs.iteritems():
      self.__kwargs[key] = value

  def __ZoneUrl(self):
    return ProjectZoneUrl(self.__kwargs['project'], self.__kwargs['zone'])

  def __MachineTypeToUrl(self, instance_name):
    return '%(zone_url)s/machineTypes/%(instance_name)s' % {
        'zone_url': self.__ZoneUrl(),
        'instance_name': instance_name,
    }

  def __NetworkToUrl(self, network):
    # TODO(mbrukman): make this an auto-generated globally-unique name?
    return '%(project_url)s/networks/%(network)s' % {
        'project_url': ProjectGlobalUrl(self.__kwargs['project']),
        'network': network,
    }

  def __ZoneToUrl(self, zone):
    return ProjectZoneUrl(self.__kwargs['project'], zone)

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
        if not (machineType.startswith('http://') or
                machineType.startswith('https://')):
          instance['machineType'] = self.__MachineTypeToUrl(machineType)

      if 'metadata' in instance:
        metadata = instance['metadata']
        if 'items' in metadata:
          items = metadata['items']
          for item in items:
            if item['value'].startswith('%file'):
              # Find the sourced file relative to the config file.
              file_path = os.path.join(os.path.dirname(file_name), item['value'][6:])
              if not os.path.exists(file_path):
                sys.stderr.write('Error: startup script "%s" not found.\n' %
                                 file_path)
                sys.exit(1)

              with open(file_path) as file_input:
                file_contents = file_input.read()
                # The limit for startup scripts sent via metadata is 35000 chars:
                #
                #   "If your startup script is less than 35000 bytes, you could choose
                #   to pass in your startup script as pure metadata, [...]"
                #
                # https://developers.google.com/compute/docs/howtos/startupscript#example
                if len(file_contents) >= 35000:
                  # TODO(mbrukman): write an automatic push-to-CloudStore to make
                  # this easy for the user.
                  sys.stderr.write('Startup script too large (%d); must be < 35000 chars; '
                                   'please use "startup-script-url" instead.')
                  sys.exit(1)
                item['value'] = file_contents

      if 'networkInterfaces' in instance:
        networkInterfaces = instance['networkInterfaces']
        for networkIntf in networkInterfaces:
          network_name = networkIntf['network']
        if not (network_name.startswith('http://') or
                network_name.startswith('https://')):
          networkIntf['network'] = self.__NetworkToUrl(network_name)

      if 'zone' in instance:
        zone = instance['zone']
        if not (zone.startswith('http://') or
                zone.startswith('https://')):
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
              if not (sourceImage.startswith('http://') or
                      sourceImage.startswith('https://')):
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
              if not (source.startswith('http://') or
                      source.startswith('https://')):
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
                if (zone.startswith('http://') or
                    zone.startswith('https://')):
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
