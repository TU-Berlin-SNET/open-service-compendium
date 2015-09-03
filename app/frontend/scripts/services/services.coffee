angular.module('frontendApp').factory 'Services', ($resource) ->
  $resource '/services/:serviceId', { serviceId: '@_id' }, {}