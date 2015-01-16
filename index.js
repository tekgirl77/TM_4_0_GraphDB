/*jslint node: true */
"use strict";

require('coffee-script/register');              // adding coffee-script support

var Server = require('./src/Server');           // gets the express server

var server = new Server().start()               // start server

function add_Swagger(app)
  {
    var Swagger_Service = require('./src/swagger/Swagger-Service')
    var options = { app: app }
    var swaggerService = new Swagger_Service(options)
    swaggerService.set_Defaults()
  }

console.log('Adding swagger support')
add_Swagger(server.app);

console.log('Server started at: ' + server.url());