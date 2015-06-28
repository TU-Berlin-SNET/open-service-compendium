`//This is the controller for the compare.jade view that is responsible for comparing two services

angular.module('frontendApp').controller('compareCtrl', ['$scope', '$filter', '$stateParams',
    function($scope, $filter, $stateParams) {

       // Function to filter JSON file for comparable services
       $scope.isSelected = function(service) {
         return (service.service_name === $stateParams.id ||
            service.service_name === $stateParams.other_id);
       };

       // Check for errors
       $scope.error_message = null;
       var selectedServices = [];
       // iterate services and find first selected service
       for(var i=0; i<$scope.services.length; i++) {
         if($scope.services[i].service_name == $stateParams.id) {
           selectedServices.push($scope.services[i]);
         }
       }
       // iterate services and find second selected service
       for(var i=0; i<$scope.services.length; i++) {
         if($scope.services[i].service_name == $stateParams.other_id) {
           selectedServices.push($scope.services[i]);
         }
       }
       // Check if we found two services
       if (selectedServices.length != 2) {
         $scope.error_message = "Only one service is selected. Please select another one.";
       }
       else {
         // Check if both services are compatible
         if (selectedServices[0].cloud_service_model != selectedServices[1].cloud_service_model) {
          $scope.error_message = "You are comparing two different service models!";
         }
       }

       // Save requested names in $scope
       $scope.firstServiceName = $stateParams.id;
       $scope.secondServiceName = $stateParams.other_id;

}]);
`
