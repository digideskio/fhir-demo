var app = angular.module('app', ['ngRoute','ngSanitize', 'ui.ace', 'ngCookies'])

$(function(){
  $('.collapse').collapse()
})

app.config(['$routeProvider','$locationProvider',
  function($routeProvider, $locationProvider) {
    // $locationProvider.html5Mode(true);
    $routeProvider.
      when('/demo/schema.html', {
        templateUrl: 'views/demo/schema.html',
        controller: 'BaseCtrl'
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
    $scope.show($scope.items[0])
  })

  $scope.show = function(item){
    $scope.resource = item
    $http.get('/data/show', {params: { resource: item.title}})
    .success(function(data){
      $scope.details = data;
    })
  }
});

app.controller('ResourcesCtrl', function($scope, $http, $filter){
  $http.get('/data/resource', {params: {type: 'patient'}})
  .success(function(data){
    $scope.items = data;
    $scope.show($scope.items[0]);
  })
  $scope.delete_resource = function(item){
    $http.get('/data/delete', {params: { 'resource_id': item.id}})
    .success(function(data){
      $scope.items.splice($scope.items.indexOf(item), 1);
    })
  }
  $scope.show = function(item) {
    $http.get('/data/details', {params: { resource_id: item.id }})
    .success(function(data){
      $scope.resource = item;
      $scope.details = data.data;
    })
  }
  $scope.loadExample = function(file){
    $scope.snippet = "Loading " + file + '...';
    $http.get(
      '/data/demo/by_attr',
      {params: { rel: 'example_resource', col: 'file', val: file}}
    ).success(function(data){
      $scope.snippet = $filter('json')(data.json);
    })
  }
  $http.get('/data/demo', {params: { rel: 'example_resource_list'}})
   .success(function(data){
     $scope.snippets = data;
     $scope.loadExample($scope.snippets[0].file);
   })
  $scope.save = function(){
    $http({
      method: 'POST',
      url: '/data/resource/create',
      data: $scope.snippet
    }).success(function(data){
      $scope.response = data
      var newItem = JSON.parse($scope.snippet);
      newItem.id = data.id;
      $scope.items.push(newItem);
    }).error(function(data, status, header) {
      $scope.response = {};
      $scope.response.error = "Something went wrong!";
    })
  };
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

  $scope.query = { query: "select * from fhir.view_patient order by id" };
  $scope.query_items = [];

  $scope.executeQuery = function() {
    $http.get('/data/query', {params: {q: $scope.query.query}})
    .success(function(data){
      $scope.query_items = data;
    })
  }

  $http.get('/data/demo', {params: { rel: 'queries'}})
  .success(function(data){
    $scope.queries = data;
    $scope.show(data[0]);
  })

  $scope.show = function(query) {
    $scope.query = angular.copy(query);
  }

  $scope.saveAs = function() {
    name = prompt('Enter name of query');
    if (!name) return;
    var query = {
      query: $scope.query.query,
      name: name
    };
    $scope.queries.push(query);
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

app.controller('ResourceUpdateCtrl', function($scope, $filter, Patient, Wizard) {
  Patient.get(Wizard.getPatientId(), function(patient) {
    $scope.resource = patient;
    $scope.query = "select fhir.update_resource('" +
      Wizard.getPatientId() +
      "', '" +
      JSON.stringify($scope.resource) +
      "')";
  })
})

app.controller('ResourceDeleteCtrl', function($scope, $filter, Wizard) {
  $scope.query = "select fhir.delete_resource('" + Wizard.getPatientId() + "')";
})

app.controller('ResourceInsertCtrl', function($scope, $filter, Wizard) {
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

  $scope.query = "select fhir.insert_resource('" + JSON.stringify($scope.resource) + "')";
})

app.controller('ResourceSelectCtrl', function($scope, $filter, Wizard) {
  $scope.query = "select * from fhir.view_patient where id = '" + Wizard.getPatientId() + "'";
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

app.directive('step', function($parse) {
  return {
    restrict: 'E',
    replace: true,
    templateUrl: '/js/templates/step.html',
    scope: {
      query: '@',
      nextStepUrl: '@',
      nextStepName: '@',
      showResult: '='
    },
    controller: function($scope, $attrs, Query, Wizard) {
      $scope.isValid = function() {
        return $scope.response && $scope.response.length > 0 && !$scope.response.error;
      }

      $scope.execute = function() {
        Query.exec($scope.query, function(response) {
          $scope.response = response.data;
          var isFirst = $parse($attrs.first)();
          if (isFirst) {
            Wizard.setPatientId(response.data[0].insert_resource);
          }
        });
      }
    },
    compile: function(tElement, tAttr) {
      if (!tAttr.showResult) tAttr.showResult = false;
      return function() {};
    }
  }
})

app.factory('Wizard', function($location, $cookies) {
  var steps = [
    { url: "/guide/about.html", title: "Что это такое?" },
    { url: "/guide/struct.html", title: "Структура" },
    { url: "/guide/patient.html", title: "Пациент" },
    { url: "/guide/insert.html", title: "Добавление" },
    { url: "/guide/select.html", title: "Выборка" },
    { url: "/guide/update.html", title: "Редактирование" },
    { url: "/guide/delete.html", title: "Удаление" },
    { url: "#demo/before.html", title: "Полное демо" }
  ];
  var currentIndexOf = function(url) {
    for (var i = 0; i < steps.length; i++) {
      if (steps[i].url == url) return i;
    }
    return -1;
  };
  var lastStep = function() {
    return $cookies.lastStep || steps[0].url;
  }
  var nextStep = function() {
    return steps[currentIndexOf($location.path()) + 1];
  }
  return {
    setPatientId: function(id) {
      $cookies.patientId = id;
    },
    getPatientId: function() {
      return $cookies.patientId;
    },
    steps: function() {
      return steps;
    },
    finishedSteps: function() {
      return steps.slice(0, currentIndexOf(lastStep()) + 1);
    },
    notFinishedSteps: function() {
      return steps.slice(currentIndexOf(lastStep()) + 1);
    },
    nextStep: nextStep,
    saveProgress: function() {
      if (currentIndexOf($location.path()) >= currentIndexOf(lastStep()))
        $cookies.lastStep = nextStep().url;
    },
    isActive: function(step) {
      return $location.path() == step.url;
    }
  }
})

app.controller('GuideMenuController', function($scope, Wizard) {
  $scope.finishedSteps = Wizard.finishedSteps();
  $scope.notFinishedSteps = Wizard.notFinishedSteps();
  $scope.isActive = function(step) {
    return Wizard.isActive(step);
  }
})

app.directive('goToNextStep', function(Wizard) {
  return {
    replace: true,
    template: "<a class='btn btn-primary' ng-click='saveProgress()' href=#{{nextStep.url}}>{{nextStep.title}}</a>",
    link: function(scope, element, attr) {
      scope.nextStep = Wizard.nextStep();
      scope.saveProgress = function() {
        Wizard.saveProgress();
      }
    }
  }
})

app.filter('highlight', function() {
  return function(text, lang) {
    if (lang)
      return hljs.highlight(lang, text).value;
    else
      return hljs.highlightAuto(text).value;
  }
})

app.directive('highlight', function($filter, $parse) {
  return {
    scope: {
      code: '@'
    },
    compile: function(tElement, tAttr) {

      return function(scope, element, attr) {
        var lang = attr.highlight;
        highlightFilter = $filter('highlight');

        var htmlDecode = function(input) {
          var e = document.createElement('div');
          e.innerHTML = input;
          return e.childNodes.length === 0 ? "" : e.childNodes[0].nodeValue;
        }

        scope.$watch('code', function(value) {
          var content = value;
          var highlighted = highlightFilter(htmlDecode(content), lang);
          element.html(highlighted, lang)
        })
      }
    }
  }
});
