'use strict'

angular.module('frontendApp', [
  'ngAnimate'
  'ngCookies'
  'ngResource'
  'ui.router'
  'ngSanitize'
  'ngTouch'
  'checklist-model'
  'ngLodash'
  'angular.filter'
]).config ($stateProvider, lodash) ->
  $stateProvider
    .state('home', url: '/', templateUrl: 'home.html')
    .state('services', url: '/services/', templateUrl: 'services.html', controller: 'ServicesController')
    .state('services.list', url: 'all?query', templateUrl: 'list.html', controller: 'ListController')
    .state('services.detail', url: ':id/:version/:name', templateUrl: 'detail.html', controller: 'DetailController')
    .state('services.compare', url: ':id/compare_with/:other_id', templateUrl: 'compare.html')