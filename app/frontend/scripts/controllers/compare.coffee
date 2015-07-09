`//This is the controller for the compare.jade view that is responsible for comparing two services

angular.module('frontendApp').controller('compareCtrl', ['$scope', '$filter', '$stateParams',
    function($scope, $filter, $stateParams) {
    

    

       // Check for errors
       $scope.error_message = null;
       // Check if we found two services
       if ($scope.checkboxList.length != 2) {
         $scope.error_message = "You have to select two services";
       }
       else
         // Check if both services are compatible
         if ($scope.checkboxList[0].cloud_service_model != $scope.checkboxList[1].cloud_service_model) {
          $scope.error_message = "You are comparing two different service models!";
         }
         else if ($scope.extractId($scope.checkboxList[0].uri) != $scope.getUriFromUrl($stateParams.id) || $scope.extractId($scope.checkboxList[1].uri) != $scope.getUriFromUrl($stateParams.other_id))
         {
          $scope.error_message = "ERROR !";
          //redirect to home
         }

         // dynamic property selection
         $scope.selectedProperties = ['uri', 'cloud_service_model', 'is_billed'];
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
