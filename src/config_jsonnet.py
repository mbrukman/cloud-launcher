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

import json
import sys

# Local imports
import common


class Error(Exception):
    pass


class JsonnetNotFoundError(Error):
    pass


class ConfigExpander(object):

    def __init__(self, **kwargs):
        self.__kwargs = {}
        for key, value in kwargs.iteritems():
            self.__kwargs[key] = value

    def ExpandFile(self, file_name):
        # Jsonnet interpreter, import only if needed to avoid dependency.
        try:
            import _jsonnet
        except:
            raise JsonnetNotFoundError(
                'Module "_jsonnet" missing;  Is _jsonnet.so in your $PYTHONPATH?')
        project = self.__kwargs['project']
        json_str = _jsonnet.evaluate_file(
            file_name, env={'GCP_PROJECT': project})
        json_data = json.loads(json_str)
        return json_data['resources']


def main(argv):
    if len(argv) < 2:
        sys.stderr.write('Missing jsonnet file as argument\n')
        sys.exit(1)

    expander = ConfigExpander()
    config = expander.ExpandFile(argv[1])
    print json.dumps(config, indent=2, separators=(',', ': '))


if __name__ == '__main__':
    main(sys.argv)
