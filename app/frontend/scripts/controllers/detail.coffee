`//This is the controller for the detail.jade view who is responsible of showing the detail of a selected services.

  angular.module('frontendApp').controller('detailCtrl', ['$scope','$stateParams',
    function($scope,$stateParams) 
    {
      //if refresh or direct access wait for the callback to get and fetch the json and put the selected service (based on uri) in $scope.selectedService
      if(!$scope.selectedService)
      {   
        $scope.services.$promise.then(function(data) 
        {
             for(var i=0; i<$scope.services.length; i++) 
             {
               if($scope.extractId(data[i].uri) == $scope.id) 
               {
                        //console.log(data[i]);
                        $scope.selectedService=data[i];
               }
             }

        });
      }
      
        //$scope.selectedService is inherited from services and contain the json file of the selected service 

        //function for showmore or showless on click
        $scope.Var = true;
        $scope.toggleText='ShowMore';
        $scope.toggle = function() {    
          $scope.Var = !$scope.Var;
          $scope.toggleText = $scope.Var ? 'ShowMore' : 'ShowLess';};

      //get service id from url
      $scope.id=$scope.getUriFromUrl($stateParams.id);

    }]);
`




