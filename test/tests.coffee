should = require('should')
_ = require('underscore')
nock = require('nock')
FreeAgent = require('../lib')
Authentication = FreeAgent.AuthenticationStrategy
Api = FreeAgent.Api

describe 'when constructing an authenticated get request to the production API', ->
  freeagentApi = new Api 'ACCESS_TOKEN'
  request = freeagentApi._getRequest 'example/endpoint', key1: 'value1',key2: 'value2', () ->

  it 'should set the request URI correctly (including params)', -> 
    request.uri.href.should.equal 'https://api.freeagent.com/v2/example/endpoint?key1=value1&key2=value2'
  
  it 'should make a GET request', -> 
    request.method.should.equal 'GET'

  it 'should attach an authorization header with access token', -> 
    request.headers.should.have.property 'Authorization', 'Bearer ACCESS_TOKEN'

  it 'should attach a user-agent header', -> 
    request.headers.should.have.property 'User-Agent', 'node-freeagent2'

describe 'when constructing an authenticated get request to the sandbox API', ->
  freeagentApi = new Api('ACCESS_TOKEN', true) #enable sandbox mode
  request = freeagentApi._getRequest 'example/endpoint', null, () ->

  it 'should set the request URI correctly', -> 
    request.uri.href.should.equal 'https://api.sandbox.freeagent.com/v2/example/endpoint'

describe 'when requesting any endpoint via a wrapper method, with an invalid/empty callback', ->
  freeagentApi = new Api 'ACCESS_TOKEN'

  it 'should throw an error', -> 
    -> freeagentApi.getProjects()
    .should.throw 'No callback defined!'

describe 'when requesting any endpoint via a wrapper method, with a callback and some empty options', ->
  freeagentApi = new Api 'ACCESS_TOKEN'
  callbackInvoked = false

  mockRequest = nock('https://api.freeagent.com/').get('/v2/projects').reply(200, '')
  request = freeagentApi.getProjects () -> 
    callbackInvoked = true
    mockRequest.done()
    done()

  it 'should not add any options to the query string', -> 
    request.uri.href.should.equal 'https://api.freeagent.com/v2/projects'

  it 'should invoke the callback', ->
    callbackInvoked.should.be.true

describe 'when requesting any endpoint via a wrapper method, with options and a callback', ->
  freeagentApi = new Api 'ACCESS_TOKEN'
  request = freeagentApi.getProjects 
    option1: 'value1' 
    option2: 'value2'
  , () ->

  it 'should add the options to the query string', -> 
    request.uri.href.should.equal 'https://api.freeagent.com/v2/projects?option1=value1&option2=value2'

describe 'when making any request', ->
  freeagentApi = new Api('ACCESS_TOKEN')

  mockResponse = user: username: 'Joe', email: 'joe@example.com'

  it 'should JSON parse and verify the response', (done) ->
    request = nock('https://api.freeagent.com/').get('/v2/users/me').reply(200, mockResponse)
    freeagentApi._getRequest 'users/me', null, (error, payload) ->
      should.not.exist error
      payload.should.eql mockResponse
      request.done()
      done()

  it 'should have error if http status code > 400', (done) ->
    request = nock('https://api.freeagent.com/').get('/v2/users/me').reply(401, '')
    freeagentApi._getRequest 'users/me', null, (error, payload) ->
      should.exist error
      error.message.should.include '401'
      should.not.exist payload
      request.done()
      done()