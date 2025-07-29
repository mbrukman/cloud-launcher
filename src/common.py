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
# Common functionality to be shared across various types of config handlers.

import os
import sys


def project_url(project):
    return 'https://www.googleapis.com/compute/%(api_version)s/projects/%(project)s' % {
        'api_version': 'v1',
        'project': project,
    }


def project_zone_url(project, zone):
    return '%(project_url)s/zones/%(zone)s' % {
        'project_url': project_url(project),
        'zone': zone,
    }


def project_global_url(project):
    return '%(project_url)s/global' % {
        'project_url': project_url(project),
    }


def disk_type_to_url(project, zone, diskType):
    assert diskType in ('pd-standard', 'pd-ssd')
    return '%(zone_url)s/diskTypes/%(diskType)s' % {
        'zone_url': project_zone_url(project, zone),
        'diskType': diskType,
    }


def image_to_url(project, image):
    return '%(project_url)s/images/%(image)s' % {
        'project_url': project_global_url(project),
        'image': image,
    }


def machine_type_to_url(project, zone, machineType):
    return '%(zone_url)s/machineTypes/%(machineType)s' % {
        'zone_url': project_zone_url(project, zone),
        'machineType': machineType,
    }


def network_to_url(project, network):
    return '%(project_url)s/networks/%(network)s' % {
        'project_url': project_global_url(project),
        'network': network,
    }


def is_url(string):
    return (string.startswith('http://') or
            string.startswith('https://'))


def read_referenced_file_to_string(base_file, referenced_file):
    """Given a string '%file:<path>'; returns the contents of file at <path>.

    Args:
      base_file (string): the file doing the referencing
      referenced_file (string): target file being referenced; must start with
          '%file:<...>'

    Returns:
      string (contents of the referenced file)
    """
    # Find the sourced file relative to the config file.
    file_path = os.path.join(os.path.dirname(base_file), referenced_file[6:])
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
        return file_contents
