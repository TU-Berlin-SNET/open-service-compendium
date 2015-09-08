angular.module('frontendApp').factory 'Filters', ['$stateParams', '$state', 'lodash', 'Schema', '$q', ($stateParams, $state, _, Schema, $q) ->
  addOrRemove = (property, filterValues, value) ->
    if(filterValues.indexOf(value) == -1)
      filterValues.push(value)
    else
      filterValues.splice(filterValues.indexOf(value), 1)

    setFilter(property, filterValues)

  setFilter = (property, value) ->
    $paramsWithoutProperty = _.reject([].concat($stateParams.query), (query) -> (query.indexOf(property) == 0))

    $state.go($state.$current.name, {query: _.sortBy($paramsWithoutProperty.concat(property + ":" + value.join(',')))})

  convertToFilter = (schema, property, filterValues) ->
    propertyDefinition = schema.definitions.Service.properties[property]

    filter = switch propertyDefinition.type
      when "array"
        if propertyDefinition.items.enum != undefined
          {
            type: "arrayEnumInclusion",
            predicate: (service) -> _.intersection(service[property], filterValues).length > 0
            change: (value) -> addOrRemove(property, filterValues, value)
          }
      when undefined
        if propertyDefinition.enum != undefined
          {
            type: "enum"
            predicate: (service) -> (_.any(filterValues, (value) -> service[property] == value))
            change: (value) -> addOrRemove(property, filterValues, value)
          }

    _.tap(filter, (filter) ->
      filter.filterView = "partials/filters/" + filter.type + ".html"
      filter.values = filterValues
      filter.property = propertyDefinition
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
  }
]