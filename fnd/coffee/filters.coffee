app = angular.module("app")
app.filter "compact", ->
  compactFilter = (obj) ->
    for key of obj
      unless obj[key]
        if angular.isObject(obj)
          delete obj[key]
        else obj.splice key, 1  if angular.isArray(obj)
      else if angular.isObject(obj[key])
        compactFilter obj[key]
      else if angular.isArray(obj[key])
        for subobj of obj[key]
          compactFilter subobj
    obj

