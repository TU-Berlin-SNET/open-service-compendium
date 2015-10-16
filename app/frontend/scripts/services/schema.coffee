angular.module('frontendApp').factory 'Schema', ["$resource", "lodash", ($resource, _) ->
  $resource '/schema.json', {}, {
    get: {
      method: "get",
      cache: true,
      interceptor : {
        response : (r) ->
          _.tap(r, (response) ->
            # Simulate provider properties as Service properties
            _.merge(response.resource.definitions.Service.properties, response.resource.definitions.Provider.properties)
            delete response.resource.definitions.Service.properties.provider

            serviceProperties = response.resource.definitions.Service.properties
            categories = _.uniq(_.map(serviceProperties, (prop) -> prop.category))

            categoriesProperties = _.zipObject(_.map(categories, (c) ->
              #[name, property]
              propertyCategoryPairs = _.select(_.pairs(serviceProperties),(kv) -> kv[1].category == c)

              for pCP in propertyCategoryPairs
                pCP[1].description = response.resource.definitions.Service.properties[pCP[0]].description

              if propertyCategoryPairs.length > 0
                [c, {
                  description: response.resource.translations.category[c],
                  properties: _.zipObject(propertyCategoryPairs)
                }]
              else
                return undefined
            ))

            categoriesProperties

            response.resource.propertyCategories = categoriesProperties
          )
      }
    }
  }
]