angular.module("frontendApp").controller "DynamicQuestionnaireController",
["$scope", "Services", "lodash", "$stateParams", "$log", "$mdDialog"
($scope, Services, _, $stateParams, $log, $mdDialog) ->

    $scope.propertyPercentage = 50
    $scope.uniDistributionRatio = 0.5

    $scope.minYear = parseInt($scope.enumerations["Established In"].values[0])
    $scope.maxYear = parseInt(new Date().getFullYear())
    $scope.establishmentYear = $scope.minYear

    $scope.questionnaireProperties = []

    # Initialize the complete array of properties
    # 1. "Established in" property is execluded since it is one of the 3 questionnaire sliders
    # 2. if property is enumeration and has <= 4 items (e.g. not property of exportable data formats) then
    #   2.1. calculate the uniform distribution ratio from statistics info
    #   2.2. create items array for the property containing its enumerations values
    # 3. otherwise create a property item with its value and selected flag
    $scope.initPropertiesArray = () ->
        $scope.propertiesArray = []
        for key, property of $scope.rows.details.fine
            if (property.c[0].v != "Established In")
                if (($scope.rows.enumRows[property.c[0].v]) && ($scope.rows.enumRows[property.c[0].v].length <= 4))
                    uniDistributionRatio = 1 - $scope.enumerations[property.c[0].v].statisticsInfo["Average Deviation from Uniform Distribution"]
                    uniDistributionRatio = Math.round(uniDistributionRatio * 100) / 100
                    items = []
                    for value in $scope.rows.enumRows[property.c[0].v]
                        items.push({
                            name: value.c[0].v,
                            value: Number(value.c[1].v).toFixed(2)
                            selected: true
                        })
                    $scope.propertiesArray.push({
                        "name": property.c[0].v
                        "value": property.c[1].v
                        "uniDistributionRatio": uniDistributionRatio
                        "items": items
                        "selected": false
                    })
                else
                    $scope.propertiesArray.push({
                        "name": property.c[0].v
                        "value": property.c[1].v
                        "selected": false
                    })

    # Call of the property array initialization method
    $scope.initPropertiesArray()

    # Change displayed properties according to the property percentage value
    $scope.$watch 'propertyPercentage', (newValue, oldValue) ->
        if ((newValue != oldValue) || (newValue))
            $scope.getQuestionnaireProperties(newValue, $scope.uniDistributionRatio)

    # Change displayed properties according to the uniform distribution ratio
    $scope.$watch 'uniDistributionRatio', (newValue, oldValue) ->
        if ((newValue != oldValue) || (newValue))
            $scope.getQuestionnaireProperties($scope.propertyPercentage, newValue)

    # Get filtered properties to be displayed in the questionnaire
    # If the value of the property is >= the property percentage value
    #   1. if property doesn't have uniDistributionRatio, then it can be added directly
    #   2. if it does have, check if it's >= uniform distribution ratio of slider
    $scope.getQuestionnaireProperties = (propertyPercentage, uniDistributionRatio) ->
        $scope.questionnaireProperties = []
        for property in $scope.propertiesArray
            if (property.value >= propertyPercentage) 
                if (!property.uniDistributionRatio) || ((property.uniDistributionRatio) && (property.uniDistributionRatio >= uniDistributionRatio))
                    $scope.questionnaireProperties.push(property)

    # Check if service has all properties filtered by the dynamic questionnaire
    # 1. if there is a property selected:
    # 1.1. if property is not provided by service, false already returnd
    # 1.2. if poprerty is selected, check for its value in the service:
    # 1.2.1. check if this value is selected among the list of values
    # 1.2. if property provided, then iteration is completed with all provided
    # 2. if service provides all checked properties, check the establishment year
    # 3. if no property selected, false should be returned
    $scope.matchToProperties = (service) ->
        propertySelected = false
        for property in $scope.questionnaireProperties
                if (property.selected)
                    propertySelected = true
                    # convert property string to service property format
                    _property = property.name.replace(/ /g, "_")
                    # check if property is provided by service
                    if (service[_property.toLowerCase()] == undefined)
                        return false
                    # check if property is enumeration
                    else if (property.items)
                        for item in property.items
                            # check if property value of the service is selected in values list
                            if ((!item.selected) && (item.name.toLowerCase() == service[_property.toLowerCase()]))
                                return false
        if (propertySelected)
            if ((service.established_in) && (service.established_in < $scope.establishmentYear))
                return false
        propertySelected

    # Property checkbox selection changed
    $scope.onPropertySelChange = (property)->
        if ($scope.questionnaireProperties.indexOf(property) > -1)
            if (property.selected)
                property.selected = false
            else
                property.selected = true

    # Show the list of values of the property
    # 1. Property should be selected
    # 2. If the property has items array, then it's an enumeration property
    $scope.showPropertyValues = (property) ->
        if ((property.selected) && (property.items))
            return true
        return false

    # Show a dialog containing the values of the property
    # Property should have items array (enumeration property)
    # Create dialog and assign items array and property name to locals property
    $scope.getValuesListDialog = (property, ev) ->
        if ((property) && (property.items))
            $mdDialog.show(
                controller: DialogController
                templateUrl: 'valuesList.html'
                parent: angular.element(document.body)
                targetEvent: ev
                locals: {
                    uniDistributionRatio: property.uniDistributionRatio
                    propertyItems: property.items
                    property: property.name
                }
                clickOutsideToClose: true)
            .then ((propertyItems) ->
                for item in propertyItems
                    property.items[propertyItems.indexOf(item)].selected = item.selected
                return
            ), ->
                return
            return
]

# Controller for the dialog of the property values
DialogController = ($scope, $mdDialog, uniDistributionRatio, propertyItems, property) ->
    $scope.uniDistributionRatio = uniDistributionRatio
    $scope.property = property

    # temporary variable to get selected value from propertyItems
    # direct assignment causes changes in the main view before confirmation
    items = []
    for item in propertyItems
        items.push(item.selected)

    $scope.propertyItems = []
    for item in propertyItems
        i = propertyItems.indexOf(item)
        $scope.propertyItems.push({
            name: item.name
            value: item.value
            selected: items[i]
        })

    $scope.hide = () ->
        $mdDialog.hide()

    $scope.cancel = () ->
        $mdDialog.cancel()

    $scope.confirmSelection = () ->
        $mdDialog.hide($scope.propertyItems)
