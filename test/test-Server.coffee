require 'fluentnode'
Server = require('./../src/Server')
expect = require('chai').expect

describe 'test-Server |',->

    server  = new Server()
    
    it 'check ctor',->
        expect(Server).to.be.an('Function')        
        expect(server    ).to.be.an('Object')
        expect(server.app).to.be.an('Function')
        
    it 'routes', ->        
        expect(server.routes         ).to.be.an('Function')
        expect(server.routes()       ).to.be.an('Array')        
        expect(server.routes().size()).to.be.above(0)
        
    it 'Check expected paths', ->
      expectedPaths = [ '/test' ]
      expect(server.routes()).to.deep.equal(expectedPaths)