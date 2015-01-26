TM_Server        = require '../../src/TM-Server'
Swagger_Service  = require '../../src/services/Swagger-Service'
Data_API         = require '../../src/api/Data-API'

describe '| api | Data-API.test', ->

  describe '| via web api |',->

      tmServer       = null
      swaggerService = null
      clientApi      = null
      dataApi      = null

      before (done)->
        dataApi = new Data_API()
        tmServer  = new TM_Server({ port : 12346})
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

      it 'id', (done)->
        clientApi.articles (data)->
          articles = data.obj
          article_Id = articles.keys().first()
          article = articles[articles.keys().first()]
          clientApi.id {id: article_Id }, (data)->
            data.obj[article_Id].assert_Is(article)
            done()

      it 'articles', (done)->
        clientApi.articles (data)->
          data.obj.keys().assert_Size_Is_Bigger_Than(50)
          done()

      it 'library', (done)->
        clientApi.library (data)->
          library = data.obj
          library.assert_Is_Object()
          library.folders.assert_Not_Empty()
          library.articles.assert_Not_Empty()
          done()

      it 'queries', (done)->
        clientApi.queries (data)->
          data.obj.assert_Size_Is_Bigger_Than(10)
          done()

      it 'queries, query_parent_queries', (done)=>
        clientApi.queries (data)=>
          query_Id    = data.obj.first().id
          clientApi.query_parent_queries {id:query_Id}, (data)=>
            parent_Query = data.obj.first()
            clientApi.queries {id:parent_Query}, (data)=>
              (item.id for item in data.obj).assert_Contains(query_Id)
              done()

      it 'queries_mappings, query_mappings', (done)=>
        clientApi.queries_mappings (data)=>
          queries_Mappings = data.obj
          queriesIds = queries_Mappings.keys()
          clientApi.query_mappings {id: queriesIds.first()}, (data)=>
            query_Mappings = data.obj
            query_Mappings.assert_Is(queries_Mappings[queriesIds.first()])
            done()

      it 'root_queries, query_tree', (done)=>
        clientApi.root_queries (data)=>
          root_Queries = data.obj
          query_Id = root_Queries.queries.first().id
          clientApi.query_tree {id: query_Id }, (data)=>
            query_Tree = data.obj
            query_Tree.id.assert_Is(query_Id )
            done()

      it 'articles_queries', (done)=>
        clientApi.articles_queries (articles_Queries)=>
          articles_Queries.keys().assert_Not_Empty()
          done();

      xit 'articles, article_parent_queries', (done)=>
        clientApi.articles (data)=>
          article_Id = data.obj.keys().first()
          clientApi.article_parent_queries { id: article_Id }, (data) =>
            query_Id = data.obj.first()
            clientApi.articles { id: query_Id }, (data)=>
              data.obj.keys().contains(article_Id)
              done()
