var app = angular.module('app');

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

app.directive('highlight', function($filter, $parse) {
  return {
    scope: { code: '@highlight' },
    link: function(scope, element, attr) {
      var htmlEncode = function(input) {
        return angular.element('<div/>').text(input).html();
      }
      scope.$watch('code', function(value) {
        element.html(htmlEncode(value));
        hljs.highlightBlock(element[0]);
      })
    }
  }
});

app.directive('loadingSpinner', function() {
  return {
    scope: { cond: '=loadingSpinner'},
    template: "<span ng-show='cond' class='spinner glyphicon glyphicon-refresh'></span>"
  }
})
