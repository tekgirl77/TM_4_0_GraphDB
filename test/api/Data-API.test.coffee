TM_Server        = require '../../src/TM-Server'
Swagger_Service  = require '../../src/services/Swagger-Service'
Data_API = require '../../src/api/Data-API'

describe '| api | Data-API.test', ->

  describe '| via web api',->

      tmServer       = null
      swaggerService = null
      clientApi      = null
      dataApi      = null

      before (done)->
        dataApi = new Data_API()
        tmServer  = new TM_Server({ port : 12345})
        options = { app: tmServer.app ,  port : tmServer.port}
        swaggerService = new Swagger_Service options
        swaggerService.set_Defaults()
        #swaggerService.setup()

        new Data_API({swaggerService: swaggerService}).add_Methods()
        swaggerService.swagger_Setup()
        tmServer.start()

        swaggerService.get_Client_Api 'data', (swaggerApi)->
            clientApi = swaggerApi
            done()

      after (done)->
        tmServer.stop ->
          done()

      it 'constructor', ->
        Data_API.assert_Is_Function()

      it 'check data section exists', (done)->
        swaggerService.url_Api_Docs.GET_Json (docs)->
          api_Paths = (api.path for api in docs.apis)
          api_Paths.assert_Contains('/data')

          swaggerService.url_Api_Docs.append("/data").GET_Json (data)->
            data.apiVersion    .assert_Is('1.0.0')
            data.swaggerVersion.assert_Is('1.2')
            data.resourcePath  .assert_Is('/data')
            clientApi.assert_Is_Object()
            done()

      it 'article', (done)->
        clientApi.articles (data)->
          articles = data.obj
          article_Id = articles.keys().first()
          article = articles[articles.keys().first()]
          log article_Id
          clientApi.article {id: article_Id }, (data)->
            data.obj[article_Id].assert_Is(article)
            done()

      it 'articles', (done)->
        clientApi.articles (data)->
          data.obj.keys().assert_Size_Is_Bigger_Than(50)
          done()

      it 'queries', (done)->
        clientApi.queries (data)->
          data.obj.assert_Size_Is_Bigger_Than(10)
          done()