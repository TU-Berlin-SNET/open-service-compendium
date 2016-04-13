angular.module("frontendApp").controller "StaticQuestionnaireDetailsController",
["$scope", "$stateParams"
($scope, $stateParams) ->

    $scope.csmKey = $stateParams.csmKey
]