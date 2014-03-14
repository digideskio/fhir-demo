app = angular.module("app")
app.run ($rootScope, $location)->
  $rootScope.$on '$routeChangeStart', (next, current) ->
    $rootScope.currentPath = $location.path()

app.controller "SchemaCtrl", ($scope, $http, $routeParams) ->
  $scope.listLoading = true

  pathEquals = (p1, p2)->
    p1.join('.') == p2.join('.')

  isChild = (parent, child)->
    pathEquals(parent.path, child.path[0..-2])

  isParent = (parent, child)->
    pathEquals(parent.path, child.path[0..(parent.path.length - 1)])

  appendInTree = (acc, item)->
    for i in acc
      if isChild(i,item)
        i._children ||=[]
        i._children.push(item)
      else if isParent(i,item)
        i._children ||= []
        appendInTree(i._children, item)
    acc

  $http.get("/data/view",
    params:
      view: "resource"
  ).success (data) ->
    $scope.listLoading = false
    $scope.items = data
    $scope.show $routeParams.name or data[0].title
    return

  $scope.selection = {}
  $scope.show = (title) ->
    $scope.resourceTitle = title
    $scope.loadingDetails = true
    $http.get("/data/show",
      params:
        resource: title
    ).success (data) ->
      $scope.loadingDetails = false
      $scope.details = data
      $scope.itemsTree = data[1..-1].reduce(appendInTree, [data[0]])[0]
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
  $scope.flags = {}
  $scope.cancel = ()->
    $scope.flags.upload = false
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
        resource_id: (if $routeParams.id then $routeParams.id else ($scope.items[0].id || $scope.items[0]._id))
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
      $location.path("/resources")
      return

    return

  $scope.show = (item) ->
    return  unless item
    $scope.resource = item
    $scope.resourceLoading = true
    $http.get("/data/details",
      params:
        resource_id: item.id || item._id #FIXME: use only _id
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
  $scope.snippet = {jsonString: "//Put your resource json here" }
  $http.get("/data/demo",
    params:
      rel: "example_resource_list"
  ).success (data) ->
    $scope.snippets = data
    return

  $scope.save = ->
    $http(
      method: "POST"
      url: "/data/resource/create"
      data: $scope.snippet.jsonString
    ).success((data) ->
      if data.error
        $scope.error = data.error
      else
        $location.path("/resources/#{$scope.snippet.json.resourceType}/#{data._id}")
      return
    )
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
app.controller "AbbreviationsCtrl", ($scope, $http, $routeParams) ->

