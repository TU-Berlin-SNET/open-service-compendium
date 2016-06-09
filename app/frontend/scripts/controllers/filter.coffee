angular.module("frontendApp").controller "FilterController",
["$scope", "$stateParams", "$mdDialog", "ServiceMatching", "lodash",
($scope, $stateParams, $mdDialog, ServiceMatching, _) ->

    $scope.filteredServices = $scope.services
    $scope.selectedValues = $stateParams.selectedValues
    $scope.questions = $stateParams.questions
    $scope.filterProperties = []
    $scope.shownProperties = []
    $scope.filterDroppeddown = false
    $scope.dropdownIcon = "keyboard_arrow_down"
    $scope.currentQuestion = ""


    # Show filter with shown filter properties & filtered cloud services
    $scope.showFilter = () ->
        $scope.getFilterProperties()
        $scope.updateShownProperties()
        $scope.filteredServices = ServiceMatching.updateFilteredServices(
            $scope.selectedValues, $scope.services, $scope.enumerations)

    # When the selection of values for a question property changes,
    # 1. Get the updated array of selected values by calling service method
    # 2. Update the number of filtered (rest) services for each value in each property
    # 3. Update filtered service according to selected values
    # 4. Update the array of shown properties in the filter
    $scope.updateSelection = (properties, property, valueKey) ->
        $scope.selectedValues = ServiceMatching.updateSelection(
            $scope.selectedValues, properties, property, valueKey)
        for p in properties
            for key, value of p.values
                if (key != "None")
                    value.restServices = ServiceMatching.getRestServices(
                        p, key, $scope.selectedValues, $scope.services, $scope.enumerations)
        $scope.filteredServices = ServiceMatching.updateFilteredServices(
            $scope.selectedValues,$scope.services, $scope.enumerations)
        $scope.updateShownProperties()

    # Initialize the properties with their values of the filter
    # 1. Add all questions to the filter with their selected values
    # 2. Loop over all properties
    # 2.1. If property is enumeration
    # 2.1.1. If enumeration is "Established in", special case to create filter property
    # 2.1.2. If enumeration is already a question, skip
    # 2.1.3. Else, create new filter property with unselected values
    # 2.2. Else if property is either a string or a boolean
    # 2.2.1 Create a new filter property with single "yes" option
    $scope.getFilterProperties = () ->
        $scope.filterProperties = []
        for question in $scope.questions
            selectedValue = ""
            values = {}
            for key, value of question.values
                if (key == "None")
                    continue
                else
                    if (value.selected)
                        selectedValue = value.description
                    values[key] = value
            $scope.filterProperties.push({
                "key": question.key
                "uniqueAnswer": question.uniqueAnswer
                "selectedValue": selectedValue
                "values": values
            })
        for key, property of $scope.propertiesDetails
            titleKey = $scope.toTitleCase(key)
            if ($scope.enumerations[titleKey])
                enumProperty = $scope.enumerations[titleKey]
                if (titleKey == "Established In")
                    values = {}
                    for column in enumProperty.columns
                        restServices = ServiceMatching.getRestServices({
                            "key": titleKey
                            "uniqueAnswer": true
                        }, column.title, $scope.selectedValues, $scope.services, $scope.enumerations)
                        values[column.title] = {
                            "description": column.title
                            "selected": false
                            "restServices": restServices
                        }
                    $scope.filterProperties.push({
                        "key": titleKey
                        "uniqueAnswer": true
                        "selectedValue": ""
                        "values": values
                    })
                    continue
                if (propertyIsQuestion(titleKey))
                    continue
                else
                    isUnique = ServiceMatching.checkIfUniqueValue(titleKey, $scope.rows.enumRows)
                    values = {}
                    enumDefined = true
                    for i, value of enumProperty
                        if (!isNaN(i))
                            if (typeof value == "string")
                                values[value] = { "selected": false }
                            else if (typeof value == "object")
                                for j, item of value.description
                                    if (item == "Translate")
                                        values[j]["description"] = $scope.toTitleCase(j)
                                    else
                                        values[j]["description"] = item
                                    values[j]["restServices"] = ServiceMatching.getRestServices({
                                        "key": titleKey
                                        "uniqueAnswer": isUnique
                                    }, j, $scope.selectedValues, $scope.services, $scope.enumerations)
                    if (enumDefined)
                        $scope.filterProperties.push({
                            "key": titleKey
                            "uniqueAnswer": isUnique
                            "selectedValue": ""
                            "values": values
                        })
            else if (property.type && ((property.type == "string") || (property.type == "boolean")))
                restServices = ServiceMatching.getRestServices({
                        "key": titleKey
                        "uniqueAnswer": true
                    }, "Yes", $scope.selectedValues, $scope.services, $scope.enumerations)
                if (restServices > 0)
                    $scope.filterProperties.push({
                        "key": titleKey
                        "uniqueAnswer": true
                        "selectedValue": ""
                        values: {
                            "Yes": {
                                "selected": false
                                "description": "Yes"
                                "restServices": restServices
                            }
                        }
                    })

    propertyIsQuestion = (key) ->
       for question in $scope.questions
            if (key == question.key)
                return true
        return false

    # Check if property should be shown or hidden
    # If dropdown button is clicked, all properties should be shown
    # Else, show it if it is in the array of properties to show
    $scope.isInShownProperties = (property) ->
        if ($scope.filterDroppeddown)
            return true
        for shownProperty in $scope.shownProperties
            if (property.key == shownProperty)
                return true
        return false

    # Check which properties should be shown or hidden
    # In the filter, no more 6 properties should be shown,
    # unless property has selected value(s), or dropdown icon pressed
    # 1. If property has selected values, show it directly
    # 2. Else if questionnaire is static
    # 2.1. check if property is a question, if yes, add it to temp. array
    # 3. If questionnaire is dynamic, check the dynamic questions array
    # 3. If there are less than 6 properties shown,
    # 3.1. add the original questions if available
    # 3.2. or add from filter properties
    $scope.updateShownProperties = () ->
        $scope.shownProperties = []
        unselected = []
        hasPropertySelected = false
        for property in $scope.filterProperties
            for key, value of property.values
                if (value.selected)
                    $scope.shownProperties.push(property.key)
                    hasPropertySelected = true
                    break
            if (hasPropertySelected)
                hasPropertySelected = false
                continue
            else
                for question in $scope.questions
                    if (property.key == question.key)
                        unselected.push(property.key)
                        break
        i = 0
        while ($scope.shownProperties.length < 6)
            if (unselected[i])
                $scope.shownProperties.push(unselected[i])
            else
                if ($scope.shownProperties.indexOf($scope.filterProperties[i].key) < 0)
                    $scope.shownProperties.push($scope.filterProperties[i].key)
            i++

    # Toggle show/hide of filter properties
    # 1. Toggle the show/hide boolean
    # 2. Toggle the icon to be up/down
    $scope.toggleDropdown = () ->
        $scope.filterDroppeddown = !$scope.filterDroppeddown
        if ($scope.dropdownIcon == "keyboard_arrow_down")
            $scope.dropdownIcon = "keyboard_arrow_up"
        else if ($scope.dropdownIcon == "keyboard_arrow_up")
            $scope.dropdownIcon = "keyboard_arrow_down"

    # For questions/properties with unique answers/values,
    # clear selection of correspoding radio buttons
    $scope.clearSelection = (property) ->
        for key, value of property.values
            value.selected = false
        property.selectedValue = ""
        for selectedValue in $scope.selectedValues
            if ((selectedValue) && (selectedValue.property == property.key))
                i = $scope.selectedValues.indexOf(selectedValue)
                $scope.selectedValues.splice(i, 1)
        for filterProperty in $scope.filterProperties
            for key, value of filterProperty.values
                value.restServices = ServiceMatching.getRestServices(filterProperty, key, $scope.selectedValues, $scope.services, $scope.enumerations)
        $scope.filteredServices = ServiceMatching.updateFilteredServices($scope.selectedValues, $scope.services, $scope.enumerations)
        $scope.updateShownProperties()

]