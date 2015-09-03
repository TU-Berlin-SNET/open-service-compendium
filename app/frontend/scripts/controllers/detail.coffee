angular.module("frontendApp").controller "detailCtrl", [ "$scope", "$stateParams", ($scope, $stateParams) ->

  #if refresh or direct access wait for the callback to get and fetch the json and put the selected service (based on uri) in $scope.selectedService
  unless $scope.selectedService
    $scope.services.$promise.then (data) ->
      i = 0

      while i < $scope.services.length
        #console.log(data[i]);
        $scope.selectedService = data[i]  if $scope.extractId(data[i].uri) is $scope.id
        i++

  #$scope.selectedService is inherited from services and contain the json file of the selected service

  #function for showmore or showless on click
  $scope.Var = true
  $scope.toggleText = "ShowMore"
  $scope.toggle = ->
    $scope.Var = not $scope.Var
    $scope.toggleText = (if $scope.Var then "ShowMore" else "ShowLess")

  #get service id from url
  $scope.id = $scope.getUriFromUrl($stateParams.id)
]