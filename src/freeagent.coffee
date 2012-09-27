request = require('request')
crypto = require('crypto')
qs = require('querystring')
_ = require('underscore')

#try to use proxy if one is available
proxyUrl = process.env.HTTPS_PROXY or process.env.https_proxy

class FreeAgent
  constructor: (access_token, sandboxMode) ->
    @access_token = access_token
    if sandboxMode
      @baseUri = 'https://api.sandbox.freeagent.com/v2/'
    else
      @baseUri = 'https://api.freeagent.com/v2/'

  _prepareHeaders : (access_token, options) ->
    options = {} if !options
    _.extend options,
      proxy: proxyUrl
      headers:
        'Accept': 'application/json'
        'User-Agent' : 'node-freeagent2'
        'Authorization': "Bearer #{access_token}"

  getCompany: (callback) ->
    @_getRequest 'company', null, (error, data) ->
      callback error, data.company

  getProjects : (callback) ->
    @_getRequest 'projects', null, callback

  getUsers : (callback) ->
    @_getRequest 'users', null, callback

  getUserProfile : (callback) ->
    @_getRequest 'users/me', null, callback

  _getRequest : (url, options, callback) ->
    requestUri = @baseUri + url
    requestUri += '?' + qs.stringify(options) if options

    request.get @_prepareHeaders(@access_token,
      uri: requestUri,
      json: true 
    ), (error, response, body) ->
      unless error
        if response.statusCode < 400
          callback null, body
        else
          callback new Error("#{response.statusCode} : #{body}")
      else
        callback error

module.exports = FreeAgent