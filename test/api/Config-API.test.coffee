TM_Server        = require '../../src/TM-Server'
Swagger_Service  = require '../../src/services/Swagger-Service'
Config_API = require '../../src/api/Config-API'

describe '| api | Config-API.test', ->

  describe '| via web api',->

      tmServer       = null
      swaggerService = null
      clientApi      = null
      configApi      = null

      before (done)->
        configApi = new Config_API()
        tmServer  = new TM_Server({ port : 12345})
        options = { app: tmServer.app ,  port : tmServer.port}
        swaggerService = new Swagger_Service options
        swaggerService.set_Defaults()
        #swaggerService.setup()

        new Config_API({swaggerService: swaggerService}).add_Methods()
        swaggerService.swagger_Setup()
        tmServer.start()

        swaggerService.get_Client_Api 'config', (swaggerApi)->
            clientApi = swaggerApi
            done()

      after (done)->
        tmServer.stop ->
          done()

      it 'constructor', ->
        Config_API.assert_Is_Function()

      it 'check config section exists', (done)->
        swaggerService.url_Api_Docs.GET_Json (docs)->
          api_Paths = (api.path for api in docs.apis)
          api_Paths.assert_Contains('/config')

          swaggerService.url_Api_Docs.append("/config").GET_Json (data)->
            data.apiVersion    .assert_Is('1.0.0')
            data.swaggerVersion.assert_Is('1.2')
            data.resourcePath  .assert_Is('/config')
            clientApi.assert_Is_Object()
            clientApi.file.assert_Is_Function()
            clientApi.contents.assert_Is_Function()
            done()


      it 'file', (done)->
        clientApi.file (data)->
          data.obj.assert_Is configApi.configService.config_File_Path()
          done()

      it 'contents', (done)->
        clientApi.contents (data)->
          data.obj.assert_Is configApi.configService.config_File_Path().file_Contents()
          done()

      it 'load_Library_Data', (done)->
        @.timeout(0)
        clientApi.load_Library_Data (data)->
          data.obj.assert_Is_String()
          done()

      it 'convert_Xml_To_Json', (done)->
        @.timeout(20000)
        clientApi.convert_Xml_To_Json (data)->
          data.obj.assert_Size_Is_Bigger_Than(10)
          log data.obj
          done()

      it 'reload', (done)->
        @timeout 10000
        clientApi.reload (data)->
          data.obj.assert_Is('data reloaded')
          done()