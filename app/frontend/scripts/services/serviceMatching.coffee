angular.module('frontendApp').factory 'ServiceMatching',
['lodash', (_) ->
    factory = {}

    # Update the array of filtered Serices
    # Loop over all available services
    # 1. If no values are selected for any property, services would be added directly
    # 2. Else, check if service provide all properties that have selected values
    # 3. If property provides unique answers, check the service value
    # 4. Else, wait for the whole loop of selectedValues array to be done,
    # 5. If one at least is equal to the service's value, add it
    factory.updateFilteredServices = (selectedValues, services, enumerations) ->
        filteredServices = []
        for service in services
            addService = true
            for selectedValue in selectedValues
                # convert property key string to service property format
                property = (selectedValue.property.replace(/ /g, "_")).toLowerCase()
                if (!service[property])
                    addService = false
                    break
                else
                    if (selectedValue.uniqueAnswer)
                        if (!factory.isServiceMatching(service, selectedValue, enumerations))
                            addService = false
                            break
                    else
                        if (!factory.isServiceMatching(service, selectedValue, enumerations))
                            if (!factory.multiPropertyProvided(service, selectedValue, selectedValues, enumerations))
                                addService = false
                                break
            if (addService)
                filteredServices.push(service)
        return filteredServices

    factory.multiPropertyProvided = (service, selectedValue, selectedValues, enumerations) ->
        selectedProperty = selectedValue.property
        for sValue in selectedValues
            if (sValue.property == selectedProperty)
                if (factory.isServiceMatching(service, sValue, enumerations))
                    return true
        return false

    # When the selection of values for a question/filter property changes,
    # 1. If this question/filter property has unique selection option
    # 1.1. If exists, set previously selected value to false,
    # 1.2. and remove it from the selectedValues array
    # 1.3. Set selected property of the value to true
    # 2. If the property can have multipe values (checkbox)
    # 2.1. If the value is unchecked, remove it from the selectedValues array
    # 3. If a value is selected in any case
    # 3.1.  Add the newly selected value to the selectedValues array
    factory.updateSelection = (selectedValues, properties, property, valueKey) ->
        selected = true
        if (property.uniqueAnswer)
            i = properties.indexOf(property)
            for key, value of properties[i].values
                if (value.selected)
                    value.selected = false
                    j = _.findIndex(selectedValues, {
                        property: property.key
                        value: key
                        uniqueAnswer: property.uniqueAnswer
                    })
                    if (j >= 0)
                        selectedValues.splice(j, 1)
            properties[i].values[valueKey].selected = true
            if (valueKey == "None")
                selected = false
        else
            if (!property.values[valueKey].selected)
                selected = false
                j = _.findIndex(selectedValues, {
                    property: property.key
                    value: valueKey
                    uniqueAnswer: property.uniqueAnswer
                })
                selectedValues.splice(j, 1)
        if (selected)
            selectedValues.push ({
                property: property.key
                value: valueKey
                uniqueAnswer: property.uniqueAnswer
            })
        return selectedValues

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
    # 2.2. If service can have only unique value
    # 2.2.1. check if service value is equal to the selected
    # 2.3. If service can have multiple values
    # 2.3.1. Loop over all service values of the property
    # 2.3.2. Check if one value value at least is equal to the selected
    factory.isServiceMatching = (service, selectedValue, enumerations) ->
        propertyKey = selectedValue.property
        value = selectedValue.value
        # convert question key string to service property format
        property = (propertyKey.replace(/ /g, "_")).toLowerCase()
        if (!enumerations[propertyKey])
            if (property == "storage_properties")
                return factory.checkServiceMaxStorageCapacity(service, property, value)
            else
                if (value == "Yes")
                    if (service[property])
                        if ((property == "free_trial") && (service[property]["has_free_trial"]))
                            return true
                        else if ((property != "free_trial") && (service[property]))
                            return true
                    else
                        return false
                else # selected answer is "It doesn't matter"
                    if (!service[property])
                        return true
                    else
                        if ((property == "free_trial") && (service[property]["has_free_trial"]))
                            return false
                        else if ((property != "free_trial") && (service[property]))
                            return false
        else
            if (property == "established_in")
                return factory.checkServiceEstablishmentYear(service, property, value)
            # check if property is provided by service
            if (service[property] == undefined)
                return false
            else
                if (selectedValue.uniqueAnswer)
                    if (String(service[property]) != value.toLowerCase())
                        return false
                else
                    for key, item of service[property]
                        if (item == value.toLowerCase())
                            return true
                    return false
        return true

    # Check if service matches the selected value of "Storage Properties" property
    factory.checkServiceMaxStorageCapacity = (service, property, value) ->
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
                    if (iServiceMaxStorage < iSelectedMaxStorage)
                        return false
        return true

    # Check if service matches the selected value of "Established in" property
    factory.checkServiceEstablishmentYear = (service, property, value) ->
        if (service[property] == undefined)
            return false
        valueRange = value.split(" ")
        if (isNaN(valueRange[0]))
            if ((valueRange[0] == "Before") && (service[property] < valueRange[1]))
                return true
            if ((valueRange[0] == "After") && (service[property] >= valueRange[1]))
                return true
        else
            if ((service[property] >= valueRange[0]) && (service[property] < valueRange[2]))
                return true
        return false


    # Check if a property value is unique, or a service can have multiple values
    # For the given key of the property, check the statistics
    # Calculate the summation of each value of the property
    # If it is more than 100, then services can have multiple values,
    # and the values are not unique
    factory.checkIfUniqueValue = (key, enumRows) ->
        statisticsEnum = enumRows[key]
        overallValue = 0
        for value in statisticsEnum
            overallValue += value.c[1].v
        if (overallValue > 100)
            return false
        return true

    # Get number of filtered (rest) services if a value is selected
    # 1. Add the given value to a copy of the selected values list
    # 2. Get the list of filtered services based on the new selected values list
    # 3. Return the number of services in the list
    factory.getRestServices = (property, valueKey, selectedValues, services, enumerations) ->
        virtualSelectedValues = []
        for value in selectedValues
            if (property.key != value.property)
                virtualSelectedValues.push(value)
        if (valueKey != "None")
            virtualSelectedValues.push({
                property: property.key
                value: valueKey
                uniqueAnswer: property.uniqueAnswer
            })
        virtualFilteredServices = factory.updateFilteredServices(virtualSelectedValues, services, enumerations)
        return virtualFilteredServices.length

    return factory
]