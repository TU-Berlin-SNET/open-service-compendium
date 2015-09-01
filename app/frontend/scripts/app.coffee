`
'use strict';
angular.module('frontendApp', ['ngAnimate', 'ngCookies', 'ngResource', 'ui.router', 'ngSanitize', 'ngTouch','checklist-model']).config(function($stateProvider) {
  $stateProvider.state('home', {
    url: "",
    templateUrl: "home.html"
  }).state('services', {
    url: "/services/:type/",
    templateUrl: "services.html"
  }).state('services.detail', {
    url: ":id",
    templateUrl: "detail.html"
  }).state('services.compare', {
    url: ":id/compare_with/:other_id",
    templateUrl: "compare.html"
  });
});

`