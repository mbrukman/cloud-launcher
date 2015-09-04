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
# Test Python config -> JSON conversion.

import glob
import json
import os
import unittest

# Local imports
import config_py


class ConfigExpanderTest(unittest.TestCase):

    def assertDictEqual(self, expected, actual):
        """A better version for our use case than the default assertDictEqual().

        The default version shows the diff as a long single-line string, which makes
        finding differences very difficult. This version identifies the specific
        key(s) which differ and their values.
        """
        equal = True
        for key in actual:
            if key not in expected:
                print 'Not found in expected: %s' % key
                equal = False

        for key in expected:
            if key not in actual:
                print 'Not found in actual: %s' % key
                equal = False
            elif expected[key] != actual[key]:
                print ('Unequal for key: %s\n'
                       '       expected: %s\n'
                       '         actual: %s\n') % (key, expected[key], actual[key])
                equal = False

        self.assertTrue(equal, 'Differences found')

    def testAllFiles(self):
        in_yaml = glob.glob(os.path.join('testdata', '*_in.py'))
        for input_file in in_yaml:
            expected = input_file.replace('_in.py', '_out.json')
            with open(expected) as expected_in:
                expected_json = json.loads(expected_in.read())

            # TODO(mbrukman): make sure that the locally-specified config in the *.py
            # files overrides the settings provided here; right now, it's not
            # the case.
            expander = config_py.ConfigExpander(
                project='curious-lemming-42', zone='dummy-zone')
            actual_json = expander.ExpandFile(input_file)

            self.assertEqual(len(expected_json), len(actual_json))
            for idx, expected_obj in enumerate(expected_json):
                self.assertDictEqual(expected_obj, actual_json[idx])


if __name__ == '__main__':
    unittest.main()
