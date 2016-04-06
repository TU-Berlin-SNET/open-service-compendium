angular.module("frontendApp").controller "StatisticsController",
["$scope", "$mdSidenav", "lodash"
($scope, $mdSidenav, _) ->

    $scope.detailed = "Properties Categories"

    # Enumeration radio button is chosen
    $scope.toggleEnum = (option) ->
        $scope.chartObject.data.rows = $scope.rows.enumRows[option]
        $scope.chartObject.options.title = $scope.enumerations[option].description +
            " (" + $scope.enumerations[option].numOfServices + " services)"
        $scope.statisticsInfo = $scope.enumerations[option].statisticsInfo


    $scope.onChange = (value) ->
        if (value == "Enumerations")
            $scope.enumChecked = true
            $scope.chartObject.data.rows = []
            $scope.chartObject.options.title = ""
        else if (value == "Detailed Properties")
            $scope.enumChecked = false
            $scope.chartObject.data.rows = $scope.rows.details.fine
            $scope.chartObject.options.title = "Percentage of detailed properties provided by the current services (" +
                $scope.numOfServices + " services)*"
        else
            $scope.enumChecked = false
            $scope.chartObject.data.rows = $scope.rows.details.rough
            $scope.chartObject.options.title = "Percentage of properties categories provided by the current services (" +
                $scope.numOfServices + " services)*"

    $scope.toggleLeft = () ->
        $mdSidenav("left").toggle()
    
    $scope.isOpenLeft = ->
        $mdSidenav("left").isOpen()

    $scope.closeLeft = ->
        $mdSidenav("left").close()


    $scope.chartObject = {}
    
    $scope.chartObject.type = "ColumnChart"
    
    $scope.chartObject.data =
      cols: [
          id: "p"
          label: "Property"
          type: "string"
      ,
          id: "s"
          label: "Services"
          type: "number"
          ]
      rows: $scope.rows.details.rough


    $scope.chartObject.options =
        title: "Percentage of properties categories provided by the current services (" +
                $scope.numOfServices + " services)*"
        animation:
            duration: 500
            easing: 'linear'
            startup: true
        vAxis:
            viewWindow:
                min: 0
                max: 100

    $scope.chartObject.methods = {
        select: (selection, event) ->
            alert("chartSelect in ctrl, selection: "+selection + " Evt: " + event)
        ready: () ->
            alert("ready")
    }
    
    $scope.chartObject.formatters = number: [{
        columnNum: 1
        suffix: '%'
    }]

]

