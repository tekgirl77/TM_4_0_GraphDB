TM_Server        = require '../../src/TM-Server'
Swagger_Service  = require '../../src/services/Swagger-Service'
Search_API       = require '../../src/api/Search-API'

describe '| api | Search-API.test', ->

  describe '| via web api',->

      tmServer       = null
      swaggerService = null
      clientApi      = null
      searchApi      = null

      before (done)->
        searchApi = new Search_API()
        tmServer  = new TM_Server({ port : 12345})
        options = { app: tmServer.app ,  port : tmServer.port}
        swaggerService = new Swagger_Service options
        swaggerService.set_Defaults()
        #swaggerService.setup()

        new Search_API({swaggerService: swaggerService}).add_Methods()
        swaggerService.swagger_Setup()
        tmServer.start()

        swaggerService.get_Client_Api 'search', (swaggerApi)->
            clientApi = swaggerApi
            done()

      after (done)->
        tmServer.stop ->
          done()

      it 'constructor', ->
        Search_API.assert_Is_Function()

      it 'check search section exists', (done)->
        swaggerService.url_Api_Docs.GET_Json (docs)->
          api_Paths = (api.path for api in docs.apis)
          api_Paths.assert_Contains('/search')

          swaggerService.url_Api_Docs.append("/search").GET_Json (data)->
            data.apiVersion    .assert_Is('1.0.0')
            data.swaggerVersion.assert_Is('1.2')
            data.resourcePath  .assert_Is('/search')
            clientApi.assert_Is_Object()
            done()


      it 'article_titles', (done)->
        clientApi.article_titles (data)->
          data.obj.assert_Not_Empty()
          done()

      it 'article_summaries', (done)->
        clientApi.article_summaries (data)->
          data.obj.assert_Not_Empty()
          done()

      it 'query_titles', (done)->
        clientApi.query_titles (data)->
          data.obj.assert_Not_Empty()
          done()

      it 'search_using_text', (done)->
        text = 'Encode'
        clientApi.search_using_text { text: text}, (data)->
          data.obj.assert_Not_Empty()
          done()
      #it 'using_text', (done)->
      #  params = {text:'some text'}
      #  clientApi.using_text params, (data)->
      #    log data.obj
      #    done()