TM_Server        = require '../../src/TM-Server'
Swagger_Service  = require '../../src/services/Swagger-Service'
GraphDB_API      = require '../../src/api/GraphDB-API'

describe '| api | GraphDB-API.test', ->

  describe '| via web api',->

      tmServer       = null
      swaggerService = null
      clientApi      = null
      graphDbApi      = null

      before (done)->
        graphDbApi = new GraphDB_API()

        graphDbApi.importService.content.load_Data ->
          tmServer   = new TM_Server({ port : 12345})
          options    = { app: tmServer.app ,  port : tmServer.port}
          swaggerService = new Swagger_Service options
          swaggerService.set_Defaults()
          #swaggerService.setup()

          new GraphDB_API({swaggerService: swaggerService}).add_Methods()
          swaggerService.swagger_Setup()
          tmServer.start()

          swaggerService.get_Client_Api 'graph-db', (swaggerApi)->
            clientApi = swaggerApi
            done()

      after (done)->
        tmServer.stop ->
          done()

      it 'constructor', ->
        GraphDB_API.assert_Is_Function()

      it 'check config section exists', (done)->
        swaggerService.url_Api_Docs.GET_Json (docs)->
          api_Paths = (api.path for api in docs.apis)
          #api_Paths.assert_Contains('/list')
          api_Paths.assert_Contains('/graph-db')

          swaggerService.url_Api_Docs.append("/graph-db").GET_Json (data)->
            data.apiVersion    .assert_Is('1.0.0')
            data.swaggerVersion.assert_Is('1.2')
            data.resourcePath  .assert_Is('/graph-db')
            clientApi.assert_Is_Object()
            #clientApi.aaa.assert_Is_Function()
            #clientApi.bbb.assert_Is_Function()
            done()

      it 'contents', (done)->
        clientApi.contents { value: 'iOs'}, (data)->
          data.obj.assert_Size_Is_Bigger_Than(1700)
          done()

      it 'subjects', (done)->
        clientApi.subjects (data)->
          data.obj.assert_Not_Empty()
          done()

      it 'predicates', (done)->
        clientApi.predicates (data)->
          data.obj.assert_Not_Empty()
          done()

      it 'objects', (done)->
        clientApi.objects (data)->
          data.obj.assert_Not_Empty()
          done()

      it 'subject', (done)->
        clientApi.subject { value: 'query-'}, (data)->
          data.obj.assert_Size_Is(0)
          done()

      it 'predicate', (done)->
        clientApi.predicate { value: 'title'}, (data)->
          data.obj.assert_Size_Is_Bigger_Than(218)
          done()

      it 'object', (done)->
        clientApi.predicate { value: 'title'}, (data)->
          value = data.obj.first().object
          clientApi.object { value: value}, (data)->
            data.obj.first().object.assert_Is value
            done()

      it 'pre_obj', (done)->
        clientApi['pre_obj'] { predicate: 'is' , object: 'Article'}, (data)->
          data.obj.assert_Not_Empty()
                  .first().subject.assert_Contains 'article-'
          done()

      #it 'query', (done)->
      #  clientApi.predicate { value: 'contains-query'}, (data)->
      #    value = data.obj.first().subject
      #    clientApi.query { value: value}, (data)->
      #      data.obj.assert_Is_Object()
      #      data.obj.nodes.assert_Not_Empty()
      #      #log data.obj
      #      done()
#
      #it 'queries', (done)->
      #  clientApi.queries {}, (data)->
      #    data.obj.assert_Is_Object()
      #    data.obj.nodes.assert_Not_Empty()
      #    #log data.obj
      #    done()
#
      #it 'filter', (done)->
      #  clientApi.predicate { value: 'contains-query'}, (data)->
      #    value = data.obj.first().subject
      #    clientApi.filter { value: value}, (data)->
      #      data.obj.assert_Is_Object()
      #      data.obj.results.assert_Not_Empty()
      #      done()