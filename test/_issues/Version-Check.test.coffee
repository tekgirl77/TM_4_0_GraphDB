TM_Server         = require('./../../src/TM-Server')
supertest         = require 'supertest'
Swagger_Service   = require '../../src/services/rest/Swagger-Service'
GraphDB_API       = require '../../src/api/GraphDB-API'
Git_API = require '../../src/api/Git-API'


describe.only '| Validate Version of Graph URLs |',->

  url_server      = null
  server          = null
  swaggerService  = null
  clientApi       = null
  graphDbApi      = null

  before (done)->
    graphDbApi = new GraphDB_API()

    graphDbApi.importService.content.load_Data ->
      server   = new TM_Server({ port : 12345})
      options    = { app: server.app ,  port : server.port}
      swaggerService = new Swagger_Service options
      swaggerService.set_Defaults()
      #swaggerService.setup()

      new GraphDB_API({swaggerService: swaggerService}).add_Methods()
      new Git_API({swaggerService: swaggerService}).add_Methods()
      swaggerService.swagger_Setup()
      server.start()

      #swaggerService.get_Client_Api 'graph-db', (swaggerApi)->
      #  clientApi = swaggerApi


      done()

  after (done)->
    server.stop ->
      done()

  it 'Check /git/status page', (done)->
    supertest(server.app)
      .get('/git/status/')
      .expect(200)
      .end (err,res)->
        throw err if (err)
        done()

  it 'Check /graph-db/contents/', (done)->
    supertest(server.app)
      .get('/graph-db/contents/')
      .expect(200)
      .end (err, res)->
        throw err if (err)
        done()

  it 'Check /graph-db/subjects', (done)->
    supertest(server.app)
      .get('/graph-db/subjects/')
      .expect(200)
      .end (err, res)->
        throw err if (err)
        done()