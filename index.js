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


    new (require('./src/api/Data-API'   ))({swaggerService: swaggerService}).add_Methods()
    new (require('./src/api/Convert-API'))({swaggerService: swaggerService}).add_Methods()
    new (require('./src/api/GraphDB-API'))({swaggerService: swaggerService}).add_Methods()
    new (require('./src/api/Content-API'))({swaggerService: swaggerService}).add_Methods()
    new (require('./src/api/Config-API' ))({swaggerService: swaggerService}).add_Methods()
    new (require('./src/api/Git-API'    ))({swaggerService: swaggerService}).add_Methods()

    swaggerService.swagger_Setup()
  }

console.log('Adding swagger support')
add_Swagger(server.app);

console.log('Server started at: ' + server.url());