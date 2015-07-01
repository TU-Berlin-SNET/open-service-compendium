`//This is the controller for the detail.jade view who is responsible of showing the detail of a selected services.

angular.module('frontendApp').controller('detailCtrl', ['$scope','$stateParams',
    function($scope,$stateParams) {

        //$scope.id should contain the name of the selected service. You can get it with ui router parameters    
        // Function to filter JSON file for comparable services
       $scope.isSelected = function(service) {
         return (service.service_name === $stateParams.id)
       };

       //$scope.selectedService is inherited from services and contain the json file of the selected service 
     
       
}]);
`