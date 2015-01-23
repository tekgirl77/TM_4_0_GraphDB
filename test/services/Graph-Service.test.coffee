expect        = require('chai'         ).expect
Graph_Service  = require('./../../src/services/Graph-Service')

describe 'services | Graph-Service.test |', ->
  describe 'core |', ->
    it 'check ctor', ->
      graphService  = new Graph_Service()
      expect(Graph_Service      ).to.be.an  ('Function')
      expect(graphService       ).to.be.an  ('Object'  )
      expect(graphService.dbPath).to.be.an  ('String'  )
      expect(graphService.db    ).to.equal  (null)
      expect(graphService.dbName).to.contain('_tmp_db')
      expect(graphService.dbPath).to.contain('.tmCache/_tmp_db')
      expect(graphService.dbPath.folder_Delete_Recursive()).to.be.true

      graphService  = new Graph_Service('aaaa')
      expect(graphService.dbName).to.equal('aaaa')
      expect(graphService.dbPath).to.equal('./.tmCache/aaaa')
      expect(graphService.dbPath.folder_Delete_Recursive()).to.be.true

    it 'openDb and closeDb', (done)->
      graphService  = new Graph_Service()

      expect(graphService.openDb).to.be.an('function')
      expect(graphService.closeDb).to.be.an('function')

      expect(graphService.dbPath.folder_Exists()).to.equal(false)
      expect(graphService.db                    ).to.equal(null)
      graphService.openDb ->
        expect(graphService.db                    ).to.not.equal(null)

        graphService.closeDb ->
          expect(graphService.dbPath.folder_Delete_Recursive()).to.equal(true)
          expect(graphService.db                              ).to.equal(null)
          done()

    #xit 'deleteDb', (done) ->
    #  using new Graph_Service(),->
    #    @.openDb =>
    #      #process.nextTick =>
    #      10.wait ()=>
    #        @.dbPath.assert_File_Exists()
    #        @.deleteDb =>
    #          @.dbPath.assert_File_Not_Exists()
    #          done()


  describe 'data operations |', ->
    graphService  = new Graph_Service()

    before (done) ->
      graphService.openDb done

    after (done) ->
      graphService.deleteDb done

    it 'add', (done)->
      expect(graphService.add).to.be.an('function')
      graphService.allData (data)->
        expect(data).to.be.empty
        graphService.add "a","b","c", ->
          graphService.query  "subject", "a", (data)->
            expect(data                  ).to.not.equal(null)
            expect(data                  ).to.be.an('array')
            expect(data.first()          ).to.be.an('object')
            expect(data.first().subject  ).to.equal('a')
            expect(data.first().predicate).to.equal('b')
            expect(data.first().object   ).to.equal('c')
            done()

    it 'get_Subject', (done)->
      expect(graphService.get_Subject).to.be.an('function')
      graphService.get_Subject "a", (data)->
        expect(data).to.deep.equal [{ subject: 'a', predicate : 'b', object:'c'}]
        graphService.get_Subject "b", (data)->
          expect(data).to.deep.equal []
          done()

    it 'get_Predicate', (done)->
      expect(graphService.get_Predicate).to.be.an('function')
      graphService.get_Predicate "b", (data)->
        expect(data).to.deep.equal [{ subject: 'a', predicate : 'b', object:'c'}]
        graphService.get_Predicate "a", (data)->
          expect(data).to.deep.equal []
          done()

    it 'get_Object', (done)->
      expect(graphService.get_Object).to.be.an('function')
      graphService.get_Object "c", (data)->
        expect(data).to.deep.equal [{ subject: 'a', predicate : 'b', object:'c'}]
        graphService.get_Object "a", (data)->
          expect(data).to.deep.equal []
          done()

    it 'alldata', (done)->
      expect(graphService.allData).to.be.an('Function')
      graphService.allData  (data) ->
        expect(data.length).to.equal(1)
        expect(data       ).to.deep.equal [{ subject: 'a', predicate : 'b', object:'c'}]
        done()

    it 'del',(done)->
      graphService.del "a","b","c", ->
        graphService.allData  (data) ->
          expect(data.length).to.equal(0)
          done()

    it 'query', (done)->
      using graphService,->
        @.query "all",null, (data)=>
          size = data.size()
          @.add '1','2','3', => @.add '10','20','30', => @.add '100','200','300', =>
            @.query "all",null, (data)=>
              data.size().assert_Is(size+3)
              @.query "subject","1", (data)=>
                data.assert_Is([ { subject: '1', predicate: '2', object: '3' } ])
                @.query "predicate","20", (data)=>
                  data.assert_Is([ { subject: '10', predicate: '20', object: '30' } ])
                  @.query "object","300", (data)=>
                    data.assert_Is([ { subject: '100', predicate: '200', object: '300' } ])
                    @.query null,"300", (data)->
                      assert_Is_Null(data)
                      done()

    it 'get_Subjects', (done)->
      graphService.get_Subjects (data)->
        data.assert_Is [ '1', '10', '100' ]
        done()

    it 'get_Predicates', (done)->
      graphService.get_Predicates (data)->
        data.assert_Is [ '2', '20', '200' ]
        done()

    it 'get_Objects', (done)->
      graphService.get_Objects (data)->
        data.assert_Is [ '3', '30', '300' ]
        done()

  describe 'open and close of dbs |', ->
    it 'confirm that open_Dbs stores db ref', (done)->
      graphService  = new Graph_Service('_tm_Db1')
      originalSize = Graph_Service.open_Dbs.keys().size();
      #Object.keys(Graph_Service.open_Dbs).assert_Size_Is(0)
      graphService.openDb ->
        db = graphService.db
        Graph_Service.open_Dbs.keys().assert_Size_Is(originalSize + 1)
        graphService.openDb ->
          db.assert_Is_Equal_To(graphService.db)
          db.assert_Is_Equal_To(Graph_Service.open_Dbs[graphService.dbPath])
          Graph_Service.open_Dbs.keys().assert_Size_Is(originalSize + 1)
          graphService.closeDb ->
            Graph_Service.open_Dbs.keys().assert_Size_Is(originalSize)
            graphService.dbPath.assert_That_File_Exists()
            graphService.deleteDb ->
              graphService.dbPath.assert_That_File_Not_Exists()
              done()