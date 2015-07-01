`//This is the controller for the list.jade view who is responsible of showing the list of services filtered by the faceted search.

angular.module('frontendApp').controller('ServicesController', [
  '$scope', 'Services', '$http','$stateParams','$state', function($scope, Services, $http,$stateParams,$state) {
    

    $http.defaults.headers.common['Accept'] = 'application/json';
    $scope.services = Services.query();
    //$scope.services contain the requested json file from the broker.
    //serviceType contain the selected radio button ex: iaas or saas
    $scope.type=$stateParams.type;
	$scope.checkboxList = [];  //List of selected checkbox
  $scope.selectedService=''; //contail the selected service for the detail view

$scope.state=$state; // contain the current state



$scope.canNotCompare = function canNotCompare() //if true will disable the compare button
{
	return ($scope.checkboxList.length <2 );
};

$scope.canNotSelect = function canNotSelect(uri) //if true will disable the checkbox
{
	return (  (!$scope.canNotCompare()) && !(uri == $scope.checkboxList[0].uri || uri == $scope.checkboxList[1].uri));
};

$scope.selectService = function selectService(service) //if true will disable the compare button
{
$scope.selectedService=service;
};

if(!$scope.type) // Check if a service model is selected
{
  window.alert("No service model selected");
}

  }
]);
`