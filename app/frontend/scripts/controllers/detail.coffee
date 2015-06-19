`//This is the controller for the detail.jade view who is responsible of showing the detail of a selected services.

angular.module('frontendApp').controller('detailCtrl', ['$scope','shareData',
    function($scope,shareData) {

        //$scope.id should contain the name of the selected service. You can get it with ui router parameters    
        $scope.id='cotroller detail.cofee';
        //$scope.data contain the requested json file.
        $scope.data=shareData.getSharedData();  
}]);
`