cheerio          = require('cheerio')
expect           = require('chai'     ).expect
supertest        = require('supertest')
Graph_Controller = require('./../../src/controllers/Graph-Controller')
Import_Service   = require('./../../src/services/Import-Service')
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
    server         = null
    app            = null
    dataId         = "_tmp_".add_Random_String()
    queryId        = "simple-graph"
    import_Service = null
    graphId        = "graph"
    graphTitle     = "Graph View (with Ajax load)"


    before (done)->
      server     = new Server()
      app        = server.app
      import_Service = new Import_Service(dataId)
      expect(import_Service.path_Name.folder_Exists()).to.be.false
      import_Service.setup ->
        expect(import_Service.path_Name.folder_Exists()).to.be.true
        done()

    after ->
      expect(import_Service.path_Name.folder_Delete_Recursive()).to.be.true

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

    it 'ajaxLoad.js', (done)->
      getResponseText '/data/graphs/scripts/ajaxLoad.js', null , (responseText)->
        expect(responseText).to.not.equal('//file not found')
        done()

    it 'articleViewer.js', (done)->
      getResponseText '/data/graphs/scripts/articleViewer.js', null , (responseText)->
        expect(responseText).to.not.equal('//file not found')
        done()

    it 'AAAA.js', (done)->
      getResponseText '/data/graphs/scripts/AAAA.js', null,  (responseText)->
        expect(responseText).to.equal('//file not found')
        done()

    it 'jquery.min.js', (done)->
      getResponseText '/lib/jquery.min.js', null, (responseText)->
        #expect(responseText).to.contain('jQuery v2.0.3')
        done()

    it '/lib/vis.js', (done)->
      getResponseText '/lib/vis.js', null, (responseText)->
        expect(responseText).to.contain('https://github.com/almende/vis')
        done()

    it '/lib/vis.css', (done)->
      getResponseText '/lib/vis.css',/css/,  (responseText)->
        expect(responseText).to.contain('.vis .overlay')
        done()