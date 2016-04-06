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
  'googlechart'
  'ngMaterial'
]).config ($stateProvider, lodash) ->
  $stateProvider
    .state('home', url: '/', templateUrl: 'home.html')
    .state('services', url: '/services/', templateUrl: 'services.html', controller: 'ServicesController')
    .state('services.info', url: '', templateUrl: 'info.html', controller: 'InfoController')
    .state('services.info.statistics', url: 'statistics/', templateUrl: 'statistics.html', controller: 'StatisticsController')
    .state('services.info.questionnaire', url:'questionnaire/', templateUrl: 'questionnaire.html', controller: 'QuestionnaireController')
    .state('services.info.questionnaire.dynamic', url:'dynamic', templateUrl: 'dynamicQuestionnaire.html', controller: 'DynamicQuestionnaireController')
    .state('services.info.questionnaire.static', url:'static', templateUrl: 'staticQuestionnaire.html', controller: 'StaticQuestionnaireController')
    .state('services.list', url: ':category?query', templateUrl: 'list.html', controller: 'ListController')
    .state('services.detail', url: ':id/:version/:name', templateUrl: 'detail.html', controller: 'DetailController')
    .state('services.detailWithoutName', url: ':id/:version', templateUrl: 'detail.html', controller: 'DetailController')
    .state('services.compare', url: ':id/compare_with/:other_id', templateUrl: 'compare.html')