`angular.module('frontendApp').controller('ServicesController', [
  '$scope', 'Services', '$http','shareData', function($scope, Services, $http,shareData) {
    $http.defaults.headers.common['Accept'] = 'application/json';
    $scope.services = Services.query();
    shareData.setSharedData($scope.services);
  }
]);



















`