app = angular.module("app")
app.directive "highlight", ($filter, $parse) ->
  scope:
    code: "@highlight"

  link: (scope, element, attr) ->
    htmlEncode = (input) ->
      angular.element("<div/>").text(input).html()

    scope.$watch "code", (value) ->
      element.html htmlEncode(value)
      hljs.highlightBlock element[0]
      return

    return

app.directive "loadingSpinner", ->
  scope:
    cond: "=loadingSpinner"

  template: "<span ng-show='cond' class='spinner glyphicon glyphicon-refresh'></span>"

