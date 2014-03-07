app = angular.module("app")
app.controller "BaseCtrl", ($scope, $http, $routeParams) ->
  $scope.listLoading = true
  $http.get("/data/view",
    params:
      view: "resource"
  ).success (data) ->
    $scope.listLoading = false
    $scope.items = data
    $scope.show $routeParams.name or data[0].title
    return

  $scope.show = (title) ->
    $scope.resourceTitle = title
    $scope.loadingDetails = true
    $http.get("/data/show",
      params:
        resource: title
    ).success (data) ->
      $scope.loadingDetails = false
      $scope.details = data
      return

    return

  $scope.columnClass = (column_name) ->
    if [
      "id"
      "_type"
      "_unknown_attributes"
      "resource_type"
      "language"
      "container_id"
      "contained_id"
      "parent_id"
      "resource_id"
    ].indexOf(column_name) >= 0
      "gray-column"
    else
      ""

  $scope.locateTable = (table_name) ->
    $("html, body").animate
      scrollTop: $("#" + table_name).offset().top - 50
    , "slow"
    return

  $scope.locateTop = ->
    $("html, body").animate
      scrollTop: 0
    , "slow"
    return

  return

app.controller "ResourcesCtrl", ($scope, $http, $filter, $routeParams, $location) ->
  $scope.listLoading = true
  $http.get("/data/resource",
    params:
      type: "patient"
  ).success (data) ->
    $scope.listLoading = false
    $scope.items = data
    item = undefined
    if $routeParams.id
      item =
        id: $routeParams.id
        resourceType: $routeParams.type
    else
      item = $scope.items[0]
    $scope.show item
    return

  $scope.deleteResource = ->
    $http.get("/data/delete",
      params:
        resource_id: (if $routeParams.id then $routeParams.id else $scope.items[0].id)
    ).success (data) ->
      index = undefined
      if $routeParams.id
        index = $scope.items.map((item) ->
          item.id
          return
        ).indexOf($routeParams.id)
      else
        index = 0
      $scope.items.splice index, 1
      $location.path "/demo/resources.html"
      return

    return

  $scope.show = (item) ->
    return  unless item
    $scope.resource = item
    $scope.resourceLoading = true
    $http.get("/data/details",
      params:
        resource_id: item.id
    ).success (data) ->
      $scope.resourceLoading = false
      $scope.details = data.data
      $scope.resource_json = data.resource_json
      return

    return

  $scope.loadExample = (file) ->
    $scope.snippet = "Loading " + file + "..."
    $scope.snippetLoading = true
    $http.get("/data/demo/by_attr",
      params:
        rel: "example_resource"
        col: "file"
        val: file
    ).success (data) ->
      $scope.snippetLoading = false
      $scope.snippet = data
      $scope.snippet.jsonString = $filter("json")(data.json)
      return

    return

  $http.get("/data/demo",
    params:
      rel: "example_resource_list"
  ).success (data) ->
    $scope.snippets = data
    $scope.loadExample $scope.snippets[0].file
    return

  $scope.save = ->
    $http(
      method: "POST"
      url: "/data/resource/create"
      data: $scope.snippet.jsonString
    ).success((data) ->
      $scope.response = data
      $location.path "demo/resources/" + $scope.snippet.json.resourceType + "/" + data.id + ".html"
      return
    ).error (data, status, header) ->
      $scope.response = {}
      $scope.response.error = "Something went wrong!"
      return

    return

  $scope.locateTable = (table_name) ->
    $("html, body").animate
      scrollTop: $("#" + table_name).offset().top - 50
    , "slow"
    return

  $scope.locateTop = ->
    $("html, body").animate
      scrollTop: 0
    , "slow"
    return

  return

app.controller "QueriesCtrl", ($scope, $http, $filter) ->
  $http.get("/data/resource",
    params:
      type: "patient"
  ).success (data) ->
    $scope.items = data
    return

  $http.get("/data/tables",
    params: {}
  ).success (data) ->
    $scope.tables = data
    return

  $scope.executeQuery = ->
    compact = $filter("compact")
    jsonize = $filter("json")
    $scope.loaded = false
    $http.get("/data/query",
      params:
        q: $scope.query.query
    ).success (data) ->
      $scope.result = jsonize(compact(data))
      $scope.loaded = true
      return

    return

  $http.get("/data/demo",
    params:
      rel: "queries"
  ).success (data) ->
    $scope.queries = data
    $scope.show data[0]
    return

  $scope.show = (query) ->
    $scope.query = angular.copy(query)
    return

  $scope.saveAs = ->
    name = prompt("Enter name of query")
    return  unless name
    query =
      query: $scope.query.query
      name: name

    $scope.queries.push query
    return

  return

app.controller "IndexCtrl", ($scope, $http, $routeParams) ->

