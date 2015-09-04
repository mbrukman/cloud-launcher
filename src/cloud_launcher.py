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
# Command runner to take action on Google Cloud Platform given a config.

# System imports
import argparse
import httplib2
import json
import logging
import os
import sys

# Google Cloud API imports
from googleapiclient.discovery import build
from googleapiclient import errors
from googleapiclient import http
from oauth2client.client import flow_from_clientsecrets
from oauth2client.file import Storage
from oauth2client import gce
from oauth2client import tools
from oauth2client.tools import run_flow

# Local imports
import config


API_VERSION = 'v1'
GCE_URL = 'https://www.googleapis.com/compute/%s/projects/' % (API_VERSION)
GCE_SCOPE = 'https://www.googleapis.com/auth/compute'


class GceHandler(object):

    def __init__(self, flags):
        self.__flags = flags

        # Perform OAuth 2.0 authorization.
        project_dir = os.path.join(
            os.getenv('HOME'), 'cloud', 'projects', flags.project)
        client_secrets = os.path.join(project_dir, 'client_secrets.json')
        oauth2_storage = os.path.join(project_dir, 'oauth2.dat')
        flow = flow_from_clientsecrets(client_secrets, scope=GCE_SCOPE)
        storage = Storage(oauth2_storage)
        credentials = storage.get()

        if credentials is None or credentials.invalid:
            credentials = run_flow(flow, storage, flags)
        http = httplib2.Http()
        self.__auth_http = credentials.authorize(http)

        # Build the service.
        self.__gce_service = build('compute', API_VERSION)
        self.__project_url = '%s%s' % (GCE_URL, flags.project)

    def Run(self):
        if self.__flags.command == 'list':
            self.List()
        elif self.__flags.command == 'insert':
            self.Insert()
        elif self.__flags.command == 'delete':
            self.Delete()
        elif self.__flags.command == 'print':
            self.Print()

    def List(self):
        for instance in self._ListInternal():
            print instance['name']

    def _ListInternal(self):
        if self.__flags.config:
            return self._ListFromConfig()
        else:
            return self._ListExisting()

    def _ListExisting(self):
        request = self.__gce_service.instances().list(project=self.__flags.project,
                                                      filter=None,
                                                      zone=self.__flags.zone)
        response = request.execute(http=self.__auth_http)
        if response and 'items' in response:
            return response['items']
        return []

    def _ListFromConfig(self):
        return config.ProcessConfig(file=self.__flags.config,
                                    project=self.__flags.project,
                                    zone=self.__flags.zone)

    def _InstanceInSelection(self, instance):
        # No explicit selection implies selecting everything, for simplicity.
        if self.__flags.instances is None:
            return True

        instances = self.__flags.instances.split(',')
        return instance in instances

    def _FormatJson(self, obj):
        if self.__flags.json_format == 'compact':
            return '%s' % obj
        elif self.__flags.json_format == 'pretty':
            return json.dumps(obj, indent=2, separators=(',', ': '))

    def _PrintJsonResponse(self, name, response):
        json_text = self._FormatJson(response)
        print 'Done: [%s], response: %s' % (name, json_text)

    def _ExecuteBatchRequest(self, requests):
        """Executes the given |requests| in batches.

        Documentation:
        * https://developers.google.com/api-client-library/python/guide/batch

        Args:
          requests: list of (request_id, request) pairs
        """
        def _BatchHttpRequestCallback(request_id, response, exception):
            if exception is not None:
                print 'Error: %s' % exception
            else:
                self._PrintJsonResponse(request_id, response)

        batch = None
        num_batch_requests = 0
        MAX_BATCH_SIZE = 1000  # documented at the URL above

        for request_id, request in requests:
            if batch is None:
                batch = http.BatchHttpRequest(
                    callback=_BatchHttpRequestCallback)
            batch.add(request, request_id=request_id)
            num_batch_requests += 1
            if num_batch_requests == MAX_BATCH_SIZE:
                batch.execute(http=self.__auth_http)
                batch = None
                num_batch_requests = 0

        # Execute the left-over requests in the batch if there are any.
        if batch is not None:
            batch.execute(http=self.__auth_http)
            batch = None

    def Insert(self):
        if self.__flags.config is None:
            sys.stderr.write(
                '--config must be specified pointing to a valid config file\n')
            sys.exit(1)

        instances = self._ListFromConfig()
        requests = []

        for instance in instances:
            instance_name = instance['name']
            if not self._InstanceInSelection(instance_name):
                if self.__flags.debug:
                    print 'Skipping instance %s [not in selection]' % instance_name
                continue

            print 'Inserting instance: %s' % instance_name
            if self.__flags.dry_run:
                continue
            request = self.__gce_service.instances().insert(project=self.__flags.project,
                                                            body=instance,
                                                            strict=True,
                                                            zone=self.__flags.zone)
            requests.append((instance_name, request))

        self._ExecuteBatchRequest(requests)
        print 'Done'

    def Delete(self):
        """Deletes the list of GCE VM instances, either already existing or in a config.
        """
        instances = self._ListInternal()
        requests = []

        for instance in instances:
            instance_name = instance['name']
            if not self._InstanceInSelection(instance_name):
                if self.__flags.debug:
                    print 'Skipping instance %s [not in selection]' % instance_name
                continue

            print 'Deleting instance: %s' % instance_name
            if self.__flags.dry_run:
                continue
            request = self.__gce_service.instances().delete(project=self.__flags.project,
                                                            instance=instance_name,
                                                            zone=self.__flags.zone)
            requests.append((instance_name, request))

        self._ExecuteBatchRequest(requests)
        print 'Done'

    def Print(self):
        if self.__flags.config is None:
            sys.stderr.write(
                '--config must be specified pointing to a valid config file\n')
            sys.exit(1)

        instances = self._ListFromConfig()
        for instance in instances:
            instance_name = instance['name']
            if not self._InstanceInSelection(instance_name):
                if self.__flags.debug:
                    print 'Skipping instance %s [not in selection]' % instance_name
                continue

            print '[%s] instance: %s' % (instance_name, self._FormatJson(instance))


def main(argv):
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
        parents=[tools.argparser])

    parser.add_argument('--project', dest='project', required=True,
                        help='Project name')

    parser.add_argument('--zone', dest='zone', required=True,
                        help='Zone')

    parser.add_argument('--config', dest='config',
                        help='File to read configuration from')

    parser.add_argument('--instances', dest='instances',
                        help='Instances to operate on')

    parser.add_argument('--debug', dest='debug', default=False,
                        action='store_true',
                        help='Whether to output debug info')

    parser.add_argument('--dry_run', dest='dry_run', default=False,
                        action='store_true',
                        help='Whether to execute in dry-run mode')

    parser.add_argument('--json_format', dest='json_format', default='compact',
                        choices=('compact', 'pretty'),
                        help='Format of the JSON response output')

    parser.add_argument('--logging', dest='logging', default='',
                        choices=('', 'info', 'warning', 'error'),
                        help='Logging level to enable')

    parser.add_argument('command', choices=('list', 'insert', 'delete', 'print'),
                        help='Command to run')

    flags = parser.parse_args(argv[1:])

    LOGGING = {
        '': None,
        'info': logging.INFO,
        'WARNING': logging.WARNING,
        'error': logging.ERROR,
    }
    logging.basicConfig(level=LOGGING[flags.logging])

    gce_handler = GceHandler(flags)
    gce_handler.Run()


if __name__ == '__main__':
    main(sys.argv)
