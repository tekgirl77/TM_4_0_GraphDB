TM_Server        = require '../../src/TM-Server'
Swagger_Service  = require '../../src/swagger/Swagger-Service'

return
describe.only 'swagger | Swagger-Service.test', ->

  url_server     = null
  server         = null
  url_api_docs   = null
  swaggerService = null
  swaggerApi     = null

  before (done)->
    server  = new TM_Server({ port : 12345})
    options = { app: server.app }
    swaggerService = new Swagger_Service options
    swaggerService.set_Defaults()
    server.start()
    swaggerService.get_Client_Api (api)->
      swaggerApi = api;
      done()

  after (done)->
    server.stop ->
      url_api_docs.GET (html)->
        assert_Is_Null(html)
        done()

  it 'check server', (done)->
    url_server   = server.url()
    url_api_docs = url_server + '/api-docs'
    help = url_server + '/docs/?url=' + url_api_docs
    url_api_docs.GET (html)->
      html.assert_Is_String()
      done()

  it 'check url_api_docs',(done)->
    url_api_docs.GET_Json (apiDocs)->
        apiDocs.assert_Is {"apiVersion":"1.0.0","swaggerVersion":"1.2","apis":[{"path":"/say"}],"info":{"title":"Swagger Hello World App","description":"This is simple hello world","termsOfServiceUrl":"http://localhost/terms/","contact":"abc@name.com","license":"Apache 2.0","licenseUrl":"http://www.apache.org/licenses/LICENSE-2.0.html"}}
        apiDocs.apiVersion.assert_Is('1.0.0')
        apiDocs.swaggerVersion.assert_Is('1.2')
        apiDocs.apis[0].path.assert_Is('/say')
        done()

  it 'swagger-client', (done)->
      swaggerApi.assert_Is_Object()
      using swaggerApi,->
        @.ping    .assert_Is_Function()
        @.sayHello.assert_Is_Function()

      done()

  it 'ping', (done)->
    swaggerApi.ping (response)->
      response.url = swaggerService.url_Api_Say.append 'ping'
      response.status.assert_Is 200
      response.method.assert_Is 'GET'
      response.obj   .assert_Is { ping: 'pong' }
      done()

  it 'sayHello', (done)->
    name = 'abc'.add_5_Random_Letters()
    swaggerApi.sayHello { name: name }, (response)->
      response.headers.input['x-powered-by'].assert_Is 'Express',
      response.url = swaggerService.url_Api_Say.append 'say_Hello'
      response.status.assert_Is 200
      response.method.assert_Is 'POST'
      response.obj   .assert_Is { hello: name }
      done()

  #it 'test', (done)->
  #  #console.log swaggerApi.keys()
  #  swaggerApi.ping3 (data)->
  #    log data.obj
  #  #url = 'http://localhost:1332/data/tm-uno/queries';
  #  #url.GET_Json (data)->
  #  #  log data
  #  #  done()
  #    done()