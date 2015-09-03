angular.module("frontendApp").controller "ServicesController", [ "$scope", "Services", "$http", "$stateParams", "$state", ($scope, Services, $http, $stateParams, $state) ->

  #$scope.services contain the requested json file from the broker.
  #serviceType contain the selected radio button ex: iaas or saas
  #List of selected checkbox
  #contail the selected service for the detail view
  # contain the current state
  # get the service uri from the url

  #console.log(url.substr(url.indexOf('-',1)+1,url.length));
  # extract the service_id from uri

  #console.log(uri.substr(uri.indexOf('/',1)+1,uri.indexOf('/',1)-1));

  #TODO handle the error
  #if true will disable the compare button
  #if true will disable the checkbox
  #if true will disable the compare button
  # Check if a service model is selected
  # Create url parameters from service name and uri
  #current properties for faceted search
  # Add the service model found in the url to the filter
  noSubFilter = (subFilterObj) ->
    for key of subFilterObj
      return false  if subFilterObj[key]
    true
  $http.defaults.headers.common["Accept"] = "application/json"
  $scope.services = Services.query()
  $scope.type = $stateParams.type
  $scope.checkboxList = []
  $scope.selectedService = ""
  $scope.state = $state
  $scope.getUriFromUrl = (url) ->
    url.substr url.indexOf("-", 1) + 1, url.length

  $scope.extractId = (uri) ->
    if uri
      uri.substr uri.indexOf("/", 1) + 1, uri.indexOf("/", 1) - 1
    else
      ""

  $scope.canNotCompare = ->
    $scope.checkboxList.length < 2

  $scope.canNotSelect = ->
    (not $scope.canNotCompare()) and not (uri is $scope.checkboxList[0].uri or uri is $scope.checkboxList[1].uri)

  $scope.selectService = (service) ->
    $scope.selectedService = service

  window.alert "No service model selected"  unless $scope.type
  $scope.seoUrl = (name, uri) ->
    if name and uri
      lowercase = name.toLowerCase()
      replaced = lowercase.replace(RegExp(" ", "g"), "_")
      replaced = replaced.replace(/-/g, "_")
      return (replaced + "-" + $scope.extractId(uri))
    "ERROR"

  $scope.filter = {}
  unless $scope.filter["model"]
    if $scope.type is "paas"
      $scope.filter["cloud_service_model"] = {}
      $scope.filter["cloud_service_model"]["paas"] = true
    else if $scope.type is "iaas"
      $scope.filter["cloud_service_model"] = {}
      $scope.filter["cloud_service_model"]["iaas"] = true
    else if $scope.type is "saas"
      $scope.filter["cloud_service_model"] = {}
      $scope.filter["cloud_service_model"]["saas"] = true
  $scope.filterByProperties = (service) ->
    matches = true
    console.log $scope.filter
    for prop of $scope.filter
      continue  if noSubFilter($scope.filter[prop])
      unless $scope.filter[prop][service[prop]]
        matches = false
        break
    matches
]