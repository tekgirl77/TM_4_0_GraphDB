TM_Server        = require '../../src/TM-Server'
Swagger_Service  = require '../../src/services/Swagger-Service'
Content_API = require '../../src/api/Content-API'

describe '| api | Content-API.test', ->

  describe '| via web api',->

      tmServer       = null
      swaggerService = null
      clientApi      = null
      contentApi      = null

      before (done)->
        contentApi = new Content_API()
        tmServer  = new TM_Server({ port : 12345})
        options = { app: tmServer.app ,  port : tmServer.port}
        swaggerService = new Swagger_Service options
        swaggerService.set_Defaults()
        #swaggerService.setup()

        new Content_API({swaggerService: swaggerService}).add_Methods()
        swaggerService.swagger_Setup()
        tmServer.start()

        swaggerService.get_Client_Api 'content', (swaggerApi)->
            clientApi = swaggerApi
            done()

      after (done)->
        tmServer.stop ->
          done()

      it 'constructor', ->
        Content_API.assert_Is_Function()

      it 'check content section exists', (done)->
        swaggerService.url_Api_Docs.GET_Json (docs)->
          api_Paths = (api.path for api in docs.apis)
          api_Paths.assert_Contains('/content')

          swaggerService.url_Api_Docs.append("/content").GET_Json (data)->
            data.apiVersion    .assert_Is('1.0.0')
            data.swaggerVersion.assert_Is('1.2')
            data.resourcePath  .assert_Is('/content')
            clientApi.assert_Is_Object()
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
          done()