expect          = require('chai'     ).expect
supertest       = require('supertest')
Data_Controller = require('./../../src/controllers/Data-Controller')
Server          = require('./../../src/Server')

describe 'test-Data-Controller |', ->
  describe 'core |', ->
    it 'check ctor',->
      dataController = new Data_Controller()
      expect(Data_Controller      ).to.be.an('function')
      expect(dataController       ).to.be.an('object')
      expect(dataController.server).to.be.undefined

      server = new Server()
      dataController = new Data_Controller(server)
      expect(dataController.server).to.equal(server)

  describe 'routes |', ->
    server         = new Server()
    app            = server.app
    dataController = new Data_Controller(server).add_Routes()

    before ->
      expect(app           ).to.be.an        ('function')
      expect(server        ).to.be.instanceOf(Server)
      expect(dataController).to.be.instanceOf(Data_Controller)

    it 'add_Routes', ->
      expect(dataController.server.routes()).to.contain('/data/:name')
      #console.log(dataController.server.routes())

    it '/data/' , (done)->
      supertest(app).get('/data')
                    .expect(404)
                    .end (error, response) ->
                      expect(response.text).to.equal('Cannot GET /data\n')
                      done()

    it '/data/:name' , (done)->
      supertest(app).get('/data/v0.1')
                    .expect(200)
                    .expect('Content-Type', /json/)
                    .end (error, response) ->
                      expect(error).to.be.null
                      json = JSON.parse(response.text)
                      expect(json       ).to.be.an('array')
                      expect(json.size()).to.equal(6)
                      expect(json.first().subject  ).to.equal('a')
                      expect(json.first().predicate).to.equal('b1')
                      expect(json.first().object   ).to.equal('c1')
                      done()

  describe 'default data sets |', ->
    server         = new Server()
    app            = server.app
    dataController = new Data_Controller(server).add_Routes()
    it '/data/v0.1-gist' , (done)->
      supertest(app).get("/data/v0.1-gist")
      .expect(200)
      .expect('Content-Type', /json/)
      .end (error, response) ->
        json = JSON.parse(response.text)
        expect(json       ).to.be.an('array')
        expect(json.size()).to.equal(83)
        expect(json.first().subject  ).to.equal('1106d793193b')
        expect(json.first().predicate).to.equal('Summary')
        expect(json.first().object   ).to.equal('...')
        done()