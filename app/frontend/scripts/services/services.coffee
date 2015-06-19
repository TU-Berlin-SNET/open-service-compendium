`angular.module('frontendApp').factory('Services', function($resource) {
  return $resource('/services/:serviceId', {
    serviceId: '@_id'
  }, {});
});
`