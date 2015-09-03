angular.module("frontendApp").controller "footerCtrl", [ "$scope", "$state", ($scope, $state) ->
  $scope.state = $state #get the current state
]