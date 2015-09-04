angular.module('frontendApp').factory 'Services', ($resource) ->
  $resource '/services.json/:serviceId', { serviceId: '@_id' }, {}