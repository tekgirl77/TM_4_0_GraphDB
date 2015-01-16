/*jslint node: true */
"use strict";

require('coffee-script/register');              // adding coffee-script support

var Server = require('./src/Server');           // gets the express server

var server = new Server().start()               // start server

console.log('Server started at: ' + server.url());