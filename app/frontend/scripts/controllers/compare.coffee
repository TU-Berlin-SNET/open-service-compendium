

`

angular.module('frontendApp').controller('compareCtrl', ['$scope','shareData',
    function($scope,shareData) {

             
        $scope.test='This is the cotroller compare.cofee';
        $scope.data=shareData.getSharedData();  
}]);



















`