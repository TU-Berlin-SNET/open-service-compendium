angular.module('frontendApp').factory 'Schema', ($resource) ->
  $resource '/schema.json', {}, {}