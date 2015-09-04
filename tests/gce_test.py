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
# Tests handling of GCE constructors.

import unittest

# Local imports
import gce

GCE = gce.GCE


class GceDefaultsTest(unittest.TestCase):

    def setUp(self):
        self.__project = 'myproject'
        self.__zone = 'myzone'

        GCE.default = GCE.Settings()
        GCE.current = GCE.Settings()

        self.assertDefaultProjectZoneAreNone()
        self.assertCurrentProjectZoneAreNone()

    def assertDefaultProjectZoneAreNone(self):
        self.assertIsNone(GCE.default.project)
        self.assertIsNone(GCE.default.zone)

    def assertCurrentProjectZoneAreNone(self):
        self.assertIsNone(GCE.current.project)
        self.assertIsNone(GCE.current.zone)

    def assertProjectZoneAreNone(self):
        self.assertIsNone(GCE.project())
        self.assertIsNone(GCE.zone())

    def testGlobalDefaults(self):
        self.assertDefaultProjectZoneAreNone()
        self.assertProjectZoneAreNone()

        GCE.setDefaults(self.__project)

        self.assertEqual(self.__project, GCE.default.project)
        self.assertEqual(self.__project, GCE.project())

        self.assertIsNone(GCE.default.zone)
        self.assertIsNone(GCE.zone())

        GCE.setDefaults(zone=self.__zone)

        self.assertEqual(self.__zone, GCE.default.zone)
        self.assertEqual(self.__zone, GCE.zone())

    def testClearCurrent(self):
        self.assertCurrentProjectZoneAreNone()

        GCE.setDefaults(self.__project, self.__zone)

        self.assertEqual(self.__project, GCE.project())
        self.assertEqual(self.__zone, GCE.zone())

        GCE.clearCurrent()

        self.assertCurrentProjectZoneAreNone()

    def testCurrentOverridesDefault(self):
        GCE.setDefaults(self.__project, self.__zone)

        self.assertEqual(self.__project, GCE.project())
        self.assertEqual(self.__zone, GCE.zone())

        project2 = 'project2'
        zone2 = 'zone2'

        self.assertNotEqual(project2, GCE.project())
        self.assertNotEqual(zone2, GCE.zone())

        GCE.setCurrent(project2, zone2)

        self.assertEqual(project2, GCE.project())
        self.assertEqual(zone2, GCE.zone())

        GCE.clearCurrent()

        self.assertEqual(self.__project, GCE.project())
        self.assertEqual(self.__zone, GCE.zone())


if __name__ == '__main__':
    unittest.main()
