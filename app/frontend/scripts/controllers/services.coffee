angular.module('frontendApp').controller 'ServicesController', ['$scope', 'Services', ($scope, Services) ->
  $scope.loadData = () ->
    $scope.services = Services.query()
]
