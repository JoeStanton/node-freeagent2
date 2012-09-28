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
    throw new Error "No callback defined!" unless callback
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
  
  #Company
  getCompany: (optionsOrCallback, callback) ->
    #How can this be written better?
    if typeof optionsOrCallback is 'function' 
      callback = optionsOrCallback
    else 
      options = optionsOrCallback

    @_getRequest 'company', null, (error, data) ->
      if not error and data and data.company
        callback null, data.company
      else
        callback error

  #Projects
  getProjects : (optionsOrCallback, callback) ->
    @_getRequest 'projects', null, callback

  getProjectWithId : (projectUri, optionsOrCallback, callback) ->
    @_getRequest 'projects/' + projectUri, null, callback

  getTasksForProject : (projectUri, optionsOrCallback, callback) ->
    @_getRequest 'tasks/' + projectUri, null, callback

  #Users
  getUsers : (optionsOrCallback, callback) ->
    @_getRequest 'users', null, callback

  #Timesheets
  getTimeslips : (optionsOrCallback, callback) ->
    @_getRequest 'timeslips', null, callback

  #Invoices
  getInvoices : (optionsOrCallback, callback) ->
    @_getRequest 'invoices', null, callback

  getInvoicesForProject : (projectUri, optionsOrCallback, callback) ->
    @_getRequest 'invoices', project: projectUri, callback

module.exports = FreeAgent