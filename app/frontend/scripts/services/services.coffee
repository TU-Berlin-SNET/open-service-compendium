angular.module('frontendApp').factory 'Services', ['$resource', 'lodash', ($resource, _) ->
  $resource '/services.json/:serviceId', { serviceId: '@_id' }, {
    'query' : {
      method: 'GET',
      cache: true,
      isArray: true,
      interceptor : {
        response : (r) ->
          _.tap(r, (response) ->
            _.forEach(response.resource, (service) ->
              pathParams = service.uri.split('/')

              service.uiRouterParams = {
                id: pathParams[4],
                version: pathParams[6],
                name: service.service_name.replace(/[ ]/g, "-")
              }
            )
          )
      }
    }
  }
]