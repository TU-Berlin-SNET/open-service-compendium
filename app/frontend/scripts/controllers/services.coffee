`//This is the controller for the list.jade view who is responsible of showing the list of services filtered by the faceted search.

angular.module('frontendApp').controller('ServicesController', [
  '$scope', 'Services', '$http','$stateParams', function($scope, Services, $http,$stateParams) {
    

    $http.defaults.headers.common['Accept'] = 'application/json';
    $scope.services = Services.query();
    //$scope.services contain the requested json file from the broker.
    //serviceType contain the selected type ex: iaas or saas
    $scope.serviceType = $stateParams.type;
    //serviceType contain the selected radio button ex: iaas or saas
    $scope.type=$scope.serviceType;
	$scope.checkboxList = [];  //List of selected checkbox


$scope.toggleSelection = function toggleSelection(id) //handle the selected checkbox
	{
 		if ($scope.checkboxList[0] == id)
 			{
 			  	$scope.checkboxList.splice(0, 1); 
			}
 		else if( $scope.checkboxList[1] == id)
 			{
 				$scope.checkboxList.splice(1, 1); 
			}
		else if ($scope.checkboxList.length >= 2)
			{
        		$scope.checkboxList[0] = $scope.checkboxList[1];
        		$scope.checkboxList[1] = id;
    		} 
    	else 
    		{
        		$scope.checkboxList.push(id);
        	}
		
	};


$scope.canNotCompare = function canNotCompare() //if true will disable the compare button
{
	return ($scope.checkboxList.length <2 );
};

$scope.canNotSelect = function canNotSelect(id) //if true will disable the checkbox
{
	return (  (!$scope.canNotCompare()) && !(id == $scope.checkboxList[0] || id == $scope.checkboxList[1]));
};


  }
]);
`