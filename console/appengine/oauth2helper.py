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

import os

# Libraries added to `third_party/python` via `requirements.txt`.
from oauth2client import appengine

# Local imports.
import safe_memcache as memcache


CLIENT_SECRETS = 'client_secrets.json'

SCOPE = [
    'https://www.googleapis.com/auth/compute',
    'https://www.googleapis.com/auth/devstorage.read_only',
]

decorator = appengine.OAuth2DecoratorFromClientSecrets(
    filename=os.path.join(os.path.dirname(__file__), CLIENT_SECRETS),
    scope=SCOPE,
    message='Missing %s file' % CLIENT_SECRETS,
    cache=None)
