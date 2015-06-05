angular.module('frontendApp').controller 'ServicesController', ['$scope', 'Services', '$http', ($scope, Services, $http) ->
  $http.defaults.headers.common['Accept']= 'application/json'

  $scope.services = Services.query()
]
