angular.module("frontendApp").controller "ListController", [ "$scope", "Services", "Schema", "Filters", "lodash", "$q", ($scope, Services, Schema, Filters, _) ->
  Filters.list().then((filters) ->
    $scope.filters = filters;
  )

  $scope.isFiltered = (service) ->
    not _.any($scope.filters, (filter) ->
      filter.predicate(service)
    )
]