cheerio         = require('cheerio'  )
expect          = require('chai'     ).expect
supertest       = require('supertest')
Server          = require('./../../src/Server')

describe 'views | views.test',->

  app = new Server().app

  it '/', (done)->
    supertest(app).get('/')
                  .expect(200)
                  .end (error,response)->
                    throw error if error
                    $ = cheerio.load(response.text)
                    expect($('#title'    ).html()).to.equal("TM 4.0 Graph DB")
                    expect($('#link_Data').html()).to.equal("data")
                    done()
