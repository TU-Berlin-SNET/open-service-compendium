angular.module("frontendApp").controller "DetailController", [ "$scope", "$stateParams", "lodash", ($scope, $stateParams, _) ->
  $scope.$watch('services', (services) ->
    $scope.service = _.find(services, (service) ->
      service.uiRouterParams.id is $stateParams.id and service.uiRouterParams.version is $stateParams.version
    )
  )
]