`//This is the controller for the compare.jade view that is responsible for comparing two services

angular.module('frontendApp').controller('compareCtrl', ['$scope', '$filter', '$stateParams',
    function($scope, $filter, $stateParams) {

       // Check for errors
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

         // dynamic property selection
         $scope.selectedProperties = [];
         $scope.properties = [];
         // get all possible property keys
         for(var key in $scope.checkboxList[0]) {
           $scope.properties.push(key);
         }
         // add selected property to properties selection
         $scope.addProperty = function() {
           $scope.selectedProperties.push($scope.select);
         }

       }
]);
`
