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


PROJECT_IMAGES = (
    {
        'project': 'centos-cloud',
        'images': (
            'centos-6-v20140318',
            'centos-6-v20140408',
            'centos-6-v20140415',
            'centos-6-v20140522',
            'centos-6-v20140605',
            'centos-6-v20140606',
            'centos-6-v20140619',
            'centos-6-v20140718',
        ),
        'pseudo': {
            'centos-6-latest': 'centos-6-v20140718',
        },
    },
    {
        # http://coreos.com/docs/running-coreos/cloud-providers/google-compute-engine/
        'project': 'coreos-cloud',
        'images': (
            'coreos-alpha-282-0-0-v20140410',
            'coreos-alpha-298-0-0-v20140425',
            'coreos-alpha-310-1-0-v20140508',
            'coreos-alpha-315-0-0-v20140512',
            'coreos-alpha-317-0-0-v20140515',
            'coreos-alpha-324-1-0-v20140522',
            'coreos-alpha-324-2-0-v20140528',
            'coreos-alpha-324-3-0-v20140530',
            'coreos-alpha-324-4-0-v20140607',
            'coreos-alpha-324-5-0-v20140607',
            'coreos-alpha-338-0-0-v20140604',
            'coreos-alpha-342-0-0-v20140608',
            'coreos-alpha-342-1-0-v20140608',
            'coreos-alpha-343-0-0-v20140609',
            'coreos-alpha-349-0-0-v20140616',
            'coreos-alpha-353-0-0-v20140621',
            'coreos-alpha-361-0-0-v20140627',
            'coreos-alpha-367-0-0-v20140703',
            'coreos-alpha-367-1-0-v20140713',
            'coreos-alpha-379-2-0-v20140715',
            'coreos-alpha-379-3-0-v20140716',
            'coreos-alpha-386-1-0-v20140723',
            'coreos-beta-310-1-0-v20140508',
            'coreos-beta-324-3-0-v20140602',
            'coreos-beta-324-5-0-v20140609',
            'coreos-beta-353-0-0-v20140625',
            'coreos-beta-367-1-0-v20140715',
            'coreos-stable-367-1-0-v20140724',
        ),
        'pseudo': {
            'coreos-alpha-latest': 'coreos-alpha-386-1-0-v20140723',
            'coreos-beta-latest': 'coreos-beta-367-1-0-v20140715',
            'coreos-stable-latest': 'coreos-stable-367-1-0-v20140724',
        },
    },
    {
        'project': 'debian-cloud',
        'images': (
            'backports-debian-7-wheezy-v20140318',
            'backports-debian-7-wheezy-v20140331',
            'backports-debian-7-wheezy-v20140408',
            'backports-debian-7-wheezy-v20140415',
            'backports-debian-7-wheezy-v20140522',
            'backports-debian-7-wheezy-v20140605',
            'backports-debian-7-wheezy-v20140606',
            'backports-debian-7-wheezy-v20140619',
            'backports-debian-7-wheezy-v20140718',
            'debian-7-wheezy-v20140318',
            'debian-7-wheezy-v20140408',
            'debian-7-wheezy-v20140415',
            'debian-7-wheezy-v20140522',
            'debian-7-wheezy-v20140605',
            'debian-7-wheezy-v20140606',
            'debian-7-wheezy-v20140619',
            'debian-7-wheezy-v20140718',
        ),
        'pseudo': {
            'backports-debian-7-wheezy-latest': 'backports-debian-7-wheezy-v20140718',
            'debian-7-wheezy-latest': 'debian-7-wheezy-v20140718',
        },
    },
    {
        # https://developers.google.com/compute/docs/containers
        'project': 'google-containers',
        'images': (
            'container-vm-v20140522',
            'container-vm-v20140624',
            'container-vm-v20140710',
        ),
        'pseudo': {
            'container-vm-latest': 'container-vm-v20140710',
        },
    },
    {
        'project': 'opensuse-cloud',
        'images': (
            'opensuse-13-1-v20140609',
            'opensuse-13-1-v20140627',
            'opensuse-13-1-v20140711',
        ),
        'pseudo': {
            'opensuse-13-1-latest': 'opensuse-13-1-v20140711',
        },
    },
    {
        'project': 'rhel-cloud',
        'images': (
            'rhel-6-v20140718',
            'rhel-6-v20140318',
            'rhel-6-v20140408',
            'rhel-6-v20140415',
            'rhel-6-v20140522',
            'rhel-6-v20140605',
            'rhel-6-v20140606',
            'rhel-6-v20140619',
            'rhel-6-v20140718',
        ),
        'pseudo': {
            'rhel-6-latest': 'rhel-6-v20140718',
        },
    },
    {
        'project': 'suse-cloud',
        'images': (
            'sles-11-sp3-v20140306',
            'sles-11-sp3-v20140609',
            'sles-11-sp3-v20140712',
        ),
        'pseudo': {
            'sles-11-sp3-latest': 'sles-11-sp3-v20140712',
        },
    },
)

def ImageShortNameToUrl(image):
  image_url_fmt = 'https://www.googleapis.com/compute/v1/projects/%(project)s/global/images/%(image)s'

  for pi in PROJECT_IMAGES:
    if image in pi['images']:
      return image_url_fmt % {
          'project': pi['project'],
          'image': image,
      }
    elif ('pseudo' in pi) and (image in pi['pseudo']):
      return image_url_fmt % {
          'project': pi['project'],
          'image': pi['pseudo'][image],
      }

  raise InvalidImageShortName('Unknown short image name: %s' % image)
