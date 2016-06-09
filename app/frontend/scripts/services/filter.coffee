angular.module('frontendApp').factory 'Filters', ['$stateParams', '$state', 'lodash', 'Schema', '$q', ($stateParams, $state, _, Schema, $q) ->
  getPropertyDefinition = (schema, propertyName) ->
    schema.resource.definitions.Service.properties[propertyName]

  addOrRemove = (property, filterValues, value) ->
    if(filterValues.indexOf(value) == -1)
      filterValues.push(value)
    else
      filterValues.splice(filterValues.indexOf(value), 1)

    setFilter(property, filterValues)

  defaultValue = (schema, propertyName) ->
    propertyDefinition = getPropertyDefinition(schema, propertyName)

    switch propertyDefinition.type
      when "array"
        # Default values are persisted within enum (without the last one)
        propertyDefinition.items.enum.slice(0, -1).join(',')
      when "string"
        ".*"
      when undefined
        if propertyDefinition.enum != undefined
          propertyDefinition.enum.slice(0, -1).join(',')

  setFilter = (property, value) ->
    $paramsWithoutProperty = _.reject([].concat($stateParams.query), (query) -> (query.indexOf(property) == 0))

    $state.go($state.$current.name, {query: _.sortBy($paramsWithoutProperty.concat(property + ":" + value.join(',')))})

  convertToFilter = (schema, propertyName, filterValues) ->
    propertyDefinition = getPropertyDefinition(schema, propertyName)

    filter = switch propertyDefinition.type
      when "array"
        if propertyDefinition.items.enum != undefined
          {
            type: "arrayEnumInclusion",
            predicate: (service) -> _.intersection(service[propertyName], filterValues).length > 0
            change: (value) -> addOrRemove(propertyName, filterValues, value)
          }
      when "string"
        {
          type: "stringMatch",
          predicate: (service) -> service[propertyName].match(new RegExp(filterValues[0]))
          change: (value) -> set(propertyName, value)
        }
      when undefined
        if propertyDefinition.enum != undefined
          {
            type: "enum"
            predicate: (service) -> (_.any(filterValues, (value) -> service[propertyName] == value))
            change: (value) -> addOrRemove(propertyName, filterValues, value)
          }

    _.tap(filter, (filter) ->
      filter.filterView = "partials/filters/" + filter.type + ".html"
      filter.values = filterValues
      filter.property = propertyDefinition
      filter.remove = () ->
        params = [].concat($stateParams.query)
        for query, i in params
          if query.indexOf(propertyName) == 0
            params.splice(i, 1)

            $stateParams.query = params

            $state.go($state.$current.name, $stateParams)

            break;
    )
  {
    list : () ->
      $q((resolve, reject) ->
        Schema.get().$promise.then((schema, error) ->
          resolve(
            if $stateParams.query == undefined
              []
            else
              _.map([].concat($stateParams.query), (filterString) ->
                [property, filterValue] = filterString.split(":")

                convertToFilter(schema, property, _.reject(filterValue.split(','), (v) -> (v == "")))
              )
          )
        )
      )

    add : (propertyName) ->
      $q((resolve, reject) ->
        Schema.get().$promise.then((schema, error) ->
          resolve(
            defaultFilter = [propertyName + ":" + defaultValue(schema, propertyName)]

            if $stateParams.query != undefined
              $stateParams.query = [].concat($stateParams.query).concat(defaultFilter)
            else
              $stateParams.query = defaultFilter

            $state.go($state.$current.name, $stateParams)
          )
        )
      )
  }
]