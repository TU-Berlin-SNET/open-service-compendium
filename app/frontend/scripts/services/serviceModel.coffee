`angular.module('frontendApp').factory('serviceModel', function() {
  var data = '';
        return {
            getServiceModel: function () {
                return data;
            },
            setServiceModel: function(value) {
                data = value;
            }
        };
    });
`