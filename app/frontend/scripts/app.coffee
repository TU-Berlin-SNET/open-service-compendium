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
      templateUrl: "services/list.html"
    ).state('detail',
      url: "/detail/:dserviceName"
      templateUrl: "detail.html"
    ).state('compare',
      url: "/compare/:services"
      templateUrl: "compare.html"
    )