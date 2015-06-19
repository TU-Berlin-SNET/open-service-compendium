`//This is the controller for the compare.jade view who is responsible of comparing two services (fabian did it for 4 services). 

angular.module('frontendApp').controller('compareCtrl', ['$scope','shareData',
    function($scope,shareData) {
   
        $scope.test='This is the cotroller compare.cofee';
        //$scope.data contain the requested json file
        $scope.data=shareData.getSharedData();  

}]);
`