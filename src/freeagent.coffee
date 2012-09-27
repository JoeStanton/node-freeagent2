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
  constructor: (access_token) ->
    @access_token = access_token

  _prepareHeaders : (access_token, options) ->
    options = {} if !options
    _.extend options,
      proxy: proxyUrl
      headers:
        'Accept': 'application/json'
        'User-Agent' : 'node-freeagent2'
        'Authorization': "Bearer #{access_token}"

  getCompany: (callback) ->
    @_getRequest 'company', null, callback

  getProjects : (callback) ->
    @_getRequest 'projects', null, callback

  _getRequest : (url, options, callback) ->
    requestUri = baseUri + url
    requestUri += '?' + qs.stringify(options) if options

    request.get @_prepareHeaders(@access_token,
      uri: requestUri,
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