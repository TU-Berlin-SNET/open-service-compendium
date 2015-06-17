'use strict'

describe 'Filter: removeSpaces', ->

  # load the filter's module
  beforeEach module 'frontendApp'

  # initialize a new instance of the filter before each test
  removeSpaces = {}
  beforeEach inject ($filter) ->
    removeSpaces = $filter 'removeSpaces'

  it 'should return the input prefixed with "removeSpaces filter:"', ->
    text = 'angularjs'
    expect(removeSpaces text).toBe ('removeSpaces filter: ' + text)
