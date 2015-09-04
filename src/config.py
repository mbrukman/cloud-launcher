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
# Config processing and expansion.

# Local imports
import config_json
import config_jsonnet
import config_py


class InvalidArgumentError(Exception):
    pass


class InvalidConfigFilename(Exception):
    pass


def ProcessConfig(**kwargs):
    if 'file' not in kwargs:
        raise InvalidArgumentError('"file" parameter not found among kwargs')

    ext_to_config = {
        '.json': config_json.ConfigExpander,
        '.jsonnet': config_jsonnet.ConfigExpander,
        '.py': config_py.ConfigExpander,
    }

    filename = kwargs['file']
    for ext, config in ext_to_config.iteritems():
        if filename.endswith(ext):
            return config(**kwargs).ExpandFile(filename)

    raise InvalidConfigFilename(
        'Unrecognized extension in file: %s' % filename)
