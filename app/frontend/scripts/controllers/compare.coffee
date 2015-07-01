`//This is the controller for the compare.jade view that is responsible for comparing two services

angular.module('frontendApp').controller('compareCtrl', ['$scope', '$filter', '$stateParams',
    function($scope, $filter, $stateParams) {

       /* @HENNING :I THINK WE DON'T NEED THIS ANYMORE ? 
       // Function to filter JSON file for comparable services
       $scope.isSelected = function(service) {
         return (service.service_name === $stateParams.id ||
            service.service_name === $stateParams.other_id);
       };

       // Check for errors
    
       var selectedServices = [];
       // iterate services and find first selected service
       for(var i=0; i<$scope.services.length; i++) {
         if($scope.services[i].service_name == $stateParams.id || $scope.services[i].service_name == $stateParams.other_id ) {
           selectedServices.push($scope.services[i]);
         }
       }

              // Save requested names in $scope
       $scope.firstServiceName = $stateParams.id;
       $scope.secondServiceName = $stateParams.other_id;
       */

        //$scope.checkboxList contain the json of the two selected services

       $scope.error_message = null;
       // Check if we found two services
       if ($scope.checkboxList.length != 2) {
         $scope.error_message = "Only one service is selected. Please select another one.";
       }
       else 
         // Check if both services are compatible
         if ($scope.checkboxList[0].cloud_service_model != $scope.checkboxList[1].cloud_service_model) {
          $scope.error_message = "You are comparing two different service models!";
         }
         else if ($scope.checkboxList[0].service_name != $stateParams.id || $scope.checkboxList[1].service_name != $stateParams.other_id)
         {
          $scope.error_message = "ERROR !";
          //redirect to home
         }

       





}]);
`
