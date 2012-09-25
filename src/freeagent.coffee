request = require('request')
crypto = require('crypto')
qs = require('querystring')
_ = require('underscore')

baseUri = 'https://api.freeagent.com/v2/'
authorizeUrl = baseUri + 'approve_app'
tokenUrl = baseUri + 'token_endpoint'

#try to use proxy if available
proxyUrl = "http://localhost:8888" #process.env.HTTPS_PROXY or process.env.https_proxy

class FreeAgent
  constructor: (client_id, client_secret) ->
    @client_id = client_id
    @client_secret = client_secret

  authenticate: (authorizationCode, callback) =>
    request.post
        url: tokenUrl,
        proxy: proxyUrl
        form: 
          client_id: @client_id
          client_secret: @client_secret
          grant_type: 'authorization_code'
          redirect_uri: 'http://localhost:3000/oauth/callback'
          code: authorizationCode
      , (err, response) ->
        return callback err if err
        if response.statusCode >= 400
          return callback(
            message: response.body
            statusCode: response.statusCode
          )
        payload = JSON.parse(response.body)
        callback null, payload

  getAuthorizationUrl : (options) =>
    options = _.extend(
      response_type: 'code'
      client_id: @client_id
      client_secret: @client_secret
    , options)
    authorizeUrl + '?' + qs.stringify(options)

  _prepareHeaders : (access_token, options) ->
    options = {} if !options
    _.extend options,
      proxy: proxyUrl
      headers:
        'Accept': 'application/json'
        'User-Agent' : 'BadgerTime' 
        'Authorization': "Bearer #{access_token}"

  getProjects : (access_token, callback) ->
    request.get @_prepareHeaders(access_token,
      uri: baseUri + "projects"
    ), (error, response) ->
      unless error or response.statusCode isnt 200
        callback null, response
      else
        callback error

module.exports = FreeAgent