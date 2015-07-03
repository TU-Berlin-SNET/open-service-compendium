`
angular.module('frontendApp').controller('homeCtrl', ['$scope','serviceModel',
    function($scope,serviceModel) {



$scope.setData = function(data) {
  serviceModel.setServiceModel(data);
}

    }]);
`