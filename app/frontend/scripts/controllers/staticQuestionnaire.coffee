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
]