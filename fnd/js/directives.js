var app = angular.module('app');

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
