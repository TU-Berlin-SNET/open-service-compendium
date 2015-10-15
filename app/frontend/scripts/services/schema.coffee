angular.module('frontendApp').factory 'Schema', ["$resource", "lodash", ($resource, _) ->
  $resource '/schema.json', {}, {
    get: {
      method: "get",
      cache: true,
      interceptor : {
        response : (r) ->
          _.tap(r, (response) ->
            serviceProperties = response.resource.definitions.Service.properties
            categories = _.uniq(_.map(serviceProperties, (prop) -> prop.category))

            categoriesProperties = _.zipObject(_.map(categories, (c) ->
              #[name, property]
              propertyCategoryPairs = _.select(_.pairs(serviceProperties),(kv) -> kv[1].category == c)

              for pCP in propertyCategoryPairs
                pCP[1].description = response.resource.definitions.Service.properties[pCP[0]].description

              if propertyCategoryPairs.length > 0
                [c, {
                  description: "Category description of " + c,
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