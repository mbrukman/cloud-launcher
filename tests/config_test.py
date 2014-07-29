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
# Tests handling of VM images (e.g., shortnames).

import glob
import json
import os
import unittest

# Local imports
import config_yaml


class ConfigExpanderTest(unittest.TestCase):

  def testAllFiles(self):
    in_yaml = glob.glob(os.path.join('testdata', '*.in.yaml'))
    for input_file in in_yaml:
      expected = input_file.replace('in.yaml', 'out.json')
      with open(expected) as expected_in:
        expected_json = json.loads(expected_in.read(), encoding='utf-8')

      expander = config_yaml.ConfigExpander(project='dummy-project', zone='dummy-zone')
      actual_json = expander.ExpandFile(input_file)

      self.assertEqual(expected_json, actual_json)


if __name__ == '__main__':
  unittest.main()
