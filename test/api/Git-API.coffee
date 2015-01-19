TM_Server        = require '../../src/TM-Server'
Swagger_Service  = require '../../src/services/Swagger-Service'
Git_API = require '../../src/api/Git-API'

describe.only 'api | Git-Service.test', ->

  describe 'directly',->
    it 'git_Exec', (done)->
        using new Git_API(), ->
            @git_Exec 'status', (result)->
                log result
                done()

  describe 'via web api',->

      tmServer       = null
      swaggerService =  null

      before (done)->
        tmServer  = new TM_Server({ port : 12345})
        options = { app: tmServer.app ,  port : tmServer.port}
        swaggerService = new Swagger_Service options
        swaggerService.set_Defaults()
        #swaggerService.setup()
        new Git_API().add_Methods(swaggerService)
        swaggerService.swagger_Setup()
        tmServer.start()
        done()

      after (done)->
        tmServer.stop ->
          done()

      it 'constructor', ->
        Git_API.assert_Is_Function()

      it 'check git section exists', (done)->
        swaggerService.url_Api_Docs.GET_Json (docs)->
          api_Paths = (api.path for api in docs.apis)
          api_Paths.assert_Contains('/list')
          api_Paths.assert_Contains('/git')

          swaggerService.url_Api_Docs.append("/git").GET_Json (data)->
            data.apiVersion    .assert_Is('1.0.0')
            data.swaggerVersion.assert_Is('1.2')
            data.resourcePath  .assert_Is('/git')
            done()

      it 'call Git method', (done)->
        swaggerService.get_Client_Api 'git', (clientApi)->
          clientApi.assert_Is_Object()
          clientApi.status (data)->
            #log data.obj.toString()
            data.obj.data.assert_Contains('On branch')
            #log new String(data.obj)#.assert_Contains('On branch')
            done()