Node-FreeAgent2 [![Build Status](https://travis-ci.org/JoeStanton/Node-FreeAgent2.png)](https://travis-ci.org/JoeStanton/Node-FreeAgent2)
===============

Node.js OAuth2 REST Library for use with the FreeAgent v2 API. It provides a very thin wrapper around the API to deal with all of the boring stuff without sacrificing on flexibility.  

Includes a passport strategy for plugging into the node-passport authentication library.  

**This library is work in progress**

##Install

```bash
npm install node-freeagent2
```  

##Usage 

The two components of this library - the API and the Authentication Strategy, can be used independently. First require the module.

```coffeescript 
FreeAgent = require 'node-freeagent2'
``` 

###API

```coffeescript 
freeAgent = new FreeAgent.Api 'auth_token'

freeAgent.getProjects (error, projects) ->
  unless error
    console.log projects
  else
    console.log error
``` 

Each REST resource has a corresponding method for GET. Requests using other HTTP verbs have not yet been implemented.
Each method of the type `GET` has a consistent signature of:

```coffeescript 
getProjects : (optionsOrCallback, callback) ->
``` 

Except where the method is a convenience function for getById or something similar, in which case it takes the form:

```coffeescript 
getProjectById : (id, optionsOrCallback, callback) ->
``` 

###Passport Strategy
```coffeescript 
FreeAgentStrategy = FreeAgent.AuthenticationStragegy
passport.use 'freeagent', new FreeagentStrategy(options, ...)
``` 

##Contributing 

Please help make this a better library, Pull requests and Issues are very welcome.  

The project is written in CoffeeScript and built into JS, both sources are currently committed but I may change this.  
The CoffeeScript and JS should be kept in sync at all times.  
  * Use `cake watch` during development. 
  * Place tests in `/tests`, execute with mocha using `cake test` 
  * Try to conform to coffeelint, check by regularly running `cake lint` 

## License 

(The MIT License)

Copyright (c) 2012 Joe Stanton &lt;joe.stanton@red-badger.com&gt;

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
