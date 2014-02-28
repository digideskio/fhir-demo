var app = angular.module('app');

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
