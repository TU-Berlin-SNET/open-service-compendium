angular.module("frontendApp").controller "ServicesController", [ "$scope", "Services", "$http", "$stateParams", "$state", "Schema", ($scope, Services, $http, $stateParams, $state, Schema) ->
  $scope.services = Services.query()
  $scope.schema = Schema.get()
]