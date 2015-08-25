// Copyright 2015 Google Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

consoleApp.controller('ProjectCtrl', ['$scope', '$http',
    function($scope, $http) {
  $scope.DEBUG = true;

  $scope.project = null;
  $scope.allInstances = [];
  $scope.instancesByZone = {};

  $scope.instanceStatusIsOneOf = function(instance, statuses) {
    if (!('status' in instance)) {
      console.log('[error] instance has no "status" field'); 
      return false;
    }
    // For more info on statuses, see the docs:
    // https://developers.google.com/compute/docs/reference/latest/instances#resource
    for (var i = 0; i < statuses.length; ++i) {
      if (instance.status == statuses[i]) {
        return true;
      }
    }
    return false;
  };

  // The various status strings and transitions can be found here:
  // https://cloud.google.com/compute/docs/instances/#checkmachinestatus

  $scope.instanceStatusIsStarting = function(instance) {
    return $scope.instanceStatusIsOneOf(
        instance, ['PROVISIONING', 'STAGING']);
  };

  $scope.instanceStatusIsRunning = function(instance) {
    return $scope.instanceStatusIsOneOf(
        instance, ['RUNNING']);
  };

  $scope.instanceStatusIsStopping = function(instance) {
    return $scope.instanceStatusIsOneOf(
        instance, ['STOPPING']);
  };

  $scope.instanceStatusIsTerminated = function(instance) {
    return $scope.instanceStatusIsOneOf(
        instance, ['TERMINATED']);
  };

  function lastComponentOfUri(uri) {
    var uriParts = uri.split('/');
    return uriParts[uriParts.length - 1];
  }

  $scope.zoneFromUri = lastComponentOfUri;
  $scope.diskFromUri = lastComponentOfUri;

  function networkInterfaceFromInstance(instance) {
    if (!('networkInterfaces' in instance)) {
      return null;
    }
    var networkInterfaces = instance.networkInterfaces;
    switch (networkInterfaces.length) {
      case 0: return null;
      case 1: return networkInterfaces[0];
      default: {
        throw (networkInterfaces.length + ' network interfaces');
      }
    }
  }

  function networkAccessConfigFromInstance(instance) {
    var networkInterface = null;
    try {
      networkInterface = networkInterfaceFromInstance(instance);
      if (networkInterface == null) {
        return null;
      }
    } catch (e) {
      if (typeof e == 'string') {
        return e;
      }
    }

    if (!('accessConfigs' in networkInterface)) {
      return null;
    }
    var accessConfigs = networkInterface.accessConfigs;
    switch (accessConfigs.length) {
      case 0: return null;
      case 1: return accessConfigs[0];
      default: throw (accessConfigs.length + ' networks');
    }
  }

  $scope.externalIpFromInstance = function(instance) {
    var accessConfig = null;
    try {
      accessConfig = networkAccessConfigFromInstance(instance);
      if (accessConfig == null) {
        console.log('externalIpFromInstance(): accessConfig is null');
        return '<error>';
      }
    } catch (e) {
      console.log('externalIpFromInstance(): exception: ' + e);
      return '<error>';
    }

    if ((typeof accessConfig == 'object') &&
        ('type' in accessConfig) &&
        (accessConfig.type == 'ONE_TO_ONE_NAT') &&
        ('natIP' in accessConfig)) {
      return accessConfig.natIP;
    }

    return '-';
  };

  $scope.networkNameFromInstance = function(instance) {
    var networkInterface = null;
    try {
      networkInterface = networkInterfaceFromInstance(instance);
      if (networkInterface == null) {
        return '';
      }
    } catch (e) {
      if (typeof e == 'string') {
        return e;
      }
    }

    if ((typeof networkInterface == 'object') &&
        ('network' in networkInterface)) {
      return lastComponentOfUri(networkInterface.network);
    }

    return '';
  };

  $scope.loadInstances = function(data) {
    var allInstances = [];
    var instancesByZone = {};
    if ('items' in data) {
      for (var zoneUri in data.items) {
        var value = data.items[zoneUri];
        if ('instances' in value) {
          // Format for zoneUri: "zones/<name-of-zone>".
          var zone = zoneUri.split('/')[1];
          if (!(zone in instancesByZone)) {
            instancesByZone[zone] = [];
          }
          allInstances.push.apply(allInstances, value.instances);
          instancesByZone[zone].push.apply(instancesByZone[zone], value.instances);
        }
      }
    }

    var compareByName = function(a, b) {
      var compareValues = function(s1, s2) {
        return s1 > s2 ? 1 : (s1 < s2 ? -1 : 0);
      };
      var aMatch = a.name.match(/^(.*)-([0-9]+)$/);
      var bMatch = b.name.match(/^(.*)-([0-9]+)$/);
      if (aMatch && bMatch) {
        var first = compareValues(aMatch[1], bMatch[1]);
        if (first != 0) {
          return first;
        }

        return compareValues(parseInt(aMatch[2]), parseInt(bMatch[2]));
      }
      return compareValues(a.name, b.name);
    };
    allInstances.sort(compareByName);
    $scope.allInstances = allInstances;
    $scope.instancesByZone = instancesByZone;
  };

  $scope.updateInstances = function() {
    $http({
      method: 'GET',
      url: '/compute/v1/projects/' + $scope.projectName + '/instances/aggregated',
    })
      .success(function(data, status, headers, config) {
        if ($scope.DEBUG) {
          console.log('[instances]');
          console.log(data);
        }

        $scope.loadInstances(data);
      })
      .error(function(data, status, headers, config) {
        if ($scope.DEBUG) {
          console.log('[instances] error: ' + data);
        }
      });

    // TODO: periodic refresh of the data.
    // setInterval($scope.updateInstances, 5000);
  };

  $scope.updateInstances();
}]);

consoleApp.controller('ProjectSelectCtrl', ['$scope', '$location',
    function($scope, $location) {
	$scope.project = null;

  $scope.visitProject = function() {
		var newPath = '/project/' + $scope.project + '/compute/instances';
		// Note: this updates the path in the Angular-route sense, i.e.,
		// <protocol>://host/#/<path>, rather than <protocol>://<host>/<path>
		//
    // $location.path(newPath).replace();
		window.location.pathname = newPath;
  };
}]);
