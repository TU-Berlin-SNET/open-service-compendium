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

$scope.getUriFromUrl = function getUriFromUrl(url) // get the service uri from the url
      {
          console.log(url.substr(url.indexOf('-',1)+1,url.length));
          return(url.substr(url.indexOf('-',1)+1,url.length));
      };

$scope.extractId = function extractId(uri) // extract the service_id from uri
{
     if(uri)
    {
    //console.log(uri.substr(uri.indexOf('/',1)+1,uri.indexOf('/',1)-1));
    return (uri.substr(uri.indexOf('/',1)+1,uri.indexOf('/',1)-1));
    }else{
      return ("");
      //TODO handle the error
     }
};

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

$scope.seoUrl = function seoUrl(name,uri) // Create url parameters from service name and uri
{
if(name && uri){
  

 var lowercase = name.toLowerCase();
 var replaced = lowercase.replace(/ /g, '_');
   replaced = replaced.replace(/-/g, '_');
  return (replaced+'-'+$scope.extractId(uri));
 }
 return ('ERROR');
 
};

$scope.filter = {}; //current properties for faceted search

$scope.filterByProperties = function(service) {
	var matches = true;
	for (var prop in $scope.filter) {
		if (noSubFilter($scope.filter[prop])) continue;
		if (!$scope.filter[prop][service[prop]]) {
			matches = false;
			break;
		}
	}
	return matches;
};

function noSubFilter(subFilterObj) {
        for (var key in subFilterObj) {
            if (subFilterObj[key]) return false;
        }
        return true;
    }


  }
]);
`