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
# Constructors for Resources suitable for making GCE API calls.

import bunch
import common
import vm_images

# Allow users to write 'true' the way they write it in many common languages,
# particularly Javascript, which is quite relevant, since we're generating JSON
# as output.
true = True


class GCE(object):

    class Settings(object):
        project = None
        zone = None

    default = Settings()
    current = Settings()

    @classmethod
    def setDefaults(cls, project=None, zone=None):
        if project is not None:
            cls.default.project = project

        if zone is not None:
            cls.default.zone = zone

    @classmethod
    def setCurrent(cls, project=None, zone=None):
        if project is not None:
            cls.current.project = project

        if zone is not None:
            cls.current.zone = zone

    @classmethod
    def clearCurrent(cls):
        cls.current.project = None
        cls.current.zone = None

    @classmethod
    def project(cls):
        if cls.current.project is not None:
            return cls.current.project
        else:
            return cls.default.project

    @classmethod
    def zone(cls):
        if cls.current.zone is not None:
            return cls.current.zone
        else:
            return cls.default.zone


class Util(object):

    @classmethod
    def updateResourceWithParams(cls, resource, params):
        resource = bunch.bunchify(resource)
        for key, val in params.iteritems():
            if val is not None:
                resource[key] = val

        return resource


class Image(object):

    @classmethod
    def resolve(cls, image, project=None):
        """
        Args:
          image (string): short name of the image
          project (string): (optional) project name

        Returns:
          string (URL pointing to the VM image)
        """
        if project is None:
            project = GCE.project()

        # TODO(mbrukman): custom images within the project should override default
        # images. For now, we will depend on them having distinct names. This also
        # allows us to select the image URL without a network call.
        try:
            return vm_images.ImageShortNameToUrl(image)
        except:
            return common.ImageToUrl(project, image)


class Disk(object):

    def __init__(self):
        assert False, 'Do not create a Disk via instance ctor; use static factory method instead'

    @classmethod
    def initializeParams(
            cls, sourceImage, diskSizeGb=None, diskType=None):
        resources = {
            'sourceImage': Image.resolve(sourceImage),
            # TODO(mbrukman): do we need a default here? GCE defaults this to 10GB
            # already; avoiding this explicit default makes the output cleaner.
            #
            # 'diskSizeGb': 10,
        }

        # Ensure that the user specified this parameter correctly.
        if (diskType is not None) and (not common.IsUrl(diskType)):
            diskType = common.DiskTypeToUrl(
                GCE.project(), GCE.zone(), diskType)

        params = {
            'diskSizeGb':  diskSizeGb,
            'diskType': diskType,
        }
        return Util.updateResourceWithParams(resources, params)

    @classmethod
    def attachedDisk(
            cls, autoDelete=None, boot=None, initializeParams=None,
            mode=None, type=None):
        """Creates a `Disk` suitable for inline inclusion in a compute `Instance`.

        Args:
          See documentation for the API:
          https://developers.google.com/compute/docs/reference/latest/instances
          https://developers.google.com/compute/docs/reference/latest/instances/attachDisk

        Returns:
          dict suitable for conversion to JSON.
        """
        resource = {
            'kind': 'compute#attachedDisk',
            'mode': 'READ_WRITE',
            'type': 'PERSISTENT',
        }
        params = {
            'autoDelete': autoDelete,
            'boot': boot,
            'initializeParams': initializeParams,
            'mode': mode,
            'type': type,
        }
        return Util.updateResourceWithParams(resource, params)

    @classmethod
    def boot(cls, **kwargs):
        kwargs['boot'] = True
        return cls.attachedDisk(**kwargs)

    @classmethod
    def data(cls, **kwargs):
        return cls.attachedDisk(**kwargs)


class Network(object):

    @classmethod
    def externalNat(cls, name=None):
        resource = {
            'network': common.NetworkToUrl(GCE.project(), 'default'),
            'accessConfigs': [
                {
                    'type': 'ONE_TO_ONE_NAT',
                    'name': 'External NAT',
                },
            ],
        }

        if name is not None and not common.IsUrl(name):
            name = common.NetworkToUrl(GCE.project(), name)

        params = {
            'network': name,
        }
        return Util.updateResourceWithParams(resource, params)

    @classmethod
    def create(cls, name, gatewayIPv4=None, IPv4Range=None):
        resource = {
            'kind': 'cloud#network',
            'name': name,
        }
        params = {
            'gatewayIPv4': gatewayIPv4,
            'IPv4Range': IPv4Range,
        }
        return Util.updateResourceWithParams(resource, params)


class Metadata(object):

    @classmethod
    def create(cls, items=None):
        resource = {
            'kind': 'compute#metadata',
        }
        params = {
            'items': items,
        }
        return Util.updateResourceWithParams(resource, params)

    @classmethod
    def item(cls, key, value):
        return {
            'key': key,
            'value': value,
        }

    @classmethod
    def fileToString(cls, path):
        import traceback
        stack = traceback.extract_stack()
        current = None
        previous = None
        for (filename, line, function, text) in reversed(stack):
            if current is None:
                current = filename
                continue
            if current != filename:
                previous = filename
                break

        return common.ReadReferencedFileToString(previous, '%%file:%s' % path)

    @classmethod
    def startupScript(cls, path):
        return Metadata.item('startup-script', Metadata.fileToString(path))


class Compute(object):

    @classmethod
    def instance(
            cls, name, disks=None, machineType=None, metadata=None,
            networkInterfaces=None, tags=None, zone=None):
        """
        Args:
          See API documentation:
          https://developers.google.com/compute/docs/reference/latest/instances

        Returns:
          dict suitable for conversion to JSON, corresponding to "compute#instance"
          Resource kind in the GCE API
        """
        resource = {
            'kind': 'compute#instance',
            'name': name,
            'networkInterfaces': [Network.externalNat()],
            'serviceAccounts': [
                {
                    'email': 'default',
                    'scopes': [
                        'https://www.googleapis.com/auth/devstorage.full_control',
                        'https://www.googleapis.com/auth/compute'
                    ],
                },
            ],
        }

        if machineType is not None and not common.IsUrl(machineType):
            machineType = common.MachineTypeToUrl(
                GCE.project(), GCE.zone(), machineType)

        params = {
            'disks': disks,
            'machineType': machineType,
            'metadata': metadata,
            'networkInterfaces': networkInterfaces,
            'tags': tags,
            'zone': zone,
        }

        return Util.updateResourceWithParams(resource, params)
