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
import logging
import os

# Libraries we added to `third_party/python` via `requirements.txt`.
from oauth2client import appengine
import httplib2

# Libraries provided by App Engine.
import jinja2
import webapp2

# Local imports.
import compute_api_gen
from oauth2helper import decorator
import safe_memcache as memcache

JINJA_ENVIRONMENT = jinja2.Environment(
    loader=jinja2.FileSystemLoader(os.path.dirname(__file__)),
    autoescape=True,
    extensions=['jinja2.ext.autoescape'])


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

    ] + compute_api_gen.routes +
    [
        (decorator.callback_path, decorator.callback_handler()),
    ],
    debug=True)
