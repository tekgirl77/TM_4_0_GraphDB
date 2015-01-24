TM_Server        = require '../../src/TM-Server'
Swagger_Service  = require '../../src/services/Swagger-Service'
Convert_API = require '../../src/api/Convert-API'

describe '| api | Convert-API.test', ->

  describe '| via web api',->

      tmServer       = null
      swaggerService = null
      clientApi      = null
      contentApi      = null

      before (done)->
        contentApi = new Convert_API()
        tmServer  = new TM_Server({ port : 12345})
        options = { app: tmServer.app ,  port : tmServer.port}
        swaggerService = new Swagger_Service options
        swaggerService.set_Defaults()
        #swaggerService.setup()

        new Convert_API({swaggerService: swaggerService}).add_Methods()
        swaggerService.swagger_Setup()
        tmServer.start()

        swaggerService.get_Client_Api 'content', (swaggerApi)->
            clientApi = swaggerApi
            done()

      after (done)->
        tmServer.stop ->
          done()

      it 'constructor', ->
        Convert_API.assert_Is_Function()

      it 'check convert section exists', (done)->
        swaggerService.url_Api_Docs.GET_Json (docs)->
          api_Paths = (api.path for api in docs.apis)
          api_Paths.assert_Contains('/convert')

          swaggerService.url_Api_Docs.append("/convert").GET_Json (data)->
            data.apiVersion    .assert_Is('1.0.0')
            data.swaggerVersion.assert_Is('1.2')
            data.resourcePath  .assert_Is('/convert')
            clientApi.assert_Is_Object()
            done()


      it 'to_query_ids (bad data)', (done)->
        #clientApi.to_query_ids {values: 'abc'.add_5_Letters() }, (data)->
        #  log data
        console.log 'TO DO'
        done()
