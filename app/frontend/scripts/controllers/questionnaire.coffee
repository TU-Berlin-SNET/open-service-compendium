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

    # For questions/filterProperties with unique selection option(radio button),
    # set selected property of the value to true
    $scope.addSelection = (properties, property, valueKey) ->
        i = properties.indexOf(property)
        properties[i].values[valueKey].selected = true
        $scope.getShownProperties()

    # Find matching services to selected values of questions
    # 1. if no value is selected (question skipped)
    # 1.1. keep all services
    # 2. if some value is selected
    # 2.1. if the service doesn't provide the property, remove it
    # 2.2. if property is "storage properties", check sub-property "max_storage_capacity"
    # 2.2.1. if selection is infinity and service is not, remove it
    # 2.2.2. if service value is infinity, it won't be deleted at any case
    # 2.2.3. if service value is less than selected, remove it (parseInt values)
    # 2.3. if service has the property, but with different value than selected, remove it
    $scope.matchServices = (service) ->
        for question in $scope.questions
            for key, value of question.values
                if (value.selected)
                    # convert question key string to service property format
                    property = question.key.replace(/ /g, "_")
                    property = property.toLowerCase()
                    # check if property is provided by service
                    if (service[property] == undefined)
                        return false
                    else
                        if (property == "storage_properties")
                            serviceValue = service[property].max_storage_capacity
                            if (serviceValue == undefined)
                                return false
                            else if ((key == "∞") && (String(serviceValue) != key))
                                return false
                            else
                                if (String(serviceValue) != "∞")
                                    serviceMaxStorage = (String(serviceValue).split(" "))
                                    iServiceMaxStorage = parseInt(serviceMaxStorage[0])
                                    if (serviceMaxStorage[1] == "TB")
                                        iServiceMaxStorage = iServiceMaxStorage * 1000
                                    selectedMaxStorage = key.split(" ")
                                    iSelectedMaxStorage = parseInt(selectedMaxStorage[0])
                                    if (selectedMaxStorage[1] == "TB")
                                        iSelectedMaxStorage = iSelectedMaxStorage * 1000
                                    if (iSelectedMaxStorage < iSelectedMaxStorage)
                                        return false
                        else if (String(service[property]) != key.toLowerCase())
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
        $scope.getShownProperties()

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
    $scope.getShownProperties = () ->
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