var app = angular.module('app');

app.controller('BaseCtrl', function($scope, $http, $routeParams){
  $scope.listLoading = true;
  $http.get('/data/view', {params: { view: 'resource' }})
    .success(function(data){
      $scope.listLoading = false;
      $scope.items = data;
      $scope.show($routeParams.name || data[0].title);
    })

  $scope.show = function(title){
    $scope.resourceTitle = title;
    $scope.loadingDetails = true;
    $http.get('/data/show', {params: { resource: title}})
    .success(function(data){
      $scope.loadingDetails = false;
      $scope.details = data;
    })
  }
});

app.controller('ResourcesCtrl', function($scope, $http, $filter, $routeParams, $location){
  $scope.listLoading = true;
  $http.get('/data/resource', {params: {type: 'patient'}})
  .success(function(data){
    $scope.listLoading = false;
    $scope.items = data;
    var item;
    if ($routeParams.id)
      item = {
        id: $routeParams.id,
        resourceType: $routeParams.type
      }
    else
      item = $scope.items[0]
    $scope.show(item);
  })
  $scope.deleteResource = function(){
    $http.get('/data/delete', {params: { 'resource_id': $routeParams.id ? $routeParams.id : $scope.items[0].id}})
    .success(function(data){
      var index;
      if ($routeParams.id)
        index = $scope.items.map(function(item) { item.id }).indexOf($routeParams.id);
      else
        index = 0
      $scope.items.splice(index, 1);
      $location.path('/demo/resources.html');
    })
  }
  $scope.show = function(item) {
    if (!item) return;
    $scope.resource = item;
    $scope.resourceLoading = true;
    $http.get('/data/details', {params: { resource_id: item.id }})
    .success(function(data){
      $scope.resourceLoading = false;
      $scope.details = data.data;
    })
  }
  $scope.loadExample = function(file){
    $scope.snippet = "Loading " + file + '...';
    $scope.snippetLoading = true;
    $http.get(
      '/data/demo/by_attr',
      {params: { rel: 'example_resource', col: 'file', val: file}}
    ).success(function(data){
      $scope.snippetLoading = false;
      $scope.snippet = data;
      $scope.snippet.jsonString = $filter('json')(data.json);
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
      data: $scope.snippet.jsonString
    }).success(function(data){
      $scope.response = data
      $location.path('demo/resources/' + $scope.snippet.json.resourceType + '/' + data.id + '.html');
    }).error(function(data, status, header) {
      $scope.response = {};
      $scope.response.error = "Something went wrong!";
    })
  };
});

app.controller('QueriesCtrl', function($scope, $http, $filter){
  $http.get('/data/resource', {params: {type: 'patient'}})
  .success(function(data){
    $scope.items = data;
  })
  $http.get('/data/tables', {params: {}})
  .success(function(data){
    $scope.tables = data;
  });

  $scope.executeQuery = function() {
    var compact = $filter('compact');
    var jsonize = $filter('json');
    $scope.loaded = false;
    $http.get('/data/query', {params: {q: $scope.query.query}})
    .success(function(data){
      $scope.result = jsonize(compact(data));
      $scope.loaded = true;
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

app.controller('GuideMenuController', function($scope, Wizard) {
  $scope.finishedSteps = Wizard.finishedSteps();
  $scope.notFinishedSteps = Wizard.notFinishedSteps();
  $scope.isActive = function(step) {
    return Wizard.isActive(step);
  }
})
