TM_Server        = require '../../src/TM-Server'
Swagger_Service  = require '../../src/services/Swagger-Service'
supertest        = require 'supertest'

describe 'swagger | Swagger-Service.test', ->

  url_server     = null
  url_api_docs   = null
  server         = null
  swaggerService = null
  swaggerApi     = null

  before (done)->
    server  = new TM_Server({ port : 12346})
    options = { app: server.app ,  port : 12346}
    swaggerService = new Swagger_Service options
    swaggerService.set_Defaults()
    ping =
          spec              : { path : "/say/ping/", nickname : "ping"}
          action            : (req, res)-> res.send {'ping': 'pong'}
    swaggerService.addGet ping
    swaggerService.swagger_Setup()
    server.start()
    done()

  after (done)->
    server.stop ->
      done()

  it 'get_Client_Api', (done)->
    swaggerService.get_Client_Api 'say', (clientApi)->

      clientApi.assert_Is_Object()
      clientApi.operations.ping.assert_Is_Object()
      clientApi.ping (response)->
        response.obj.assert_Is { ping :'pong'}
        done()

  it 'check server', (done)->
    url_server   = server.url()
    url_api_docs = url_server + '/v1.0/api-docs'
    help = url_server + '/docs/?url=' + url_api_docs
    url_api_docs.GET (html)->
      html.assert_Is_String()
      done()

  it 'check url_api_docs',(done)->
    url_api_docs.GET_Json (apiDocs)->
        apiDocs.assert_Is_Object()
        apiDocs.apiVersion.assert_Is('1.0.0')
        apiDocs.swaggerVersion.assert_Is('1.2')
        #apiDocs.apis[0].path.assert_Is('/graphs')
        done()

  it '/docs' , (done)->
    supertest(server.app)
      .get('/docs')
      .end (error, response)->
        response.header.location.assert_Contains ['docs/?url','v1.0/api-docs']
        done()

  it '/docs' , (done)->
    supertest(server.app)
      .get('/docs/')
      .end (error, response)->
        response.text.assert_Contains [ 'swagger', 'api-docs' ]
        done()

  it '/v1.0/api-docs', (done)->
    supertest(server.app)
      .get('/v1.0/api-docs')
      .end (error, response)->
        #response.text.assert_Contains [ 'swagger', 'api-docs' ]
        json = response.text.json_Parse()
        json.apiVersion.assert_Is '1.0.0'
        json.info.title.assert_Is 'TeamMentor GraphDB 4.0',
        done()

#  it 'swagger-client', (done)->
#      swaggerApi.assert_Is_Object()
#      using swaggerApi,->
#        @.ping    .assert_Is_Function()
#        @.sayHello.assert_Is_Function()
#
#      done()
#
#  it 'ping', (done)->
#    swaggerApi.ping (response)->
#      response.url = swaggerService.url_Api_Docs.append 'say/ping'
#      response.status.assert_Is 200
#      response.method.assert_Is 'GET'
#      response.obj   .assert_Is { ping: 'pong' }
#      done()
#
#  it 'sayHello', (done)->
#    name = 'abc'.add_5_Random_Letters()
#    swaggerApi.sayHello { name: name }, (response)->
#      response.headers.input['x-powered-by'].assert_Is 'Express',
#      response.url = swaggerService.url_Api_Docs.append 'say/say_Hello'
#      response.status.assert_Is 200
#      response.method.assert_Is 'POST'
#      response.obj   .assert_Is { hello: name }
#      done()
#
  #it 'test', (done)->
  #  #console.log swaggerApi.keys()
  #  swaggerApi.ping3 (data)->
  #    log data.obj
  #  #url = 'http://localhost:1332/data/tm-uno/queries';
  #  #url.GET_Json (data)->
  #  #  log data
  #  #  done()
  #    done()
