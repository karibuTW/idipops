'use strict';
var persona = angular.module('persona', []);
persona.service('Persona', [
  '$window',
  function ($window) {
    if (!$window.navigator.id) {
      throw {
        name: 'LibraryRequired',
        message: 'The Persona library is required. Please include https://login.persona.org/include.js in your html'
      };
    }
    // Forward arguments to the library
    this.watch = function () {
      $window.navigator.id.watch.apply($window.navigator.id, arguments);
    };
    // Forward arguments to the library
    this.request = function () {
      $window.navigator.id.request.apply($window.navigator.id, arguments);
    };
    // Forward arguments to the library
    this.logout = function () {
      $window.navigator.id.logout.apply($window.navigator.id, arguments);
    };
  }
]);