var app = angular.module('app');

app.filter('compact', function() {
  return function compactFilter(obj) {
    for (var key in obj) {
      if (!obj[key]) {
        if (angular.isObject(obj)) {
          delete obj[key];
        } else if (angular.isArray(obj)) {
          obj.splice(key, 1);
        }
      } else if (angular.isObject(obj[key])) {
        compactFilter(obj[key]);
      } else if (angular.isArray(obj[key])) {
        for (var subobj in obj[key]) {
          compactFilter(subobj);
        }
      }
    }
    return obj;
  }
})

