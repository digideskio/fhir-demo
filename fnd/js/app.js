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
      when('/resources.html', {
        templateUrl: 'views/resources.html',
        controller: 'ResourcesCtrl'
      }).
      when('/resources/:resource.html', {
        templateUrl: 'views/resource_show.html',
        controller: 'ResourceShowCtrl'
      }).
      when('/patients.html', {
        templateUrl: 'views/patients.html',
        controller: 'PatientsCtrl'
      }).
      when('/patients/new.html', {
        templateUrl: 'views/patient_new.html',
        controller: 'PatientNewCtrl'
      }).
      when('/patients/:id.html', {
        templateUrl: 'views/patient_show.html',
        controller: 'PatientShowCtrl'
      }).
      when('/about.html', {
        templateUrl: 'views/about.html',
        controller: 'AboutCtrl'
      }).
      otherwise({
        redirectTo: '/index.html'
      });
}]);

app.controller('IndexCtrl', function($scope, $http){ })

app.controller('PatientsCtrl', function($scope, $http){
  $scope.items = $http.get('/data/resource', {params: {type: 'patient'}})
  .success(function(data){
    $scope.items = data;
  })
})

.filter('humanName', function() {
    return function(name) {
      if(! name){
        return 'Ups :('
      }
      else {
        return name.map(function(nm){
          return (nm.prefix || []).join(' ') + ' ' +
                 (nm.family || []).join(' ') + ' ' +
                 (nm.given || []).join(' ');
        }).join('; ')
      }
    };
});

app.controller('PatientNewCtrl', function($scope, $http){
  $scope.resourse = JSON.stringify({a:1})
  $scope.save = function(){
    $scope.response = "loading..."

    $http({
      method: 'POST',
      url: '/post/resource',
      data: "data=" + JSON.stringify($scope.resourse).replace(/(^"|"$)/g,''), //HACK: ????
      headers: {
        "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8"
      }
    }).success(function(data){
      $scope.response = "Patient saved with " + data
    })
  };
})

app.controller('PatientShowCtrl',
    function($scope, $http, $routeParams){
  $scope.params = $routeParams
});

app.controller('ResourcesCtrl', function($scope, $http){
  $scope.items = $http.get('/data/view', {params: { view: 'resource'}})
  .success(function(data){
    $scope.items = data;
  })
})

app.controller('ResourceShowCtrl',
    function($scope, $http, $routeParams){
  $scope.params = $routeParams
});

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

