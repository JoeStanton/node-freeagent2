request = require('request')
crypto = require('crypto')
qs = require('querystring')
_ = require('underscore')

baseUri = 'https://api.freeagent.com/v2/'
authorizeUrl = baseUri + 'approve_app'
tokenUrl = baseUri + 'token_endpoint'

#try to use proxy if one is available
proxyUrl = process.env.HTTPS_PROXY or process.env.https_proxy

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
        'User-Agent' : 'node-freeagent2'
        'Authorization': "Bearer #{access_token}"

  getCompany: (access_token, callback) ->
    @_getRequest access_token, 'company', null, callback

  getProjects : (access_token, callback) ->
    @_getRequest access_token, 'projects', null, callback

  _getRequest : (access_token, url, options, callback) ->
    request.get @_prepareHeaders(access_token,
      uri: baseUri + url + '?' + qs.stringify(options),
      json: true 
    ), (error, response) ->
      unless error
        if response.statusCode is 200
          callback null, response
        else
          callback new Error("#{response.statusCode} : {response.body}")
      else
        callback error

module.exports = FreeAgent