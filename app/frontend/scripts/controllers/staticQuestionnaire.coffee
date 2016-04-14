angular.module("frontendApp").controller "StaticQuestionnaireController",
["$scope"
($scope) ->

    $scope.cloudServiceModels = [
        {
            key: "SaaS"
            value: "Software as a Service",
            description: ""
        },
        {
            key: "PaaS"
            value: "Platform as a Service",
            description: ""
        },
        {
            key: "IaaS"
            value: "Infrastructure as a Service",
            description: ""
        },
        {
            key: "HaaS"
            value: "Hardware as a Service",
            description: ""
        }
    ]

    $scope.serviceCategories = [
        {
            key: "storage",
            value: "Storage",
            description: ""
        },
        {
            key: "vm",
            value: "Virtual Machine",
            description: ""
        }
    ]

    $scope.currentquestion = "csm"

    $scope.questions = {
        "csm" : {
            "show": true,
            "chosenVal": null
        },
        "category": {
            "show": false,
            "chosenVal": null
        },
        "rest": {
            "show": false,
            "chosenVal": null
        }
    }

    $scope.showNext = (chosenVal) ->
        if ($scope.currentquestion == "csm")
            $scope.questions.csm.show = false
            $scope.questions.csm.chosenVal = chosenVal
            $scope.questions.category.show = true
            $scope.currentquestion = "category"
            return
        if ($scope.currentquestion = "category")
            $scope.questions.category.show = false
            $scope.questions.category.chosenVal = chosenVal
            $scope.questions.rest.show = true
            $scope.currentquestion = "rest"
        return

    $scope.showPrev = () ->
        if ($scope.currentquestion == "category")
            $scope.currentquestion = "csm"
            $scope.questions.csm.show = true
            $scope.questions.csm.chosenVal = null
            $scope.questions.category.show = false
            $scope.questions.category.chosenVal = null
            return
        if ($scope.currentquestion == "rest")
            $scope.currentquestion = "category"
            $scope.questions.category.show = true
            $scope.questions.category.chosenVal = null
            $scope.questions.rest.show = false
            $scope.questions.rest.chosenVal = null
        return
            
]