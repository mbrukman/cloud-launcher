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
# Handles VM images (e.g., shortnames) for simplifying config specification.

class InvalidImageShortName(Exception):
  def __init__(self, value):
    self.__value = value

  def __str__(self):
    return repr(self.__value)


_PROJECT_IMAGES = (
    {
        'project': 'centos-cloud',
        'images': (
            'centos-6-v20140318',
            'centos-6-v20140408',
            'centos-6-v20140415',
        ),
    },
    {
        # http://coreos.com/docs/running-coreos/cloud-providers/google-compute-engine/
        'project': 'coreos-cloud',
        'images': (
            'coreos-beta-310-1-0-v20140508',
            'coreos-alpha-324-1-0-v20140522',
        ),
    },
    {
        'project': 'debian-cloud',
        'images': (
            'debian-7-wheezy-v20140318',
            'debian-7-wheezy-v20140408',
            'debian-7-wheezy-v20140415',
        ),
    },
    {
        # https://developers.google.com/compute/docs/containers
        'project': 'google-containers',
        'images': (
            'container-vm-v20140522',
        ),
    },
    {
        'project': 'rhel-cloud',
        'images': (
            'rhel-6-v20140415',
        ),
    },
    {
        'project': 'suse-cloud',
        'images': (
            'sles-11-sp3-v20140306',
        ),
    },
)

def ImageShortNameToUrl(image):
  image_url_fmt = 'https://www.googleapis.com/compute/v1/projects/%(project)s/global/images/%(image)s'

  for pi in _PROJECT_IMAGES:
    if image in pi['images']:
      return image_url_fmt % {
          'project': pi['project'],
          'image': image,
      }

  raise InvalidImageShortName('Unknown short image name: %s' % image)
