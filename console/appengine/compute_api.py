#!/usr/bin/env python
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

"""Converts API definitions in compute_api.yaml into handlers and routes."""

import sys

sys.path.insert(1, 'third_party/python')

import yaml

BASE_CLASS = 'compute_api_base.ComputeV1Base'


def class_name(item):
    """Returns class name given the item dictionary.

    Args:
      item: dictionary

    Returns:
      string usable as a class name
    """
    obj = item['object'][0].upper() + item['object'][1:]
    method = item['method'][0].upper() + item['method'][1:]
    return 'ComputeV1%s%sHandler' % (obj, method)


def method_args(item):
    """Returns a dictionary formatted as a string given the arguments in item.

    Args:
        item: dictionary containing key 'args' mapping to a list of strings

    Returns:
        dictionary formatted as a string, suitable for printing as a value
    """
    args = ["'%s': %s" % (arg, arg) for arg in item['args']]
    return '{%s}' % ', '.join(args)

def main(argv):
    print('# GENERATED FILE: DO NOT EDIT MANUALLY; WILL BE OVERWRITTEN')
    print('# Regenerate via: %s %s' % (argv[0], argv[1]))
    print()
    print('# Libraries provided by App Engine.')
    print('import webapp2')
    print()
    print('# Local imports.')
    print('from oauth2helper import decorator')
    print('import compute_api_base')
    print()
    with open(argv[1], 'r') as yaml_input:
        data = yaml.safe_load(yaml_input)

        # Output class definitions.
        for item in data:
            print("""\
class %(class)s(%(base_class)s):
    @decorator.oauth_required
    def %(verb)s(self, %(verb_args)s):
        return self._%(verb)s(
            obj='%(object)s', method='%(method)s',
            args=%(method_args)s)
""" % {
          'class': class_name(item),
          'base_class': BASE_CLASS,
          'verb': item['verb'].lower(),
          'verb_args': ', '.join(item['args']),
          'object': item['object'],
          'method': item['method'],
          'method_args': method_args(item),
      })

        # Output routes.
        print('routes = [')

        for item in data:
            print('    webapp2.Route(')
            print("        '%s'," % item['url'])
            print('        %s),' % class_name(item))

        print(']')


if __name__ == '__main__':
    main(sys.argv)
