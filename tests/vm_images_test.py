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
# Tests handling of VM images (e.g., shortnames).

import json
import os
import unittest

# Local imports
import vm_images


class ImageShortNameToUrlTest(unittest.TestCase):

    def projectImageToUrl(self, project, image):
        url_fmt = 'https://www.googleapis.com/compute/v1/projects/%(project)s/global/images/%(image)s'
        return url_fmt % {
            'project': project,
            'image': image,
        }

    def testDirectReferenceImages(self):
        for project, data in vm_images.PROJECT_IMAGES.iteritems():
            for image in data['images']:
                self.assertEqual(
                    self.projectImageToUrl(project, image),
                    vm_images.ImageShortNameToUrl(image))

    def testPseudoImages(self):
        for project, data in vm_images.PROJECT_IMAGES.iteritems():
            if not 'pseudo' in data:
                continue
            for pseudo in data['pseudo']:
                self.assertEqual(
                    self.projectImageToUrl(project, data['pseudo'][pseudo]),
                    vm_images.ImageShortNameToUrl(pseudo))

    def testInvalid(self):
        self.assertRaises(
            vm_images.InvalidImageShortName,
            vm_images.ImageShortNameToUrl,
            'some-unknown-image')


if __name__ == '__main__':
    unittest.main()
