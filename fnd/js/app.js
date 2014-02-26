var app = angular.module('app', ['ngRoute','ngSanitize', 'ui.ace'])

$(function(){
  $('.collapse').collapse()
})

app.config(['$routeProvider','$locationProvider',
  function($routeProvider, $locationProvider) {
    // $locationProvider.html5Mode(true);
    $routeProvider.
      when('/index.html', {
        templateUrl: 'views/index.html',
        controller: 'IndexCtrl'
      }).
      when('/demo/before.html', {
        templateUrl: 'views/demo/before.html'
      }).
      when('/demo/resources_meta.html', {
        templateUrl: 'views/demo/resources_meta.html',
        controller: 'BaseCtrl'
      }).
      when('/demo/resources_meta/:resource.html', {
        templateUrl: 'views/demo/resource_meta_show.html',
        controller: 'BaseShowCtrl'
      }).
      when('/demo/resources.html', {
        templateUrl: 'views/demo/resources.html',
        controller: 'ResourcesCtrl'
      }).
      when('/demo/resources/new.html', {
        templateUrl: 'views/demo/resource_new.html',
        controller: 'ResourceNewCtrl'
      }).
      when('/demo/resources/:id.html', {
        templateUrl: 'views/demo/resource_show.html',
        controller: 'ResourceShowCtrl'
      }).
      when('/demo/queries.html', {
        templateUrl: 'views/demo/queries.html',
        controller: 'QueriesCtrl'
      }).
      when('/about.html', {
        templateUrl: 'views/about.html',
        controller: 'AboutCtrl'
      }).
      when('/guide/:step.html', {
        templateUrl: function(params) {
          return 'views/guide/' + params.step + '.html';
        }
      }).
      otherwise({
        redirectTo: '/index.html'
      });
}]);

app.controller('IndexCtrl', function($scope, $http){
});

app.controller('BaseCtrl', function($scope, $http){
 $http.get('/data/view', {params: { view: 'resource'}})
  .success(function(data){
    $scope.items = data;
  })
});

app.controller('BaseShowCtrl',
    function($scope, $http, $routeParams){
  $scope.params = $routeParams
  $http.get('/data/show', {params: { resource: $routeParams.resource}})
  .success(function(data){
    $scope.items = data;
  })
});

app.controller('ResourcesCtrl', function($scope, $http){
  $http.get('/data/resource', {params: {type: 'patient'}})
  .success(function(data){
    $scope.items = data;
  })
  $scope.delete_resource = function(item){
    $http.get('/data/delete', {params: { 'resource_id': item.id}})
    .success(function(data){
      $scope.items.splice($scope.items.indexOf(item), 1);
    })
  }
});

app.controller('ResourceNewCtrl', function($scope, $http, $routeParams, $location, $rootScope, $timeout){
  $scope.resource = JSON.stringify({
      "resourceType":"Patient",
      "name":{
          "use":"official",
          "family":[
                "Chalmers"
              ],
          "given":[
                "Peter",
                "James"
              ]
        },
      "telecom":[
          {
            "system":"phone",
            "value":"(03) 5555 6473",
            "use":"work"
          }
        ],
      "gender":{
          "coding":[
                {
                  "system":"http://hl7.org/fhir/v3/AdministrativeGender",
                  "code":"M",
                  "display":"Male"
                }
              ]
        },
      "address":{
          "use":"home",
          "line":[
                "534 Erewhon St"
              ],
          "city":"PleasantVille",
          "state":"Vic",
          "zip":"3999"
        }
    });
  $scope.example_search = {file: $routeParams.search};

  $scope.load_example = function(file){
    $scope.resource = "Loading " + file + '...';
    $http.get(
      '/data/demo/by_attr',
      {params: { rel: 'example_resource', col: 'file', val: file}}
    ).success(function(data){
      $scope.resource = JSON.stringify(data.json);
    })
  }

  $scope.resources = $http
  .get('/data/demo', {params: { rel: 'example_resource_list'}})
  .success(function(data){
    $scope.resources = data;
    if ($routeParams.search) {
      for(var i=0;i<$scope.resources.length;i++){
        var res = $scope.resources[i];
        if (res.file.match(new RegExp($routeParams.search, 'i'))) {
            $http.get(
              '/data/demo/by_attr',
              {params: { rel: 'example_resource', col: 'file', val: res.file}}
            ).success(function(data){
              $scope.resource = JSON.stringify(data.json);
            })
            break;
          }
      }
    }
  })

  $scope.save = function(){
    $http({
      method: 'POST',
      url: '/data/resource/create',
      data: $scope.resource
    }).success(function(data){
      $scope.response = data
      window.wizard = { patientId: data.id };
    }).error(function(data, status, header) {
      $scope.response = {};
      $scope.response.error = "Something went wrong!";
    })
  };
})

