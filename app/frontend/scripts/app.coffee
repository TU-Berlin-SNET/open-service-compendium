'use strict';

###
@ngdoc overview
@name frontendApp
@description frontendApp

Main module of the application.
###

angular.module('frontendApp', ['ngAnimate', 'ngCookies', 'ngResource', 'ui.router', 'ngSanitize', 'ngTouch']).config ($stateProvider) ->
    $stateProvider.state('home',
      url: "/"
      templateUrl: "home.html"
    ).state('services',
      url: "/services"
      templateUrl: "services/services.html"
    ).state('services.detail',
      url: "/:id"
      templateUrl: "detail.html"
    ).state('services.compare',
      url: "/:id/compare_with/:other_id"
      templateUrl: "compare.html"
    )
    