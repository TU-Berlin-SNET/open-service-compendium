`//This is the controller for the detail.jade view who is responsible of showing the detail of a selected services.

angular.module('frontendApp').controller('detailCtrl', ['$scope','$stateParams',
    function($scope,$stateParams) {

  
      //$scope.selectedService is inherited from services and contain the json file of the selected service 

      //function for showmore or showless on click

      $scope.Var = true;
      $scope.toggleText='ShowMore';
      $scope.toggle = function() {    
        $scope.Var = !$scope.Var;
        $scope.toggleText = $scope.Var ? 'ShowMore' : 'ShowLess';
    };
       
}]);
`