app.controller('ResourceShowCtrl',
    function($scope, $http, $routeParams){
  $http.get('/data/details', {params: { resource_id: $routeParams.id}})
  .success(function(data){
    $scope.resource_id = data.resource_id;
    $scope.resource_name = data.resource_name;
    $scope.items = data.data;
  })
});

app.controller('QueriesCtrl', function($scope, $http){
  $http.get('/data/resource', {params: {type: 'patient'}})
  .success(function(data){
    $scope.items = data;
  })
  $http.get('/data/tables', {params: {}})
  .success(function(data){
    $scope.tables = data;
  });

  if (window.wizard)
    $scope.query = "select * from fhir.view_patient where id = '"  + window.wizard.patientId + "'";
  else
    $scope.query = "select * from fhir.view_patient order by id";
  $scope.query_items = [];

  $scope.execute_query = function() {
    $http.get('/data/query', {params: {q: $scope.query}})
    .success(function(data){
      $scope.query_items = data;
    })
  }

  $http.get('/data/demo', {params: { rel: 'queries'}})
  .success(function(data){
    $scope.queries = data;
  })

  $scope.set_query = function(query) {
    $scope.query = query;
  }
})

app.controller('CoursesCtrl', function($scope, $http){
  $scope.items = $http.get('/data/public_course')
  .success(function(data){
    $scope.items = data;
  })
})

app.controller('menu', function($scope, $http){
  $scope.items = $http.get('/meta/menu.json')
  .success(function(data){
    $scope.items = data;
  })
})

app.factory('Patient', function($http, $q) {
  return {
    get: function(id, callback) {
      var query = "select * from fhir.view_patient where id = '" + id + "'"

      $http.get('/data/query', {params: {q: query}}).then(function(response) {
        if (callback) callback(response.data[0].json)
      });
    },
    update: function(id, patient, callback) {
      $http.put('/data/resource', patient, { params: {resource_id: id} }).then(function(response) {
        if (callback) callback(response);
      })
    },
    remove: function(id) {
      $http.get('/data/delete', {params: { 'resource_id': id}});
    }
  }
})

app.factory('Query', function($http, $q) {
  return {
    exec: function(query, callback) {
      query = query.replace(/;$/, '');
      $http.get('/data/query', {params: {q: query}}).then(function(response) {
        if (callback) callback(response)
      });
    }
  }
})

app.controller('ResourceUpdateCtrl', function($scope, $filter, Query, Patient) {
  if (window.wizard) {
     Patient.get(window.wizard.patientId, function(patient) {
       $scope.resource = patient;
       $scope.query = "select fhir.update_resource('" +
         window.wizard.patientId +
         "', '" +
         JSON.stringify($scope.resource) +
         "')";
     })
  };

  $scope.save = function() {
    if (window.wizard) Query.exec($scope.query, function(response) {
      $scope.response = response.data;
    });
  }
})

app.controller('ResourceDeleteCtrl', function($scope, $filter, Query) {
  $scope.del = function() {
    if (window.wizard) Query.exec($scope.query, function(response) {
      $scope.response = response.data;
    });
  };

  if (window.wizard) {
    $scope.query = "select fhir.delete_resource('" +
      window.wizard.patientId + "')";
  }
})

app.controller('ResourceInsertCtrl', function($scope, $filter, Query) {
  $scope.resource = {
      "resourceType":"Patient",
      "name":{
          "use":"official",
          "family":[
                "Chalmers"
              ],
          "given":[
                "Peter",
                "James"
              ]
        }
  };

  $scope.query = "select fhir.insert_resource('" +
    JSON.stringify($scope.resource) + "')";

  $scope.save = function() {
    Query.exec($scope.query, function(response) {
      $scope.response = response.data;
      window.wizard = { patientId: response.data[0].insert_resource }
    })
  }
})

app.controller('ResourceSelectCtrl', function($scope, $filter, Query) {
  $scope.select = function() {
    if (window.wizard) Query.exec($scope.query, function(response) {
      $scope.response = response.data;
    });
  };

  if (window.wizard) {
    $scope.query = "select * from fhir.view_patient where id = '" +
      window.wizard.patientId + "'";
  }
})

app.filter('compact', function() {
  return function compactFilter(obj) {
    for (var key in obj) {
      if (!obj[key]) {
        if (angular.isObject(obj)) {
          delete obj[key];
        } else if (angular.isArray(obj)) {
          obj.splice(key, 1);
        }
      } else if (angular.isObject(obj[key])) {
        compactFilter(obj[key]);
      } else if (angular.isArray(obj[key])) {
        for (var subobj in obj[key]) {
          compactFilter(subobj);
        }
      }
    }
    return obj;
  }
})
