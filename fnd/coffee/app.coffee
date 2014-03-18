app = angular.module("app", [
  "ngRoute"
  "ngSanitize"
  "ngCookies"
  "ngAnimate"
  "ui.codemirror"
])
app.config [
  "$routeProvider"
  "$locationProvider"
  ($routeProvider, $locationProvider) ->
    $routeProvider.when("/schema",
      templateUrl: "views/schema.html"
      controller: "SchemaCtrl"
    ).when("/schema/:name",
      templateUrl: "views/schema.html"
      controller: "SchemaCtrl"
    ).when("/resources",
      templateUrl: "views/resources.html"
      controller: "ResourcesCtrl"
    ).when("/resources/:type/:id",
      templateUrl: "views/resources.html"
      controller: "ResourcesCtrl"
    ).when("/queries",
      templateUrl: "views/queries.html"
      controller: "QueriesCtrl"
    ).when("/abbreviations",
      templateUrl: "views/abbreviations"
      controller: "AbbreviationsCtrl"
    ).when("/",
      templateUrl: "views/index.html"
    ).when("/index",
      templateUrl: "views/index.html"
      controller: "IndexCtrl"
    ).when("/abbreviations",
      templateUrl: "views/abbreviations.html"
      controller: "AbbreviationsCtrl"
    ).otherwise redirectTo: "/noroute"
]
