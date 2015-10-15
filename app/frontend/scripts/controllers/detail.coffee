angular.module("frontendApp").controller "DetailController", [ "$scope", "$stateParams", "lodash", "$templateCache", ($scope, $stateParams, _, $templateCache) ->
  $scope.$watch('services', (services) ->
    $scope.service = _.find(services, (service) ->
      service.uiRouterParams.id is $stateParams.id and service.uiRouterParams.version is $stateParams.version
    )
  )

  $scope.hasPropertyValues = (category) ->
    _.any _.keys(category.properties), (property) ->
      $scope.service[property] != undefined

  $scope.templateName = (name, property) ->
    templateByName = "partials/details/named/#{name}.html"
    return templateByName if $templateCache.get(templateByName)

    "partials/details/generic.html"
]