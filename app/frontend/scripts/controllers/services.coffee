`//This is the controller for the list.jade view who is responsible of showing the list of services filtered by the faceted search.

angular.module('frontendApp').controller('ServicesController', [
  '$scope', 'Services', '$http','shareData', function($scope, Services, $http,shareData) {
    $http.defaults.headers.common['Accept'] = 'application/json';
    $scope.services = Services.query();
    //$scope.services contain the requested json file from the broker.
    shareData.setSharedData($scope.services);
  }
]);
`