angular.module("frontendApp").controller "QuestionnaireController",
["$scope", "$mdDialog", "ServiceMatching", "lodash", ($scope, $mdDialog, ServiceMatching, _) ->
    
    $scope.static = false
    $scope.dynamic = false
    $scope.categoryChosen = false
    $scope.filteredServices = $scope.services
    $scope.selectedValues = []
    $scope.questions = []
    $scope.dynamicQuestions = []
    $scope.currentQuestion = ""
    $scope.dynamicQuestionsDone = false
    $scope.nextButtonIcon = "keyboard_arrow_right"
    $scope.backButtonIcon = "keyboard_arrow_left"

    # Dialog of info button in the main questionnaire view
    $scope.showInfo = () ->
        $mdDialog.show $mdDialog.alert({
            clickOutsideToClose: true
            title: "Info"
            content: "In a dynamic questionnnaire, questions are built dynamically based on the current status of services
            properties and on the user's answer of each question.\n
            Static questions have no dependency on the properties statistics, nor on the user's answers."
            ariaLabel: "Alert Dialog Demo"
            ok: "Got it!"
        }).parent(angular.element(document.querySelector("#questionnnaire")))

    # When the type of questionnaire is shown
    # 1. Show this questionnaire
    # 2. Set the corresponding questions and current question
    $scope.showQuestionnaire = (qType) ->
        if (qType == "dynamic")
            $scope.dynamic = true
            $scope.getDynamicQuestions()
            $scope.getQuestionsValues($scope.dynamicQuestions)
            $scope.questions.push($scope.dynamicQuestions[0])
        else if (qType == "static")
            $scope.static = true
            $scope.questions = $scope.getStaticQuestions()
        $scope.getQuestionsValues($scope.questions)
        $scope.currentQuestion = $scope.questions[0].key

    # Set the value of the chosen category and begin the questionnaire
    $scope.setServiceCategory = (category) ->
        $scope.categoryChosen = category
        $scope.updateSelection($scope.questions, $scope.questions[0], category)
        if (category == "storage")
            $scope.questions[0].selectedValue = "Storage"
        else if (category == "vm")
            $scope.questions[0].selectedValue = "Virtual Machine"
        $scope.showNext(0)

    # Initialize the list of static questions
    $scope.getStaticQuestions = () ->
        staticQuestions = [
            {
                key: "Service Categories"
                q: "Choose service category"
                uniqueAnswer: true
                selectedValue: "It doesn't matter"
                values: {}
            },
            {
                key: "Cloud Service Model"
                q: "Choose the cloud service model"
                uniqueAnswer: true
                selectedValue: "It doesn't matter"
                values: {}
            },
            {
                key: "Payment Options"
                q: "Which payment option should the service provide?"
                uniqueAnswer: false
                selectedValue: ""
                values: {}
            },
            {
                key: "Can be used offline"
                q: "Should the cloud service provide offline usage?"
                uniqueAnswer: true
                selectedValue: "It doesn't matter"
                values: {}
            },
            {
                key: "Free Trial"
                q: "Should the cloud service provide free trial?"
                uniqueAnswer: true
                selectedValue: "It doesn't matter"
                values: {}
            },
            {
                key: "Storage Properties"
                q: "What is the maximum storage capacity needed?"
                uniqueAnswer: true
                selectedValue: "It doesn't matter"
                values: {}
            }
        ]
        return staticQuestions

    # Initialize the list of dynamic questions
    $scope.getDynamicQuestions = () ->
        $scope.dynamicQuestions = [{
            key: "Service Categories"
            q: "Choose Service Category"
            uniqueAnswer: true
            selectedValue: ""
            values: {}
        }]
        for key, property of $scope.enumerations
            if (key == "Service Categories")
                continue
            if (property.statisticsInfo["Uniform Distribution Ratio"])
                uniqueAnswer = ServiceMatching.checkIfUniqueValue(key, $scope.rows.enumRows)
                uniDistributionRatio = property.statisticsInfo["Uniform Distribution Ratio"]
                providenceRatio = property.numOfServices / $scope.services.length
                rating = (uniDistributionRatio / 2) + (providenceRatio / 2)
                $scope.dynamicQuestions.push({
                    key: key
                    q: property.description
                    selectedValue: ""
                    uniqueAnswer: uniqueAnswer
                    rating: rating
                    uniDistributionRatio: uniDistributionRatio
                    providenceRatio: providenceRatio
                    values: {}
                })
        # Sort the questions in descending order according to the rating value
        $scope.dynamicQuestions.sort((q1, q2) ->
            q2.rating - q1.rating)

    # Get the values of each question
    # 1. If the question key (property) is an enumeration
    # 1.1. Values are stored with numerical keys
    # 1.2. Descriptions of values are stored in an object with numerical key
    # 1.3. If question can have only unique value, add a value of "It doesn't matter"
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
                if (ServiceMatching.checkIfUniqueValue(question.key, $scope.rows.enumRows))
                    question.values["None"] = {
                        "selected": true,
                        "description": "It doesn't matter"
                    }
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
                    },
                    "None": {
                        "selected": true,
                        "description": "It doesn't matter"
                    }
                }
            else
                question.values = {
                    "Yes": {
                        "selected": false,
                        "description": "Yes"
                    },
                    "None": {
                        "selected": true,
                        "description": "It doesn't matter"
                    }
                }
            if (question.values.None)
                question.selectedValue = "It doesn't matter"
            for key, value of question.values
                restServices = ServiceMatching.getRestServices(question,
                    key, $scope.selectedValues, $scope.services, $scope.enumerations)
                value["restServices"] = restServices

    # Update the list of questions to be shown based on values' selection
    # 1. If no values are selected, start with the first element in the linitialized array of dynamic questions
    # 2. Else, loop over the array of dynamic questions
    # 2.1. Loop over the array of selected values
    # 2.2. If the question is already in the selected values array, 
    # 2.2.1. add this question to the list, because it's a previous question
    # 2.3. If the question is not in the selected values array,
    # 2.3.1. break the loop (save index)
    # 3. Check if question is in the general questions list 
    # 3.1. If yes, this means the question was skipped with no selected answer
    # 3.2. Push this question to the resulting list, and increment the index
    # 4. Loop over dynamic questions starting from index, while index is < 7,
    # and no service provide the property of the considered question
    # 5. If all filtered services provide the question property, add question to the list
    # 6. Else, dismiss it and check the next
    $scope.updateDynamicQuestions = () ->
        questions = []
        qIndex = 0
        if ($scope.selectedValues.length == 0)
            return $scope.dynamicQuestions[0]
        for question in $scope.dynamicQuestions
            questionSelected = false
            for selectedValue in $scope.selectedValues
                if (question.key == selectedValue.property)
                    questionSelected = true
                    break
            if (questionSelected)
                questions.push(question)
                questionSelected = false
                qIndex++
            else if ($scope.questions.indexOf(question) >= 0)
                questions.push(question)
                qIndex++
            else if (questions.length < $scope.questions.length)
                qIndex++
                continue
            else
                break
        propertyProvided = false
        while ((qIndex < $scope.dynamicQuestions.length - 1) && (questions.length < 6) && (!propertyProvided))
            question = $scope.dynamicQuestions[qIndex]
            # convert question key string to service property format
            property = (question.key.replace(/ /g, "_")).toLowerCase()
            valueProvided = null
            for service in $scope.filteredServices
                if (service[property] && !valueProvided)
                    valueProvided = service[property]
                    if (typeof valueProvided == "object")
                        itemsNum = 0
                        for key, item of valueProvided
                            itemsNum++
                        if (itemsNum > 1)
                            questions.push(question)
                            propertyProvided = true
                            break
                    continue
                if (serviceProvidesDiffValue(valueProvided, service[property]))
                    questions.push(question)
                    propertyProvided = true
                    break
            qIndex++
        if ($scope.questions.length == questions.length)
            $scope.dynamicQuestionsDone = true
        else
            $scope.dynamicQuestionsDone = false
        return questions

    # For the dynamic functionality, in a question two values should be at least provided
    # check if the value already provided is different that a service value
    serviceProvidesDiffValue = (value, serviceValue) ->
        if (value && serviceValue)
            if ((typeof value == "string") && (typeof serviceValue == "string") && (value != serviceValue))
                return true
            else if ((typeof value == "object") && (typeof serviceValue == "object"))
                for serviceKey, serviceItem of serviceValue
                    for valueKey, valueItem of value
                        if (serviceItem != valueItem)
                            return true
        return false

    # When the selection of values for a question property changes,
    # 1. Get the updated array of selected values by calling service method
    # 2. If dynmaic questionnaire, update the list of questions
    # 3. Update filtered service according to selected values
    # 4. Update the number of filtered (rest) services for each value in each property
    $scope.updateSelection = (questions, question, valueKey) ->
        $scope.selectedValues = ServiceMatching.updateSelection(
            $scope.selectedValues, questions, question, valueKey)
        $scope.filteredServices = ServiceMatching.updateFilteredServices(
            $scope.selectedValues, $scope.services, $scope.enumerations)
        if ($scope.dynamic)
            $scope.questions = $scope.updateDynamicQuestions()
        for q in $scope.questions
            for key, value of q.values
                value.restServices = ServiceMatching.getRestServices(
                    q, key, $scope.selectedValues, $scope.services, $scope.enumerations)

    # Navigate to the next question (or skip)
    $scope.showNext = (index) ->
        if (index == 0)
            $scope.categoryChosen = true
        if (($scope.dynamic) && (index == $scope.questions.length - 1))
            $scope.questions = $scope.updateDynamicQuestions()
            for q in $scope.questions
                for key, value of q.values
                    value.restServices = ServiceMatching.getRestServices(
                        q, key, $scope.selectedValues, $scope.services, $scope.enumerations)
        if ((index < $scope.questions.length - 1) && (index < 6))
            $scope.currentQuestion = $scope.questions[index + 1].key

    # Navigate back to the previous question
    # 1. Change the value of the current question
    # 2. If questionnaire is static, deselct values of current question
    # 3. If questionnaire is dynamic, remove current question from list
    # 4. Remove selection from selectedValues array of current question
    # 5. Update filtered services
    $scope.showPrev = (index) ->
        if (index > 0)
            $scope.currentQuestion = $scope.questions[index - 1].key
            if (index < $scope.questions.length)
                if ($scope.static)
                    for key, value of $scope.questions[index].values
                        value.selected = false
            if (index == 1)
                $scope.categoryChosen = false
            $scope.removeSelectedQuestion($scope.questions[index].key)
            if ($scope.dynamic)
                $scope.questions.splice(index, 1)
            $scope.filteredServices = ServiceMatching.updateFilteredServices(
                $scope.selectedValues, $scope.services, $scope.enumerations)
            $scope.dynamicQuestionsDone = false

    # For a given question key, remove all values selected of this question
    $scope.removeSelectedQuestion = (questionKey) ->
        for selectedValue in $scope.selectedValues
            if (selectedValue.property == questionKey)
                index = $scope.selectedValues.indexOf(selectedValue)
                $scope.selectedValues.splice(index, 1)

]