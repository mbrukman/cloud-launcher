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
"""Base classes and functions for the generated Compute API module."""

# Standard Python libraries.
import json

# Libraries we added to `third_party/python` via `requirements.txt`.
from apiclient import discovery as apiclient_discovery
from apiclient import errors as apiclient_errors
from apiclient import http as apiclient_http
import httplib2

# Libraries provided by App Engine.
import webapp2

# Local imports.
from oauth2helper import decorator
import safe_memcache as memcache


APP_NAME = 'Cloud Console'
APP_VERSION = '0.1'
USER_AGENT = '%s/%s (github.com/mbrukman/cloud-launcher/tree/master/console)' % (
    APP_NAME, APP_VERSION)

# Timeout is in seconds.
MEMCACHE_TIMEOUT = 30


def Http():
    """Returns an instance of `httplib2.Http` with User-agent set."""
    http = httplib2.Http(memcache)
    return apiclient_http.set_user_agent(http, USER_AGENT)


class ComputeV1Base(webapp2.RequestHandler):

    def _get(self, obj, method, args):
        status_int = 200
        response = {}
        write_to_cache = False

        memcache_key = self.request.path
        memcache_value = memcache.get(memcache_key)
        if memcache_value:
            output = memcache_value
        else:
            http = decorator.credentials.authorize(Http())
            service = apiclient_discovery.build('compute', 'v1', http=http)
            try:
                response = service.__dict__[obj]().__dict__[
                    method](**args).execute()
                output = json.dumps(response, indent=2)
                write_to_cache = True
            except apiclient_errors.HttpError, e:
                response = {
                    'error': repr(e),
                    'response': response,
                }
                output = json.dumps(response, indent=2)
                status_int = 403

        self.response.headers['Content-Type'] = 'application/json'
        self.response.status_int = status_int
        self.response.write(output)

        if write_to_cache:
            memcache.set(key=memcache_key, value=output, time=MEMCACHE_TIMEOUT)


    def _post(self, obj, method, args):
        status_int = 200
        response = {}
        http = decorator.credentials.authorize(Http())
        service = apiclient_discovery.build('compute', 'v1', http=http)
        try:
            response = service.__dict__[obj]().__dict__[
                method](**args).execute()
            output = json.dumps(response, indent=2)
        except apiclient_errors.HttpError, e:
            response = {
                'error': repr(e),
                'response': response,
            }
            output = json.dumps(response, indent=2)
            status_int = 403

        self.response.headers['Content-Type'] = 'application/json'
        self.response.status_int = status_int
        self.response.write(output)
