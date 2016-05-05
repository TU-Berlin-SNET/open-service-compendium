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
        $scope.filteredServices = ServiceMatching.updateFilteredServices($scope.selectedValues, $scope.services, $scope.enumerations)

    # # Update the array of filtered Serices
    # # Loop over all available services
    # # 1. If no values are selected for any property, services would be added directly
    # # 2. Else, check if service provide all properties that have selected values
    # # 3. If property provides unique answers, check the service value
    # # 4. Else, wait for the whole loop of selectedValues array to be done,
    # # 5. If one at least is equal to the service's value, add it
    # $scope.updateFilteredServices = (selectedValues) ->
    #     filteredServices = []
    #     for service in $scope.services
    #         addService = true
    #         for selectedValue in selectedValues
    #             # convert property key string to service property format
    #             property = (selectedValue.property.replace(/ /g, "_")).toLowerCase()
    #             if (!service[property])
    #                 addService = false
    #                 break
    #             else
    #                 if (selectedValue.uniqueAnswer)
    #                     if (!$scope.isServiceMatching(service, selectedValue))
    #                         addService = false
    #                         break
    #                 else
    #                     if (!$scope.isServiceMatching(service, selectedValue))
    #                         addService = false
    #                     else
    #                         addService = true
    #                         break
    #         if (addService)
    #             filteredServices.push(service)
    #     return filteredServices

    # When the selection of values for a question/filter property changes,
    # 1. If this question/filter property has unique selection option
    # 1.1. If exists, set previously selected value to false,
    # 1.2. and remove it from the selectedValues array
    # 1.3. Set selected property of the value to true
    # 2. If the property can have multipe values (checkbox)
    # 2.1. If the value is unchecked, remove it from the selectedValues array
    # 3. If a value is selected in any case
    # 3.1.  Add the newly selected value to the selectedValues array
    # 4. Update the number of filtered (rest) services for each value in each property
    # 5. If dynmaic questionnaire, update the list of questions
    # 6. Update the array of filtered services
    # 7. Update the array of shown properties in the filter
    $scope.updateSelection = (properties, property, valueKey) ->
        selected = true
        if (property.uniqueAnswer)
            i = properties.indexOf(property)
            for key, value of properties[i].values
                if (value.selected)
                    value.selected = false
                    j = _.findIndex($scope.selectedValues, {
                        property: property.key
                        value: key
                        uniqueAnswer: property.uniqueAnswer
                    })
                    $scope.selectedValues.splice(j, 1)
            properties[i].values[valueKey].selected = true
        else
            if (!property.values[valueKey].selected)
                selected = false
                j = _.findIndex($scope.selectedValues, {
                    property: property.key
                    value: valueKey
                    uniqueAnswer: property.uniqueAnswer
                })
                $scope.selectedValues.splice(j, 1)
        if (selected)
            $scope.selectedValues.push ({
                property: property.key
                value: valueKey
                uniqueAnswer: property.uniqueAnswer
            })
        for property in properties
            for key, value of property.values
                value.restServices = ServiceMatching.getRestServices(property, key, $scope.selectedValues, $scope.services, $scope.enumerations)
        if ($scope.dynamic)
            $scope.questions = $scope.updateDynamicQuestions()
        $scope.filteredServices = ServiceMatching.updateFilteredServices($scope.selectedValues, $scope.services, $scope.enumerations)
        $scope.updateShownProperties()

    # # Check if service matches value of given property
    # # 1. if the property is not an enumeration
    # # 1.1. if property is "storage properties", check sub-property "max_storage_capacity"
    # # 1.1.1. if selection is infinity and service is not, remove it
    # # 1.1.2. if service value is infinity, it won't be deleted at any case
    # # 1.1.3. if service value is less than selected, remove it (parseInt values)
    # # 1.2. Else check for yes or no answers
    # # 1.2.1. "free trial" property is checked through sub-property "has_free_trial"
    # # 1.2.2. If yes, property should be provided with true value
    # # 1.2.3. If no, property should be either null, false, or not provided at all
    # # 2. If service is an enumeration property
    # # 2.1. if the service doesn't provide the property, remove it
    # # 2.2. If service can have only unique value
    # # 2.2.1. check if service value is equal to the selected
    # # 2.3. If service can have multiple values
    # # 2.3.1. Loop over all service values of the property
    # # 2.3.2. Check if one value value at least is equal to the selected
    # $scope.isServiceMatching = (service, selectedValue) ->
    #     propertyKey = selectedValue.property
    #     value = selectedValue.value
    #     # convert question key string to service property format
    #     property = (propertyKey.replace(/ /g, "_")).toLowerCase()
    #     if (!$scope.enumerations[propertyKey])
    #         if (property == "storage_properties")
    #             if (service[property] == undefined)
    #                 return false
    #             else
    #                 serviceValue = service[property].max_storage_capacity
    #                 if (serviceValue == undefined)
    #                     return false
    #                 else if ((value == "∞") && (String(serviceValue) != value))
    #                     return false
    #                 else
    #                     if (String(serviceValue) != "∞")
    #                         serviceMaxStorage = (String(serviceValue).split(" "))
    #                         iServiceMaxStorage = parseInt(serviceMaxStorage[0])
    #                         if (serviceMaxStorage[1] == "TB")
    #                             iServiceMaxStorage = iServiceMaxStorage * 1000
    #                         selectedMaxStorage = value.split(" ")
    #                         iSelectedMaxStorage = parseInt(selectedMaxStorage[0])
    #                         if (selectedMaxStorage[1] == "TB")
    #                             iSelectedMaxStorage = iSelectedMaxStorage * 1000
    #                         if (iSelectedMaxStorage < iSelectedMaxStorage)
    #                             return false
    #         else
    #             if (value == "Yes")
    #                 if (service[property])
    #                     if ((property == "free_trial") && (service[property]["has_free_trial"]))
    #                         return true
    #                     else if ((property != "free_trial") && (service[property]))
    #                         return true
    #                 else
    #                     return false
    #             else # selected answer is "No"
    #                 if (!service[property])
    #                     return true
    #                 else
    #                     if ((property == "free_trial") && (service[property]["has_free_trial"]))
    #                         return false
    #                     else if ((property != "free_trial") && (service[property]))
    #                         return false
    #     else
    #         # check if property is provided by service
    #         if (service[property] == undefined)
    #             return false
    #         else
    #             if (selectedValue.uniqueAnswer)
    #                 if (String(service[property]) != value.toLowerCase())
    #                     return false
    #             else
    #                 for key, item of service[property]
    #                     if (item == value.toLowerCase())
    #                         return true
    #                 return false
    #     return true

    # Initialize the properties with their values of the filter
    # 1. Add all questions to the filter with their selected values
    # 2. Loop over all enumeration properties
    # 2.1. If enumeration is already a question, skip
    # 2.2. Else, create new filter property with unselected values
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
                    restServices = ServiceMatching.getRestServices(question, key, $scope.selectedValues, $scope.services, $scope.enumerations)
                    values[key] = {
                        selected: value.selected
                        description: value.description
                        restServices : restServices
                    }
            $scope.filterProperties.push({
                "key": question.key
                "uniqueAnswer": question.uniqueAnswer
                "selectedValue": selectedValue
                "values": values
            })
        propertyExists = false
        for key, property of $scope.enumerations
            for question in $scope.questions
                if (key == question.key)
                    propertyExists = true
                    break
            if (propertyExists)
                propertyExists = false
                continue
            else
                isUnique = ServiceMatching.checkIfUniqueValue(key, $scope.rows.enumRows)
                values = {}
                for i, value of property
                    if (!isNaN(i))
                        if (typeof value == "string")
                            values[value] = { "selected": false }
                        else if (typeof value == "object")
                            for j, item of value.description
                                values[j]["description"] = item
                                values[j]["restServices"] = ServiceMatching.getRestServices({
                                    key: key
                                    uniqueAnswer: isUnique
                                }, j, $scope.selectedValues, $scope.services, $scope.enumerations)
                $scope.filterProperties.push({
                    "key": key
                    "uniqueAnswer": isUnique
                    "selectedValue": ""
                    "values": values
                })

    # # Check if a property value is unique, or a service can have multiple values
    # # For the given key of the property, check the statistics
    # # Calculate the summation of each value of the property
    # # If it is more than 100, then services can have multiple values,
    # # and the values are not unique
    # $scope.checkIfUniqueValue = (key) ->
    #     statisticsEnum = $scope.rows.enumRows[key]
    #     overallValue = 0
    #     for value in statisticsEnum
    #         overallValue += value.c[1].v
    #     if (overallValue > 100)
    #         return false
    #     return true

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
            if (selectedValue.property == property.key)
                i = $scope.selectedValues.indexOf(selectedValue)
                $scope.selectedValues.splice(i, 1)
        for filterProperty in $scope.filterProperties
            for key, value of filterProperty.values
                value.restServices = ServiceMatching.getRestServices(filterProperty, key, $scope.selectedValues, $scope.services, $scope.enumerations)
        $scope.filteredServices = ServiceMatching.updateFilteredServices($scope.selectedValues, $scope.services, $scope.enumerations)
        $scope.updateShownProperties()

    # # Get number of filtered (rest) services if a value is selected
    # # 1. Add the given value to a copy of the selected values list
    # # 2. Get the list of filtered services based on the new selected values list
    # # 3. Return the number of services in the list
    # $scope.getRestServices = (property, valueKey) ->
    #     virtualSelectedValues = []
    #     for value in $scope.selectedValues
    #         virtualSelectedValues.push(value)
    #     virtualSelectedValues.push({
    #         property: property.key
    #         value: valueKey
    #         uniqueAnswer: property.uniqueAnswer
    #     })
    #     virtualFilteredServices = $scope.updateFilteredServices(virtualSelectedValues)
    #     return virtualFilteredServices.length
]