angular.module("frontendApp").controller "ListController", [ "$scope", "Services", "Schema", "Filters", "lodash", "$stateParams", ($scope, Services, Schema, Filters, _, $stateParams) ->
  Services.query().$promise.then((response) ->
    $scope.categorizedServices = _.filter(response.resource, (service) ->
      [].concat(service.service_categories).indexOf($stateParams.category) != -1
    )
  )

  Filters.list().then((filters) ->
    $scope.filters = filters;
  )

  $scope.isFiltered = (service) ->
    if $scope.filters.length == 0
      false
    else
      not _.any($scope.filters, (filter) ->
        filter.predicate(service)
      )
]