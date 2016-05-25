angular.module("frontendApp").controller "InfoController",
["$scope", "lodash"
($scope, _) ->

    $scope.statisticsOptions = []

    propertiesDetails = {}

    propertiesCategories = {}
    servicesPerProperty = {} # number of services per each (detailed) property

    $scope.rows = {
        details: {
            rough: [],
            fine: []
            },
        enumRows : {
        }
    }
    $scope.enumerations = {}
    $scope.numOfServices = 0 # overall number of services in system

    # Initialize the propertiesDetails variable and propertiesCategories
    # Basically propertiesDetails is the schema with deleted properties
    $scope.$watch 'schema', (newValue, oldValue) ->
        if ((oldValue != newValue) || (!_.isEmpty(oldValue)))
            propertiesDetails = newValue.properties
            delete propertiesDetails.service_name
            delete propertiesDetails.provider
            propertiesCategories = newValue.propertyCategories
            uncheckCategories()
            setEnumerations(propertiesDetails)

    $scope.$watch 'services', (newValue, oldValue) ->
        if ((oldValue != newValue) || (!_.isEmpty(oldValue)))
            # Reset number of services per category to zero
            for key, category of propertiesCategories
                category.numOfServices = 0
                # If description missing, use category name
                if (!category.description)
                    category.description = toTitleCase(key)

            # Loop over all services
            for service in newValue
                $scope.numOfServices++
                uncheckCategories() # reset checked value of each category to false

                # Loop over all properties of the service
                for property, value of service
                    addPropertyToCategory(property)
                    if (propertiesDetails[property])
                        propertyName = toTitleCase(property)
                        servicesPerProperty[propertyName]++
                    if ($scope.enumerations[toTitleCase(property)])
                        title = toTitleCase(property)
                        $scope.enumerations[title].numOfServices++
                        if (!isNaN(value))
                            $scope.enumerations[title].values.push(parseInt(value))
                        else if (Array.isArray(value))
                            for subValue in value
                                if (!$scope.enumerations[title][subValue])
                                    $scope.enumerations[title][subValue] = 1
                                else
                                    $scope.enumerations[title][subValue]++
                        else
                            if (!$scope.enumerations[title][value])
                                $scope.enumerations[title][value] = 1
                            else
                                $scope.enumerations[title][value]++
            createEnumCharts()
            createPropertiesCharts()
    
    # Converts string to title case
    toTitleCase = (s) ->
        temp = s.replace(/_/g, " ")
        title = temp.replace(/\w\S*/g, (txt) ->
            txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase())
        title

    # Increment number of services in the category of the given property
    # Increment only if the correspoding category has not been incremented for the property service yet (not checked)
    addPropertyToCategory = (property) ->
        for key, category of propertiesCategories
            if ((category.properties[property]) && (!category.checked))
                category.checked = true
                category.numOfServices++

    # Reset the checked value of each category to false
    # The goal of the check property is to prevent multiple increments of nr. of services
    # for the same service when properties belong to same category
    uncheckCategories = () ->
        for key, category of propertiesCategories
            if ((category.checked == undefined) || (category.checked))
                category.checked = false

    # Set the enumeration object which contains all enumerations of properties
    # Loop over all properties
    # 1. If property object has "enum" or "items" property with "items.enum", then it's an enumeration
    # 1.1. Add the values to the enumerations object
    # 2. If property value is number, then an enumeration is to be later created
    # 3. Add necessary properties to enumerations object
    setEnumerations = (properties) ->
        isEnum = false
        if (properties)
            for key, value of properties
                servicesPerProperty[toTitleCase(key)] = 0
                # 1
                if ((value.enum) || ((value.items) && (value.items.enum)))
                    isEnum = true
                    # 1.1
                    if (value.enum)
                        $scope.enumerations[toTitleCase(key)] = value.enum
                    else if ((value.items) && (value.items.enum))
                        $scope.enumerations[toTitleCase(key)] = value.items.enum
                # 2
                else if (value.type == "number")
                    isEnum = true
                    $scope.enumerations[toTitleCase(key)] = {}
                    $scope.enumerations[toTitleCase(key)].values = []
                if (isEnum)
                    isEnum = false
                    # 3
                    $scope.enumerations[toTitleCase(key)].numOfServices = 0
                    $scope.enumerations[toTitleCase(key)].description = value.description
                    $scope.enumerations[toTitleCase(key)].statisticsInfo = {}
                    if (!$scope.statisticsOptions)
                        $scope.statisticsOptions = []
                    $scope.statisticsOptions.push(toTitleCase(key))

    # For properties with nummerical values, distribute the range into four quarters
    # In this case, this property can be considered as a property with four enumeration values
    getDistribution = (enumVal) ->
        enumVal.values.sort((a, b) -> a - b)  #sort the values in ascending  order
        hightestVal = enumVal.values[enumVal.values.length - 1]
        smallestVal = enumVal.values[0]
        diff = hightestVal - smallestVal
        range = Math.round(diff / 4)

        enumVal.columns = [
            { "title" : "Before " + (smallestVal + range), "v" : 0 }
            { "title" : (smallestVal + range) + " - " + (smallestVal + 2*range), "v" : 0}
            { "title" : (smallestVal + 2*range) + " - " + (smallestVal + 3*range), "v" : 0}
            { "title" : "After " + (smallestVal + 3*range), "v" : 0}
        ]

        for value in enumVal.values
            if (value < (smallestVal + range))
                enumVal.columns[0].v++
            else if (value < (smallestVal + 2*range))
                enumVal.columns[1].v++
            else if (value < (smallestVal + 3*range))
                enumVal.columns[2].v++
            else
                enumVal.columns[3].v++

    # Loop over all properties enumerations to create the rows of each's chart 
    # and to calucualte statistical info
    createEnumCharts = () ->
        for i, enumValue of $scope.enumerations
            $scope.rows.enumRows[i] = []
            # enum refers to a value property
            if (enumValue.values)
                # Distribute the values of this property among 4 groups    
                getDistribution(enumValue)
                for col in enumValue.columns
                    $scope.rows.enumRows[i].push({
                        c: [
                            {v: col.title}
                            {v: col.v * 100 / enumValue.numOfServices}
                        ]
                    })
                # Calculate mean, median, and standard daviation
                sum = 0
                for value in enumValue.values
                    sum += value
                enumValue.statisticsInfo["Average"] = sum/enumValue.numOfServices
                enumValue.statisticsInfo["Median"] = enumValue.values[Math.ceil(enumValue.numOfServices/2)]
                variance = 0
                for value in enumValue.values
                    variance += Math.pow(enumValue.statisticsInfo["Average"] - value, 2)
                variance /= enumValue.numOfServices
                enumValue.statisticsInfo["Standard Daviation"] = Math.sqrt(variance).toFixed(2)
            else
                # enum is an enumeration
                numOfEnumElem = 0
                enumElem = []
                for key, value of enumValue
                    if ((!isNaN(key)) && (typeof value == "string"))
                        $scope.rows.enumRows[i].push({
                            c: [
                                { v: toTitleCase(value) }
                                { v: if (isNaN(enumValue[value])) then 0
                                else enumValue[value] * 100 / enumValue.numOfServices
                                }
                            ]})
                        numOfEnumElem++
                        # save the values of the enum in an array (for the ease of use)
                        enumElem.push(enumValue[value])
                # calculate ratio of uniform distribution
                uniDistribution = 1/numOfEnumElem
                uniValue = uniDistribution * enumValue.numOfServices
                deviation = 0
                allEqual = true
                prevElem = enumElem[0]
                for elem in enumElem
                    if (prevElem != elem)
                        allEqual = false
                    if (!elem)
                        elem = 0
                    deviation += Math.abs(elem - uniValue)
                if (allEqual)
                    deviation = 0
                else
                    deviation /= numOfEnumElem # mean of sum of deviations
                    deviation /= enumValue.numOfServices # decimal ratio of deviation
                enumValue.statisticsInfo["Uniform Distribution Ratio"] = 1 - deviation.toFixed(2)
        removeZeroEnums()

    # delete enumerations charts with rows of zero values
    removeZeroEnums = () ->
        for key, row of $scope.rows.enumRows
            if (row.length == 1)
                delete ($scope.rows.enumRows[key])
                delete ($scope.enumerations[key])
                $scope.statisticsOptions.splice($scope.statisticsOptions.indexOf(key), 1)
            else
                allZero = true
                for element in row
                    if (element.c[1].v > 0)
                        allZero = false
                        break
                if (allZero)
                    delete ($scope.rows.enumRows[key])
                    delete ($scope.enumerations[key])
                    $scope.statisticsOptions.splice($scope.statisticsOptions.indexOf(key), 1)

    # Loop over number of services per detailed properties to create rows
    createPropertiesCharts = () ->
        for property, value of servicesPerProperty
            if (value > 0)
                $scope.rows.details.fine.push({
                    c: [
                        { v: property }
                        { v: value * 100 / $scope.numOfServices }
                    ]})
        # Loop over number of properties categories to get nr. of services
        # per category and create rows
        for key, category of propertiesCategories
            if (category.numOfServices > 0)
                $scope.rows.details.rough.push({
                    c: [
                        { v: category.description }
                        { v: category.numOfServices * 100 / $scope.numOfServices}
                    ]})

]