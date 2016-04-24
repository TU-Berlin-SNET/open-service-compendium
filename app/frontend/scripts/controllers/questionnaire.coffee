angular.module("frontendApp").controller "QuestionnaireController",
["$scope", "$mdDialog", "lodash", ($scope, $mdDialog, _) ->
    
    $scope.static = false
    $scope.dynamic = false
    $scope.filterShown = false
    $scope.filteredServices = $scope.services
    $scope.selectedValues = []
    $scope.questions = []
    $scope.filterProperties = []
    $scope.shownProperties = []
    $scope.filterDroppeddown = false
    $scope.dropdownIcon = "keyboard_arrow_down"
    $scope.currentQuestion = ""

    # Dialog of info button in the main questionnaire view
    $scope.showInfo = () ->
        $mdDialog.show $mdDialog.alert({
            clickOutsideToClose: true
            title: "Info"
            content: "A dynamic selection is a questionnnaire
             based on the statistics of services properties.\n
            A static selection is a questionnaire with no
             dependency on the properties statistics."
            ariaLabel: "Alert Dialog Demo"
            ok: "Got it!"
        }).parent(angular.element(document.querySelector("#questionnnaire")))

    # When the type of questionnaire is shown
    # 1. Show this questionnaire
    # 2. Set the corresponding questions and current question
    $scope.showQuestionnaire = (qType) ->
        if (qType == "dynamic")
            $scope.dynamic = true
            $scope.questions = $scope.getDynamicQuestions()
        else if (qType == "static")
            $scope.static = true
            $scope.questions = $scope.getStaticQuestions()
        $scope.getQuestionsValues($scope.questions)
        $scope.currentQuestion = $scope.questions[0].key

    $scope.updateFilteredServices = () ->
        $scope.filteredServices = []
        for service in $scope.services
            addService = true
            for selectedValue in $scope.selectedValues
                # convert property key string to service property format
                property = (selectedValue.property.replace(/ /g, "_")).toLowerCase()
                if (!service[property])
                    addService = false
                    break
                else
                    if (selectedValue.uniqueAnswer)
                        if (!$scope.isServiceMatching(service, selectedValue.property, selectedValue.value))
                            addService = false
                            break
                    else
                        if (!$scope.isServiceMatching(service, selectedValue.property, selectedValue.value))
                            addService = false
                        else
                            addService = true
                            break
            if (addService)
                $scope.filteredServices.push(service)

    $scope.initFilteredServices = () ->
        $scope.filteredServices = []
        for service in $scope.services
            $scope.filteredServices.push(service)

    # Initialize the list of static questions
    $scope.getStaticQuestions = () ->
        staticQuestions = [
            {
                key: "Service Categories"
                q: "Choose service category"
                uniqueAnswer: true
                values: {}
            },
            {
                key: "Cloud Service Model"
                q: "Choose the cloud service model"
                uniqueAnswer: true
                values: {}
            },
            {
                key: "Payment Options"
                q: "Which payment option should the service provide?"
                uniqueAnswer: false
                values: {}
            },
            {
                key: "Can be used offline"
                q: "Should the cloud service provide offline usage?"
                uniqueAnswer: true
                values: {}
            },
            {
                key: "Free Trial"
                q: "Should the cloud service provide free trial?"
                uniqueAnswer: true
                values: {}
            },
            {
                key: "Storage Properties"
                q: "What is the maximum storage capacity needed?"
                uniqueAnswer: true
                values: {}
            }
        ]
        return staticQuestions

    # Initialize the list of dynamic questions
    $scope.getDynamicQuestions = () ->
        dynamicQuestions = []
        for key, property of $scope.enumerations
            if (property.statisticsInfo["Average Deviation from Uniform Distribution"])
                uniDistributionRatio = 1 - property.statisticsInfo["Average Deviation from Uniform Distribution"]
                uniqueAnswer = $scope.checkIfUniqueValue(key)
                dynamicQuestions.push({
                    key: key
                    q: property.description
                    uniqueAnswer: uniqueAnswer
                    uniDistributionRatio: uniDistributionRatio
                    values: {}
                })
        dynamicQuestions.sort((q1, q2) -> q2.uniDistributionRatio - q1.uniDistributionRatio)
        console.log (dynamicQuestions)
        return dynamicQuestions

    # Get the values of each question
    # 1. If the question key (property) is an enumeration
    # 1.1. Values are stored with numerical keys
    # 1.2. Descriptions of values are stored in an object with numerical key
    # 2. If question key is not an enumeration, but is "storage properties"
    # 2.1. The values of this question are the max storage capacity
    # 3. For any other question
    # 3.1. The answer is yes or no
    $scope.getQuestionsValues = (questions) ->
        for question in questions
            if ($scope.enumerations[question.key])
                for key, value of $scope.enumerations[question.key]
                    if (!isNaN(key))
                        if (typeof value == "string")
                            question.values[value] = { "selected": false }
                        else if (typeof value == "object")
                            for i, item of value.description
                                question.values[i]["description"] = item
            else if (question.key == "Storage Properties")
                question.values = {
                    "10 GB": {
                        "selected": false,
                        "description": "10 GB"
                    },
                    "50 GB": {
                        "selected": false,
                        "description": "50 GB"
                    },
                    "100 GB": {
                        "selected": false,
                        "description": "100 GB"
                    },
                    "1 TB": {
                        "selected": false,
                        "description": "1 TB"
                    },
                    "5 TB": {
                        "selected": false,
                        "description": "5 TB"
                    },
                    "∞": {
                        "selected": false,
                        "description": "Unlimited"
                    }
                }
            else
                question.values = {
                    "Yes": {
                        "selected": false,
                        "description": "Yes"
                    },
                    "No": {
                        "selected": false,
                        "description": "No"
                    }
                }

    # When the selection of values for a question/filter property changes,
    # 1. If this question/filter property has unique selection option
    # 1.1. If exists, set previously selected value to false,
    # 1.2. and remove it from the selectedValues array
    # 1.3. Set selected property of the value to true
    # 2. If the property can have multipe values (checkbox)
    # 2.1. If the value is unchecked, remove it from the selectedValues array
    # 3. If a value is selected in any case
    # 3.1.  Add the newly selected value to the selectedValues array
    # 4. Update the array of shown properties in the filter
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
        $scope.updateFilteredServices()
        $scope.updateShownProperties()

    # Check if service matches value of given property
    # 1. if the property is not an enumeration
    # 1.1. if property is "storage properties", check sub-property "max_storage_capacity"
    # 1.1.1. if selection is infinity and service is not, remove it
    # 1.1.2. if service value is infinity, it won't be deleted at any case
    # 1.1.3. if service value is less than selected, remove it (parseInt values)
    # 1.2. Else check for yes or no answers
    # 1.2.1. "free trial" property is checked through sub-property "has_free_trial"
    # 1.2.2. If yes, property should be provided with true value
    # 1.2.3. If no, property should be either null, false, or not provided at all
    # 2. If service is an enumeration property
    # 2.1. if the service doesn't provide the property, remove it
    # 2.1. if service has the property, but with different value than selected, remove it
    $scope.isServiceMatching = (service, propertyKey, value) ->
        # convert question key string to service property format
        property = (propertyKey.replace(/ /g, "_")).toLowerCase()
        if (!$scope.enumerations[propertyKey])
            if (property == "storage_properties")
                if (service[property] == undefined)
                    return false
                else
                    serviceValue = service[property].max_storage_capacity
                    if (serviceValue == undefined)
                        return false
                    else if ((value == "∞") && (String(serviceValue) != value))
                        return false
                    else
                        if (String(serviceValue) != "∞")
                            serviceMaxStorage = (String(serviceValue).split(" "))
                            iServiceMaxStorage = parseInt(serviceMaxStorage[0])
                            if (serviceMaxStorage[1] == "TB")
                                iServiceMaxStorage = iServiceMaxStorage * 1000
                            selectedMaxStorage = value.split(" ")
                            iSelectedMaxStorage = parseInt(selectedMaxStorage[0])
                            if (selectedMaxStorage[1] == "TB")
                                iSelectedMaxStorage = iSelectedMaxStorage * 1000
                            if (iSelectedMaxStorage < iSelectedMaxStorage)
                                return false
            else
                if (value == "Yes")
                    if (service[property])
                        if ((property == "free_trial") && (service[property]["has_free_trial"]))
                            return true
                        else if ((property != "free_trial") && (service[property]))
                            return true
                    else
                        return false
                else # selected answer is "No"
                    if (!service[property])
                        return true
                    else
                        if ((property == "free_trial") && (service[property]["has_free_trial"]))
                            return false
                        else if ((property != "free_trial") && (service[property]))
                            return false
        else
            # check if property is provided by service
            if (service[property] == undefined)
                return false
            else if (String(service[property]) != value.toLowerCase())
                return false
        return true

    # Navigate to the next question (or skip)
    $scope.showNext = (index) ->
        if (index < $scope.questions.length - 1)
            $scope.currentQuestion = $scope.questions[index + 1].key

    # Navigate back to the previous question
    # Going back should deselect the value of current and previous question
    $scope.showPrev = (index) ->
        if (index > 0)
            $scope.filterShown = false
            $scope.currentQuestion = $scope.questions[index - 1].key
            if (index < $scope.questions.length)
                for key, value of $scope.questions[index].values
                    value.selected = false
            for key, value of $scope.questions[index - 1].values
                value.selected = false

    # Show filter with shown filter properties & filtered cloud services
    $scope.showFilter = () ->
        $scope.filterShown = true
        $scope.getFilterProperties()
        $scope.updateShownProperties()

    # Initialize the properties with their values of the filter
    # 1. Add all questions to the filter with their selected values
    # 2. Loop over all enumeration properties
    # 2.1. If enumeration is already a question, skip
    # 2.2. Else, create new filter property with unselected values
    $scope.getFilterProperties = () ->
        $scope.filterProperties = []
        for question in $scope.questions
            selectedValue = ""
            if (question.uniqueAnswer)
                for key, value of question.values
                    if (value.selected)
                        selectedValue = value.description
                        break
            $scope.filterProperties.push({
                "key": question.key
                "uniqueAnswer": question.uniqueAnswer
                "selectedValue": selectedValue
                "values": question.values
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
                isUnique = $scope.checkIfUniqueValue(key)
                values = {}
                for i, value of property
                    if (!isNaN(i))
                        if (typeof value == "string")
                            values[value] = { "selected": false }
                        else if (typeof value == "object")
                            for j, item of value.description
                                values[j]["description"] = item
                $scope.filterProperties.push({
                    "key": key
                    "uniqueAnswer": isUnique
                    "values": values
                })

    # Check if a property value is unique, or a service can have multiple values
    # For the given key of the property, check the statistics
    # Calculate the summation of each value of the property
    # If it is more than 100, then services can have multiple values,
    # and the values are not unique
    $scope.checkIfUniqueValue = (key) ->
        statisticsEnum = $scope.rows.enumRows[key]
        overallValue = 0
        for value in statisticsEnum
            overallValue += value.c[1].v
        if (overallValue > 100)
            return false
        return true

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
    # 2. Else check if property is a question, if yes, add it to temp. array
    # 3. If there are less than 6 properties shown, add the original questions
    $scope.updateShownProperties = () ->
        $scope.shownProperties = []
        questionsAndUnselected = []
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
                        questionsAndUnselected.push(property.key)
                        break
        for question in questionsAndUnselected
            if ($scope.shownProperties.length < 6)
                $scope.shownProperties.push(question)
            else
                break

    # Toggle show/hide of filter properties
    # 1. Toggle the show/hide boolean
    # 2. Toggle the icon to be up/down
    $scope.toggleDropdown = () ->
        $scope.filterDroppeddown = !$scope.filterDroppeddown
        if ($scope.dropdownIcon == "keyboard_arrow_down")
            $scope.dropdownIcon = "keyboard_arrow_up"
        else if ($scope.dropdownIcon == "keyboard_arrow_up")
            $scope.dropdownIcon = "keyboard_arrow_down"

]