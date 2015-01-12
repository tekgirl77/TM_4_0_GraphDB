cheerio           = require('cheerio')
#expect           = require('chai'     ).expect
supertest         = require('supertest')
Filter_Controller = require('./../../src/controllers/Filter-Controller')
Import_Service    = require('./../../src/services/Import-Service')
Server            = require('./../../src/Server')

describe 'controllers | Filter-Controller.test', ->

  filterController = null
  server          = null
  app             = null
  before ->
    server           = new Server()
    app              = server.app
    filterController = new Filter_Controller(server)

  it 'check ctor',->
    Filter_Controller.assert_Is_Function()
    filterController.assert_Is_Object()
    filterController.server.assert_Is_Equal_To(server)


  it '/data/:dataId/:queryId/filter/:filterId' , (done)->
    dataId   = 'data-test'
    queryId  = 'simple'
    filterId = 'totals'
    url = "/data/#{dataId}/#{queryId}/filter/#{filterId}"
    supertest(app).get(url)
                  .expect(200)
                  .expect('Content-Type', /json/)
                  .end (error, response) ->
                    (error == null).assert_Is_True()
                    json = JSON.parse(response.text)
                    json.assert_Is_Object()
                    json.number_of_nodes.assert_Is_Equal_To(14)
                    json.number_of_edges.assert_Is_Equal_To(12)
                    done()
