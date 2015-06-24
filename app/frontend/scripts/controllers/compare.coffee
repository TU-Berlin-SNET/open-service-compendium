`//This is the controller for the compare.jade view that is responsible for comparing two services

angular.module('frontendApp').controller('compareCtrl', ['$scope', '$filter', '$stateParams',
    function($scope, $filter, $stateParams) {
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
