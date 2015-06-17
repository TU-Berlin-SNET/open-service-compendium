'use strict'

describe 'Service: sharedData', ->

  # load the service's module
  beforeEach module 'frontendApp'

  # instantiate service
  sharedData = {}
  beforeEach inject (_sharedData_) ->
    sharedData = _sharedData_

  it 'should do something', ->
    expect(!!sharedData).toBe true
