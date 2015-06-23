`//This is the controller for the compare.jade view that is responsible for comparing two services

angular.module('frontendApp').controller('compareCtrl', ['$scope', '$filter', '$stateParams', 'shareData',
    function($scope, $filter, $stateParams, shareData) {

       // Get the JSON list of all services
       $scope.services = shareData.getSharedData();

       // Function to filter JSON file for comparable services
       $scope.isSelected = function(service) {
         return (service.service_name === $stateParams.id ||
            service.service_name === $stateParams.other_id);
       };

       // Save requested names in $scope
       $scope.firstServiceName = $stateParams.id;
       $scope.secondServiceName = $stateParams.other_id;

}]);
`
