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
    $routeProvider.when("/demo/schema.html",
      templateUrl: "views/demo/schema.html"
      controller: "BaseCtrl"
    ).when("/demo/schema/:name.html",
      templateUrl: "views/demo/schema.html"
      controller: "BaseCtrl"
    ).when("/demo/resources.html",
      templateUrl: "views/demo/resources.html"
      controller: "ResourcesCtrl"
    ).when("/demo/resources/:type/:id.html",
      templateUrl: "views/demo/resources.html"
      controller: "ResourcesCtrl"
    ).when("/demo/queries.html",
      templateUrl: "views/demo/queries.html"
      controller: "QueriesCtrl"
    ).when("/demo/index.html",
      templateUrl: "views/demo/index.html"
      controller: "IndexCtrl"
    ).otherwise redirectTo: "/demo/index.html"
]
