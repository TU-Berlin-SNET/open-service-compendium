angular.module('frontendApp').factory 'Schema', ($resource) ->
  $resource '/schema.json', {}, {
    get: {
      method: "get"
      cache: true
    }
  }