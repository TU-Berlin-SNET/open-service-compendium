`//This is the controller for the detail.jade view who is responsible of showing the detail of a selected services.

angular.module('frontendApp').controller('detailCtrl', ['$scope','$stateParams',
    function($scope,$stateParams) {


  
      //$scope.selectedService is inherited from services and contain the json file of the selected service 

      //function for showmore or showless on click
		$scope.Var = true;
      $scope.toggleText='ShowMore';
      $scope.toggle = function() {    
        $scope.Var = !$scope.Var;
        $scope.toggleText = $scope.Var ? 'ShowMore' : 'ShowLess';};

        

    //get service id from url
     $scope.id=$scope.getUriFromUrl($stateParams.id);


	// TODO find out why $scope.services.length == 0 when refreshing 
	console.log("data : " + $scope.services);
	console.log($scope.services.length);
	if(!$scope.selectedService) // if rehresh or direct access, mus be desactivated to see the difference in $scope.services
	{
		for(var i=0; i<$scope.services.length; i++)
		{
	       if($scope.extractId($scope.services[i].uri) == $scope.id) 
	       {
	        selectedService=$scope.services[i];
	        console.log("id found: "+ $scope.id);


	        }
	    }
	}
   
}]);
`




