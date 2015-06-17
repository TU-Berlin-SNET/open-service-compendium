

`

angular.module('frontendApp').controller('detailCtrl', ['$scope','shareData',
    function($scope,shareData) {

             
        $scope.dserviceName='cotroller detail.cofee';
        $scope.data=shareData.getSharedData();  
}]);



















`