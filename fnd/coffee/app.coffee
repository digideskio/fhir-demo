app = angular.module("app", [
  "ngRoute"
  "ngSanitize"
  "ngCookies"
  "ui.codemirror"
])
app.config [
  "$routeProvider"
  "$locationProvider"
  ($routeProvider, $locationProvider) ->
    $routeProvider.when("/schema.html",
      templateUrl: "views/schema.html"
      controller: "SchemaCtrl"
    ).when("/schema/:name.html",
      templateUrl: "views/schema.html"
      controller: "SchemaCtrl"
    ).when("/resources.html",
      templateUrl: "views/resources.html"
      controller: "ResourcesCtrl"
    ).when("/resources/:type/:id.html",
      templateUrl: "views/resources.html"
      controller: "ResourcesCtrl"
    ).when("/queries.html",
      templateUrl: "views/queries.html"
      controller: "QueriesCtrl"
    ).when("/abbreviations",
      templateUrl: "views/abbreviations.html"
      controller: "AbbreviationsCtrl"
    ).when("/",
      templateUrl: "views/index.html"
    ).when("/index.html",
      templateUrl: "views/index.html"
      controller: "IndexCtrl"
    ).otherwise redirectTo: "/noroute.html"
]
