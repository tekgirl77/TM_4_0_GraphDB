/*jslint node: true */
"use strict";

require('coffee-script/register');              // adding coffee-script support

var Server = require('./src/TM-Server');           // gets the express server

var server = new Server().start()               // start server

function add_Swagger(app)
  {
    var Swagger_Service = require('./src/services/Swagger-Service')
    var options = { app: app }
    var swaggerService = new Swagger_Service(options)
    swaggerService.set_Defaults()

    var Git_API = require('./src/api/Git-API')
    new Git_API({swaggerService: swaggerService}).add_Methods()
    swaggerService.swagger_Setup()
  }

console.log('Adding swagger support')
add_Swagger(server.app);

console.log('Server started at: ' + server.url());