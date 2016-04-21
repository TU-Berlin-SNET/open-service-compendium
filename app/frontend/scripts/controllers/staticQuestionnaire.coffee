angular.module("frontendApp").controller "StaticQuestionnaireController",
["$scope", "lodash"
($scope, _) ->

    $scope.currentQuestion = "Service Categories"

    $scope.questions = [
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

    # Function call as init
    $scope.getQuestionsValues($scope.questions)

    
    # Navigate to the next question (or skip)
    $scope.showNext = (index) ->
        if (index < $scope.questions.length - 1)
            $scope.currentQuestion = $scope.questions[index + 1].key

    # Navigate back to the previous question
    # Going back should deselect the value of current and previous question
    $scope.showPrev = (index) ->
        if (index > 0)
            $scope.currentQuestion = $scope.questions[index - 1].key
            
]