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

import json
import os

class InvalidImageShortName(Exception):
  def __init__(self, value):
    self.__value = value

  def __str__(self):
    return repr(self.__value)


PROJECT_IMAGES = None
if PROJECT_IMAGES is None:
  vm_images_path = os.path.join(os.path.dirname(__file__), 'cache', 'vm_images.json')
  with open(vm_images_path, 'r') as vm_images_fd:
    PROJECT_IMAGES = json.loads(vm_images_fd.read())


def ImageShortNameToUrl(image):
  image_url_fmt = 'https://www.googleapis.com/compute/v1/projects/%(project)s/global/images/%(image)s'

  for project, data in PROJECT_IMAGES.iteritems():
    if image in data['images']:
      return image_url_fmt % {
          'project': project,
          'image': image,
      }
    elif ('pseudo' in data) and (image in data['pseudo']):
      return image_url_fmt % {
          'project': project,
          'image': data['pseudo'][image],
      }

  raise InvalidImageShortName('Unknown short image name: %s' % image)
