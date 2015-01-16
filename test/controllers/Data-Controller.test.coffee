cheerio         = require('cheerio')
expect          = require('chai'     ).expect
supertest       = require('supertest')
Data_Controller = require('./../../src/controllers/Data-Controller')
Server          = require('./../../src/Server')

describe 'controllers | Data-Controller.test', ->
  server = new Server()
  app    = server.app
  dataController = new Data_Controller(server)


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

    before ->
      expect(app           ).to.be.an        ('function')
      expect(server        ).to.be.instanceOf(Server)
      expect(dataController).to.be.instanceOf(Data_Controller)

    it 'add_Routes', ->
      expect(dataController.server.routes()).to.contain('/data/:name')
      #console.log(dataController.server.routes())



 #  it '/data/' , (done)->
 #    supertest(app).get('/data')
 #                  .expect(200)
 #                  .end (error, response) ->
 #                    $ = cheerio.load(response.text)
 #                    $('#title').html().assert_Is("Available data")
 #                    #expect($('#baseFolder').html()).to.equal("db")
 #                    $('#dataIds').length.assert_Bigger_Than(0)

 #                    firstDataId = $('#dataIds a')
 #                    expect(firstDataId.html()        ).to.equal('data-test')
 #                    expect(firstDataId.attr('id'    )).to.equal('data-test')
 #                    expect(firstDataId.attr('href'  )).to.equal('/data/data-test')
 #                    expect(firstDataId.attr('target')).to.equal('_blank')

 #                    firstQueryId = $('#queries a')
 #                    expect(firstQueryId.html()        ).to.equal('simple')
 #                    expect(firstQueryId.attr('id'    )).to.equal('simple')
 #                    expect(firstQueryId.attr('href'  )).to.equal('/data/data-test/simple')
 #                    expect(firstQueryId.attr('target')).to.equal('_blank')

 #                    firstGraphId = $('#graphs a')
 #                    expect(firstGraphId.html()        ).to.equal('graph-wide')
 #                    expect(firstGraphId.attr('id'    )).to.equal('graph-wide')
 #                    expect(firstGraphId.attr('href'  )).to.equal('/data/data-test/simple/graph-wide')
 #                    expect(firstGraphId.attr('target')).to.equal('_blank')
 #                     done()


    #it '/data/:name' , (done)->
    #  supertest(app).get('/data/data-test')
    #                .expect(200)
    #                .expect('Content-Type', /json/)
    #                .end (error, response) ->
    #                  expect(error).to.be.null
    #                  json = JSON.parse(response.text)
    #                  expect(json       ).to.be.an('array')
    #                  expect(json.size()).to.equal(12)
    #                  expect(json.first() .subject  ).to.equal('Principles')
    #                  expect(json.first() .predicate).to.equal('have')
    #                  expect(json.first() .object   ).to.equal('Guidelines')
    #                  expect(json.fourth().subject  ).to.equal('a')
    #                  expect(json.fourth().predicate).to.equal('b1')
    #                  expect(json.fourth().object   ).to.equal('c1')
    #                  done()

  ###

  describe 'default data sets |', ->
    it '/data/v0.1-gist' , (done)->
      supertest(app).get("/data/v0.1-gist")
                    .expect(200)
                    .expect('Content-Type', /json/)
                    .end (error, response) ->
                      throw error if error
                      json = JSON.parse(response.text)
                      expect(json       ).to.be.an('array')
                      expect(json.size()).to.equal(83)
                      expect(json.first().subject  ).to.equal('1106d793193b')
                      expect(json.first().predicate).to.equal('Summary')
                      expect(json.first().object   ).to.equal('...')
                      done()

  #this is the code that was inside the v0.1-gist.coffee file

  GitHub_Service = require(process.cwd() + '/src/services/GitHub-Service')

  add_Data = (dataUtil, callback)->
    gist_Id   = '456938ffc68d151bea96'
    gist_File = 'article-data.json'
    new GitHub_Service().enableCache().gist gist_Id, gist_File, (gistData) ->
      dataUtil.data = JSON.parse(gistData.content)
      callback()
  module.exports = add_Data

  ###
