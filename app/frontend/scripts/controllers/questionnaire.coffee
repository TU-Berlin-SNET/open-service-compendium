angular.module("frontendApp").controller "QuestionnaireController",
["$scope", "$mdDialog", "ServiceMatching", "lodash", ($scope, $mdDialog, ServiceMatching, _) ->
    
    $scope.static = false
    $scope.dynamic = false
    $scope.categoryChosen = false
    $scope.filteredServices = $scope.services
    $scope.selectedValues = []
    $scope.questions = []
    $scope.dynamicQuestions = []
    $scope.dropdownIcon = "keyboard_arrow_down"
    $scope.currentQuestion = ""

    # Dialog of info button in the main questionnaire view
    $scope.showInfo = () ->
        $mdDialog.show $mdDialog.alert({
            clickOutsideToClose: true
            title: "Info"
            content: "In a dynamic questionnnaire, questions are built dynamically based on the current status of services
            properties and on the user's answer of each question.\n
            A static selection is a questionnaire with no dependency on the properties statistics."
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
                selectedValue: "I don't care"
                values: {}
            },
            {
                key: "Cloud Service Model"
                q: "Choose the cloud service model"
                uniqueAnswer: true
                selectedValue: "I don't care"
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
                selectedValue: "I don't care"
                values: {}
            },
            {
                key: "Free Trial"
                q: "Should the cloud service provide free trial?"
                uniqueAnswer: true
                selectedValue: "I don't care"
                values: {}
            },
            {
                key: "Storage Properties"
                q: "What is the maximum storage capacity needed?"
                uniqueAnswer: true
                selectedValue: "I don't care"
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
            if (property.statisticsInfo["Average Deviation from Uniform Distribution"])
                uniqueAnswer = ServiceMatching.checkIfUniqueValue(key, $scope.rows.enumRows)
                uniDistributionRatio = 1 - property.statisticsInfo["Average Deviation from Uniform Distribution"]
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
        return $scope.dynamicQuestions

    # Get the values of each question
    # 1. If the question key (property) is an enumeration
    # 1.1. Values are stored with numerical keys
    # 1.2. Descriptions of values are stored in an object with numerical key
    # 1.3. If question can have only unique value, add a value of "I don't care"
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
                        "description": "I don't care"
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
                        "description": "I don't care"
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
                    },
                    "None": {
                        "selected": true,
                        "description": "I don't care"
                    }
                }
            if (question.values.None)
                question.selectedValue = "I don't care"
            for key, value of question.values
                if (key != "None")
                    restServices = ServiceMatching.getRestServices(
                        question, key, $scope.selectedValues, $scope.services, $scope.enumerations)
                    value["restServices"] = restServices

    # Update the list of questions to be shown based on values' selection
    # 1. If no values are selected, start with the initialized array of dynamic questions
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
        questionSelected = false
        qIndex = 0
        if ($scope.selectedValues.length == 0)
            return $scope.dynamicQuestions[0]
        for question in $scope.dynamicQuestions
            for selectedValue in $scope.selectedValues
                if (question.key == selectedValue.property)
                    questionSelected = true
                    break
            if (questionSelected)
                questions.push(question)
                questionSelected = false
                qIndex++
            else
                break
        while ($scope.questions.indexOf($scope.dynamicQuestions[qIndex]) >= 0)
            questions.push($scope.dynamicQuestions[qIndex])
            qIndex++
        propertyProvided = false
        while ((qIndex < $scope.dynamicQuestions.length - 1) && (qIndex < 7) && (!propertyProvided))
            question = $scope.dynamicQuestions[qIndex]
            # convert question key string to service property format
            property = (question.key.replace(/ /g, "_")).toLowerCase()
            for service in $scope.filteredServices
                if (service[property])
                    questions.push(question)
                    propertyProvided = true
                    break
            qIndex++
        return questions

    # When the selection of values for a question property changes,
    # 1. Get the updated array of selected values by calling service method
    # 2. Update the number of filtered (rest) services for each value in each property
    # 3. If dynmaic questionnaire, update the list of questions
    # 4. Update filtered service according to selected values
    $scope.updateSelection = (questions, question, valueKey) ->
        $scope.selectedValues = ServiceMatching.updateSelection(
            $scope.selectedValues, questions, question, valueKey)
        if ($scope.dynamic)
            $scope.questions = $scope.updateDynamicQuestions()
        for q in $scope.questions
            for key, value of q.values
                if (key != "None")
                    value.restServices = ServiceMatching.getRestServices(
                        q, key, $scope.selectedValues, $scope.services, $scope.enumerations)
        $scope.filteredServices = ServiceMatching.updateFilteredServices(
            $scope.selectedValues, $scope.services, $scope.enumerations)

    # Navigate to the next question (or skip)
    $scope.showNext = (index) ->
        if (($scope.dynamic) && (index == $scope.questions.length - 1))
            $scope.questions = $scope.updateDynamicQuestions()
            console.log ($scope.questions)
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
                if ($scope.dynamic)
                    $scope.questions.splice(index, 1)
            if (index == 1)
                $scope.categoryChosen = false
            $scope.removeSelectedQuestion($scope.questions[index].key)
            $scope.filteredServices = ServiceMatching.updateFilteredServices(
                $scope.selectedValues, $scope.services, $scope.enumerations)

    # For a given question key, remove all values selected of this question
    $scope.removeSelectedQuestion = (questionKey) ->
        for selectedValue in $scope.selectedValues
            if (selectedValue.property == questionKey)
                index = $scope.selectedValues.indexOf(selectedValue)
                $scope.selectedValues.splice(index, 1)

]