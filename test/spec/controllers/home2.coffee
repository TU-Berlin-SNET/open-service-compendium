'use strict'

describe 'Controller: Home2Ctrl', ->

  # load the controller's module
  beforeEach module 'frontendApp'

  Home2Ctrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    Home2Ctrl = $controller 'Home2Ctrl', {
      $scope: scope
    }

  it 'should attach a list of awesomeThings to the scope', ->
    expect(scope.awesomeThings.length).toBe 3
