`

angular.module('frontendApp').factory('shareData', function() {
  var data = '';

        return {
            getSharedData: function () {
                return data;
            },
            setSharedData: function(value) {
                data = value;
            }
        };
    });




`