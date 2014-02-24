var app = angular.module('app', ['ngRoute','ngSanitize'])

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
    console.log(item.id);
    $http.get('/data/delete', {params: { 'resource_id': item.id}})
    .success(function(data){
      $scope.items.splice($scope.items.indexOf(item), 1);
    })
  }
});

app.controller('ResourceNewCtrl', function($scope, $http, $routeParams, $location, $rootScope, $timeout){
  $scope.resourse = JSON.stringify({a:1})
  $scope.example_search = {file: $routeParams.search}

  $scope.load_example = function(file){
    $scope.resourse = "Loading " + file + '...';
    $http.get(
      '/data/demo/by_attr',
      {params: { rel: 'example_resource', col: 'file', val: file}}
    ).success(function(data){
      $scope.resourse = JSON.stringify(data.json);
    })
  }

  $scope.resources = $http
  .get('/data/demo', {params: { rel: 'example_resource_list'}})
  .success(function(data){
    $scope.resources = data;
    console.log($routeParams);
    if ($routeParams.search) {
      for(var i=0;i<$scope.resources.length;i++){
        var res = $scope.resources[i];
        if (res.file.match(new RegExp($routeParams.search, 'i'))) {
            $http.get(
              '/data/demo/by_attr',
              {params: { rel: 'example_resource', col: 'file', val: res.file}}
            ).success(function(data){
              $scope.resourse = JSON.stringify(data.json);
            })
            break;
          }
      }
    }
  })

  $scope.save = function(){
    $scope.response = "loading..."
    var res = JSON.parse($scope.resourse)

    $http({
      method: 'POST',
      url: '/data/resource/create',
      data: JSON.stringify(res)
    }).success(function(data){
      $scope.response = data
      if (data.id) {
        var path = "/#/resources/" + data.id + ".html";
        document.location.href = path;
      }
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

  $scope.query = 'select * from fhir.view_patient order by id'
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
