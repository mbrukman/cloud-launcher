#!/usr/bin/python
#
# Copyright 2015 Google Inc.
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

# Standard library imports
import unittest

# Google imports
import os
import sys

# Try using $GOOGLE_CLOUD_SDK as the root installation.
_GOOGLE_CLOUD_SDK = None

# First try using $HOME/google-cloud-sdk as the install dir.
_HOME_GOOGLE_CLOUD_SDK = '%s/google-cloud-sdk' % os.environ['HOME']
if os.path.exists(_HOME_GOOGLE_CLOUD_SDK):
    _GOOGLE_CLOUD_SDK = _HOME_GOOGLE_CLOUD_SDK

# If there's an env var pointing directly to Google Cloud SDK installation dir,
# us that (overrides $HOME/google-cloud-sdk).
if ('GOOGLE_CLOUD_SDK' in os.environ and
    os.path.isdir(os.environ['GOOGLE_CLOUD_SDK'])):
    _GOOGLE_CLOUD_SDK = os.environ['GOOGLE_CLOUD_SDK']

_APPENGINE = '%s/platform/google_appengine' % _GOOGLE_CLOUD_SDK

sys.path.insert(1, _APPENGINE)
sys.path.insert(1, '%s/lib/yaml/lib' % _APPENGINE)
sys.path.insert(1, 'third_party/python')

import appengine_config
from google.appengine.ext import testbed

# Local imports
import httpretty


class RequestHandlersTest(unittest.TestCase):
    def setUp(self):
        super(RequestHandlersTest, self).setUp()
        # For more info, see:
        # https://cloud.google.com/appengine/docs/python/tools/localunittesting
        self.testbed = testbed.Testbed()
        self.testbed.activate()
        self.testbed.init_memcache_stub()
        # For more info, see: https://github.com/gabrielfalcao/HTTPretty
        httpretty.enable()

        # If we import this module at the global scope before we stub out
        # memcache, the code breaks because it runs immediately and the
        # decorator isn't able to use memcache at load time due to the missing
        # API stub. By loading it after stubbing out memcache, it works.
        import compute_api_base
        self.compute_api_base = compute_api_base

    def tearDown(self):
        httpretty.disable()
        httpretty.reset()
        self.testbed.deactivate()

    def testUserAgent(self):
        mockContent = 'This is some content'
        httpretty.register_uri(httpretty.GET, 'http://localhost:9000/',
                               body=mockContent)
        http = self.compute_api_base.Http()
        (resp_headers, content) = http.request("http://localhost:9000", "GET")
        self.assertEqual(httpretty.last_request().headers['user-agent'],
                         self.compute_api_base.USER_AGENT)
        self.assertEqual(content, mockContent)


if __name__ == '__main__':
    unittest.main()
