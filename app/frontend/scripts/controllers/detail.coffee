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



      $scope.isSelected = function(service) {
          return ($scope.extractId(service.uri) === $scope.id);
        };

      // Temporary solution to allow refresh and direct access. The problem is that it's not possible to access $scope.services in case of refresh, probably due to delay caused by the request to the server, but it's possible to do it in the view.
      $scope.select = function(service) { 
          $scope.selectedService=service;
        };

	
   
}]);
`




