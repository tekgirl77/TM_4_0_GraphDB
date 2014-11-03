cheerio          = require('cheerio')
expect           = require('chai'     ).expect
supertest        = require('supertest')
Graph_Controller = require('./../../src/controllers/Graph-Controller')
Db_Service       = require('./../../src/services/Db-Service')
Server           = require('./../../src/Server')

describe 'controllers | test-Graph-Controller |', ->
  describe 'core |', ->
    it 'check ctor',->
      graphController = new Graph_Controller()
      expect(Graph_Controller      ).to.be.an('function')
      expect(graphController       ).to.be.an('object')
      expect(graphController.server).to.be.undefined

      server = new Server()
      graphController = new Graph_Controller(server)
      expect(graphController.server).to.equal(server)



  describe 'routes |', ->
    server         = new Server()
    app            = server.app
    dataId         = "_tmp_".add_Random_String()
    queryId        = "simple-graph"
    graphId        = "graph"
    graphTitle     = "Graph View (with Ajax load)"

    db_Service     = new Db_Service(dataId)

    before ->
      expect(db_Service.path_Name.folder_Exists()).to.be.false
      db_Service.setup()
      expect(db_Service.path_Name.folder_Exists()).to.be.true

    after ->
      expect(db_Service.path_Name.folder_Delete_Recursive()).to.be.true

    it 'add_Routes', ->
      expect(server.routes()).to.contain('/data/:dataId/:queryId/:graphId')
      expect(server.routes()).to.contain('/data/graphs/scripts/:script.js')


    it '/data/:dataId:/queryId:/graphId', (done)->
      url ="/data/#{dataId}/#{queryId}/#{graphId}"
      supertest(app).get(url)
                    .end (error, response)->
                      $ =cheerio.load(response.text)
                      expect($('#title').html()).to.equal(graphTitle)
                      done();

  describe 'routes | /data/graphs/scripts/*', ->

    getResponseText = (url,contentType, callback )->
      supertest(new Server().app).get(url)
                                 .expect('Content-Type', contentType || /javascript/)
                                 .end (error, response)->
                                   throw error if error
                                   callback(response.text)

    it 'first.js', (done)->
      getResponseText '/data/graphs/scripts/ajaxLoad.js', null , (responseText)->
        expect(responseText).to.not.equal('//file not found')
        done()

    it 'AAAA.js', (done)->
      getResponseText '/data/graphs/scripts/AAAA.js', null,  (responseText)->
        expect(responseText).to.equal('//file not found')
        done()

    it 'jquery.min.js', (done)->
      getResponseText '/lib/jquery.min.js', null, (responseText)->
        expect(responseText).to.contain('jQuery v2.0.3')
        done()

    it '/lib/vis.js', (done)->
      getResponseText '/lib/vis.js', null, (responseText)->
        expect(responseText).to.contain('https://github.com/almende/vis')
        done()

    it '/lib/vis.css', (done)->
      getResponseText '/lib/vis.css',/css/,  (responseText)->
        expect(responseText).to.contain('.vis .overlay')
        done()