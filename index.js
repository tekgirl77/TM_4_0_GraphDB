/*jslint node: true */
"use strict";

require('coffee-script/register');              // adding coffee-script support

var server = require('./src/server');           // gets the express server

server.port  = process.env.PORT || 1332;        // sets port
server.listen(server.port);                     // start server

console.log('Server started at: http://localhost:' + server.port);

//require('child_process').spawn('open',['http://localhost:' + server.port]);