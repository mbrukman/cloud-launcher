#!/usr/bin/env python
#
# Copyright 2015 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
"""A console for Google Cloud Platform, running on App Engine.

Download the OAuth 2.0 client secrets via the Developer Console
<https://console.developers.google.com/> and save them as 'client_secrets.json'
in this directory. See README.md for details.
"""

# Standard Python libraries.
import json
import logging
import os

# Libraries we added to `lib` via `requirements.txt`.
from apiclient import discovery
from apiclient import errors
from oauth2client import appengine
import httplib2

# Libraries provided by App Engine.
import jinja2
import webapp2

# Local imports.
import safe_memcache as memcache

# Timeout is in seconds.
MEMCACHE_TIMEOUT = 30

CLIENT_SECRETS = 'client_secrets.json'

JINJA_ENVIRONMENT = jinja2.Environment(
    loader=jinja2.FileSystemLoader(os.path.dirname(__file__)),
    autoescape=True,
    extensions=['jinja2.ext.autoescape'])

SCOPE_READONLY = [
    'https://www.googleapis.com/auth/compute.readonly',
    'https://www.googleapis.com/auth/devstorage.read_only',
]

SCOPE_READWRITE = [
    'https://www.googleapis.com/auth/compute',
    'https://www.googleapis.com/auth/devstorage.full_control',
]

decorator = appengine.OAuth2DecoratorFromClientSecrets(
    filename=os.path.join(os.path.dirname(__file__), CLIENT_SECRETS),
    # TODO(mbrukman): optional upgrade to read-write mode?
    scope=SCOPE_READONLY,
    message='Missing %s file' % CLIENT_SECRETS,
    cache=memcache)


class IndexHandler(webapp2.RequestHandler):

    @decorator.oauth_aware
    def get(self):
        if not decorator.has_credentials():
            self.redirect(decorator.authorize_url())
            return

        variables = {}
        template = JINJA_ENVIRONMENT.get_template('web/index.html')
        self.response.write(template.render(variables))


class RedirectHandler(webapp2.RequestHandler):

    @decorator.oauth_aware
    def get(self, project):
        self.redirect('/#%s' % self.request.path)


class ComputeV1Base(webapp2.RequestHandler):

    def _get(self, obj, method, args):
        status_int = 200
        response = {}

        memcache_key = self.request.path
        memcache_value = memcache.get(memcache_key)
        if memcache_value:
            output = memcache_value
        else:
            http = decorator.credentials.authorize(httplib2.Http(memcache))
            service = discovery.build('compute', 'v1', http=http)
            try:
                response = service.__dict__[obj]().__dict__[
                    method](**args).execute()
                output = json.dumps(response, indent=2)
                memcache.set(key=memcache_key, value=output,
                             time=MEMCACHE_TIMEOUT)
            except errors.HttpError, e:
                response = {
                    'error': repr(e),
                    'response': response,
                }
                output = json.dumps(response, indent=2)
                status_int = 403

        self.response.headers['Content-Type'] = 'application/json'
        self.response.status_int = status_int
        self.response.write(output)


class ComputeV1ProjectInstancesAggregatedHandler(ComputeV1Base):

    @decorator.oauth_required
    def get(self, project):
        return self._get(
            obj='instances', method='aggregatedList', args={'project': project})


app = webapp2.WSGIApplication(
    [
        webapp2.Route(
            '/',
            IndexHandler),

        # Legacy URL handlers for compatibility with Developers Console;
        # redirect to new AngularJS URL with routes.
        webapp2.Route(
            '/project/<project>/compute/instances',
            RedirectHandler),

        # API handlers.
        webapp2.Route(
            '/compute/v1/projects/<project>/instances/aggregated',
            ComputeV1ProjectInstancesAggregatedHandler),

        (decorator.callback_path, decorator.callback_handler()),
    ],
    debug=True)
