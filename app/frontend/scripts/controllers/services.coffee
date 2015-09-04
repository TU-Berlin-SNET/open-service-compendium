angular.module("frontendApp").controller "ServicesController", [ "$scope", "Services", "Schema", "$http", "$stateParams", "$state", ($scope, Services, Schema, $http, $stateParams, $state) ->
  $scope.services = Services.query()
  $scope.schema = Schema.get()
]