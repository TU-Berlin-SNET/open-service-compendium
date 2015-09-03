angular.module('frontendApp').controller 'compareCtrl', ['$scope', '$filter','$stateParams', ($scope, $filter, $stateParams) ->

    $scope.id = $scope.getUriFromUrl($stateParams.id)

    $scope.other_id = $scope.getUriFromUrl($stateParams.other_id)

    #if refresh or direct access wait for the callback to get and fetch the json and put the selected services (based on uri's) in $scope.checkboxlist
    if !$scope.checkboxList[0] and !$scope.checkboxList[1]
      $scope.services.$promise.then (data) ->
        i = 0
        while i < $scope.services.length
          if $scope.extractId(data[i].uri) == $scope.id or $scope.extractId(data[i].uri) == $scope.other_id
            $scope.checkboxList.push data[i]
          i++

        $scope.selectedProperties = [
          'uri'
          'cloud_service_model'
          'is_billed'
        ]

        $scope.properties = []

        # get all possible property keys
        for key of $scope.checkboxList[0]
          $scope.properties.push key

        # add selected property to properties selection
        $scope.addProperty = ->
          $scope.selectedProperties.push $scope.select

    # Check for errors
    $scope.error_message = null

    # Check if we found two services
    if $scope.checkboxList.length != 2

    else if $scope.checkboxList[0].cloud_service_model != $scope.checkboxList[1].cloud_service_model
      $scope.error_message = 'You are comparing two different service models!'
    else if $scope.extractId($scope.checkboxList[0].uri) != $scope.getUriFromUrl($scope.id) or $scope.extractId($scope.checkboxList[1].uri) != $scope.getUriFromUrl($scope.other_id)
      $scope.error_message = 'ERROR !'
      # redirect to home

    # dynamic property selection
    $scope.selectedProperties = [
      'uri'
      'cloud_service_model'
      'is_billed'
    ]

    $scope.properties = []

    # get all possible property keys
    for key of $scope.checkboxList[0]
      $scope.properties.push key
    # add selected property to properties selection

    $scope.addProperty = ->
      if $scope.selectedProperties.indexOf($scope.select) == -1
        $scope.selectedProperties.push $scope.select
]