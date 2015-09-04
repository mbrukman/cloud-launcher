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
# Config processing for JSON files.

import json
import os
import sys


class ConfigExpander(object):

    def __init__(self, **kwargs):
        self.__kwargs = {}
        for key, value in kwargs.iteritems():
            self.__kwargs[key] = value

    def ExpandFile(self, file_name):
        with open(file_name, 'r') as file_input:
            json_obj = json.loads(file_input.read())
            return json_obj['resources']


def main(argv):
    if len(argv) < 2:
        sys.stderr.write('Syntax: %s [JSON file]\n' %
                         os.path.basename(argv[0]))
        sys.exit(1)

    expander = ConfigExpander()
    config = expander.ExpandFile(argv[1])
    print json.dumps(config, indent=2, separators=(',', ': '))


if __name__ == '__main__':
    main(sys.argv)
