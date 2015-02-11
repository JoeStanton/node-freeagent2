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

  #Inject headers for OAuth2 and FreeAgent API specifics (eg. User Agent Requirement)
  _prepareHeaders : (access_token, options) ->
    options = {} if !options
    _.extend options,
      proxy: proxyUrl
      headers:
        'Accept': 'application/json'
        'User-Agent' : 'node-freeagent2'
        'Authorization': "Bearer #{access_token}"

  #Get Request Mechanism
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
          callback new Error("#{response.statusCode} : #{body.errors.error.message}")
      else
        callback error

  #Post Request Mechanism
  _postRequest : (url, data, callback) ->
    requestUri = @baseUri + url

    request.post @_prepareHeaders(@access_token,
      uri: requestUri,
      # body: data,
      json: true
    ), (error, response, body) ->
      unless error
        if response.statusCode < 400
          callback null, body
        else
          callback new Error("#{response.statusCode} : #{body.errors.error.message}")
      else
        callback error

  _processParams : (optionsOrCallback, callback) ->
    if typeof optionsOrCallback is 'function'
      options: null
      callback: optionsOrCallback
    else
      if callback
        options: optionsOrCallback
        callback: callback
      else
        throw new Error 'No callback defined!'

  refreshToken : (refresh_token, client_id, client_secret, callback) ->
    request.post
      url: @baseUri + 'token_endpoint'
      headers:
        'Accept': 'application/json'
        'User-Agent' : 'node-freeagent2'
        'Authorization': 'Basic ' + new Buffer("#{client_id}:#{client_secret}").toString('base64')
      json:
        grant_type: 'refresh_token'
        refresh_token: refresh_token
    , (error, response, body) ->
      if not error and response and body.access_token
        @access_token = body.access_token
        callback null, body.access_token
      else
        callback error

  #Company
  getCompany : (optionsOrCallback, callback) ->
    params = @_processParams optionsOrCallback, callback
    @_getRequest 'company', params.options, (error, data) ->
      if not error and data and data.company
        params.callback null, data.company
      else
        params.callback error

  #Projects
  getProjects : (optionsOrCallback, callback) ->
    params = @_processParams optionsOrCallback, callback
    @_getRequest 'projects', params.options, params.callback

  getProjectWithId : (projectUri, optionsOrCallback, callback) ->
    params = @_processParams optionsOrCallback, callback
    @_getRequest 'projects/' + projectUri, params.options, params.callback

  getTasksForProject : (projectUri, optionsOrCallback, callback) ->
    params = @_processParams optionsOrCallback, callback
    @_getRequest 'tasks/' + projectUri, params.options, params.callback

  #Users
  getUsers : (optionsOrCallback, callback) ->
    params = @_processParams optionsOrCallback, callback
    @_getRequest 'users', params.options, params.callback

  #Timesheets
  getTimeslips : (optionsOrCallback, callback) ->
    params = @_processParams optionsOrCallback, callback
    @_getRequest 'timeslips', params.options, params.callback

  #Invoices
  getInvoices : (optionsOrCallback, callback) ->
    params = @_processParams optionsOrCallback, callback
    @_getRequest 'invoices', params.options, params.callback

  getInvoicesForProject : (projectUri, optionsOrCallback, callback) ->
    params = @_processParams optionsOrCallback, callback
    @_getRequest 'invoices',
      _.extend params.options, project: projectUri
      params.callback

  getExpenses : (optionsOrCallback, callback) ->
    params = @_processParams optionsOrCallback, callback
    @_getRequest 'expenses', params.options, params.callback

  createExpense : (optionsOrCallback, callback) ->
    params = @_processParams optionsOrCallback, callback
    @_postRequest 'expenses', params.options, params.callback

  getCurrentUser : (optionsOrCallback, callback) ->
    params = @_processParams optionsOrCallback, callback
    @_getRequest 'users/me', params.options, params.callback

  getOpenBills : (optionsOrCallback, callback) ->
    params = @_processParams optionsOrCallback, callback
    @_getRequest 'bills',
      view: 'open',
      params.callback

  getContacts : (optionsOrCallback, callback) ->
    params = @_processParams optionsOrCallback, callback
    @_getRequest 'contacts', params.options, params.callback

  getCategories : (optionsOrCallback, callback) ->
    params = @_processParams optionsOrCallback, callback
    @_getRequest 'categories', params.options, params.callback

module.exports = FreeAgent
