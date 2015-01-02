expect        = require('chai'         ).expect
Graph_Service  = require('./../../src/services/Graph-Service')

describe 'services | test-Graph-Service |', ->
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

      expect(graphService.openDb).to.be.an('function');
      expect(graphService.closeDb).to.be.an('function');

      expect(graphService.dbPath.folder_Exists()).to.equal(false)
      expect(graphService.db                    ).to.equal(null)
      graphService.openDb ->
        expect(graphService.db                    ).to.not.equal(null)

        graphService.closeDb ->
          expect(graphService.dbPath.folder_Delete_Recursive()).to.equal(true)
          expect(graphService.db                              ).to.equal(null)
          done()

    it 'deleteDb', (done) ->
      using new Graph_Service(),->
        @.openDb =>
          @.dbPath.assert_File_Exists()
          @.deleteDb =>
            @.dbPath.assert_File_Not_Exists()
            done()


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

###

  it 'graphDataFromQAServer', (done)->
    expect(graphService.graphDataFromQAServer).to.be.an('Function')
    graphService.graphDataFromQAServer (graphData)->
      expect(graphData      ).to.be.an('Object')
      expect(graphData.nodes).to.be.an('Array')
      expect(graphData.edges).to.be.an('Array')
      done()

  xit 'mapNodesFromGraphData', (done)->
    expect(graphService.mapNodesFromGraphData).to.be.an('Function')
    graphService.graphDataFromQAServer (graphData)->
      graphService.mapNodesFromGraphData graphData, (nodes)->
        expect(nodes            ).to.be.an('Object')
        expect(nodes.nodes_by_Id).to.be.an('Object')
        expect(nodes.nodes_by_Is).to.be.an('Object')
        expect(Object.keys(nodes.nodes_by_Id).length).to.equal(graphData.nodes.length)
        done()

  xit 'createSearchDataFromGraphData', (done)->

    viewName          = 'Data Validation'
    container_Title   = 'Perform Validation on the Server'
    container_Id      = '4eef2c5f-7108-4ad2-a6b9-e6e84097e9e0'
    container_Size    = 3
    resultsTitle      = '8/8 results showing'
    result_Title      = 'Client-side Validation Is Not Relied On'
    result_Link       = 'https://tmdev01-sme.teammentor.net/9607b6e3-de61-4ff7-8ef0-9f8b44a5b27d'
    result_Id         = '9607b6e3-de61-4ff7-8ef0-9f8b44a5b27d'
    result_Summary    = 'Verify that the same or more rigorous checks are performed on the server as
                             on the client. Verify that client-side validation is used only for usability
                             and to reduce the number of posts to the server.'
    result_Score      = 0
    view_Title        = 'Technology'
    view_result_Title = 'ASP.NET 4.0'
    view_result_Size  = 1

    checkSearchData = (data)->
      #console.log(data)
      expect(data             ).to.be.an('Object')

      expect(data.title       ).to.be.an('String')
      expect(data.containers  ).to.be.an('Array' )
      expect(data.resultsTitle).to.be.an('String')
      expect(data.results     ).to.be.an('Array' )
      expect(data.filters     ).to.be.an('Array' )

      expect(data.title                   ).to.equal(viewName)
      done()
      return
      expect(data.containers.first().title).to.equal(container_Title)
      expect(data.containers.first().id   ).to.equal(container_Id   )
      expect(data.containers.first().size ).to.equal(container_Size )
      expect(data.resultsTitle            ).to.equal(resultsTitle   )
      expect(data.results.first().title   ).to.equal(result_Title)
      expect(data.results.first().link    ).to.equal(result_Link)
      expect(data.results.first().id      ).to.equal(result_Id)
      expect(data.results.first().summary ).to.equal(result_Summary)
      expect(data.results.first().score   ).to.equal(result_Score)

      firstFilter = data.filters.first()
      expect(firstFilter.title                ).to.equal(view_Title)
      expect(firstFilter.results              ).to.be.an('Array' )
      expect(firstFilter.results.first().title).to.equal(view_result_Title)
      expect(firstFilter.results.first().size ).to.equal(view_result_Size)

      done()

    expect(graphService.createSearchDataFromGraphData).to.be.an('Function')
    graphService.graphDataFromQAServer (graphData) ->
      graphService.createSearchDataFromGraphData graphData, (searchData)->
        checkSearchData(searchData)

  return
  #    it 'dataFilePath',->
  #        expect(              graphService.dataFilePath   ).to.be.an('Function')
  #        expect(              graphService.dataFilePath() ).to.be.an('String')
  #        expect(fs.existsSync(graphService.dataFilePath())).to.be.true
  #
  #    it 'dataFromFile', ->
  #        expect(              graphService.dataFromFile   ).to.be.an('Function')
  #        data = graphService.dataFromFile()
  #        expect(data        ).to.be.an('Array')
  #        expect(data        ).to.not.be.empty
  #        expect(data.first()).to.not.be.empty
  #
  #        expect(data.first().subject).to.be.an('String')
  #        expect(data.first().predicate).to.be.an('String')
  #        expect(data.first().object).to.be.an('String')

  it 'dataFromGitHub', (done)->
    expect(graphService.dataFromGitHub   ).to.be.an('Function')
    graphService.dataFromGitHub (data)->
      expect(data        ).to.be.an('Array')
      expect(data        ).to.not.be.empty
      expect(data.first()).to.not.be.empty

      expect(data.first().subject).to.be.an('String')
      expect(data.first().predicate).to.be.an('String')
      expect(data.first().object).to.be.an('String')
      done()

  it 'loadTestData', (done)->
    expect(graphService.loadTestData).to.be.an('Function')
    graphService.loadTestData () ->
      expect(graphService.data).to.not.be.empty
      expect(graphService.data.length).to.be.above(50)
      #graphService.closeDb()
      done()


  it 'query', (done)->
    expect(graphService.query).to.be.an('Function')

    items = [{ key : "subject"  , value: "bcea0b7ace25" , hasResults:true }
      { key : "subject"  , value: "...."         , hasResults:false}
      { key : "predicate", value: "View"         , hasResults:true }
      { key : "predicate", value: "...."         , hasResults:false}
      { key : "object"   , value: "Design"       , hasResults:true }]
    #items = []
    checkItem = ->
      if(items.empty())
        done()
      else
        item = items.pop()
        graphService.query item.key, item.value, (err, data)->
          if (item.hasResults)
            expect(data).to.not.be.empty
            expect(JSON.stringify(data)).to.contain(item.key)
            expect(JSON.stringify(data)).to.contain(item.value)
          else
            expect(data).to.be.empty
          checkItem()
    checkItem()


  it 'createSearchData' , (done)->

    viewName          = 'Data Validation'
    container_Title   = 'Perform Validation on the Server'
    container_Id      = '4eef2c5f-7108-4ad2-a6b9-e6e84097e9e0'
    container_Size    = 3
    resultsTitle      = '8/8 results showing'
    result_Title      = 'Client-side Validation Is Not Relied On'
    result_Link       = 'https://tmdev01-sme.teammentor.net/9607b6e3-de61-4ff7-8ef0-9f8b44a5b27d'
    result_Id         = '9607b6e3-de61-4ff7-8ef0-9f8b44a5b27d'
    result_Summary    = 'Verify that the same or more rigorous checks are performed on the server as
                             on the client. Verify that client-side validation is used only for usability
                             and to reduce the number of posts to the server.'
    result_Score      = 0
    view_Title        = 'Technology'
    view_result_Title = 'ASP.NET 4.0'
    view_result_Size  = 1

    checkSearchData = (data)->
      #console.log(data)
      expect(data             ).to.be.an('Object')
      expect(data.title       ).to.be.an('String')
      expect(data.containers  ).to.be.an('Array' )
      expect(data.resultsTitle).to.be.an('String')
      expect(data.results     ).to.be.an('Array' )
      expect(data.filters     ).to.be.an('Array' )

      expect(data.title                   ).to.equal(viewName)
      expect(data.containers.first().title).to.equal(container_Title)
      expect(data.containers.first().id   ).to.equal(container_Id   )
      expect(data.containers.first().size ).to.equal(container_Size )
      expect(data.resultsTitle            ).to.equal(resultsTitle   )
      expect(data.results.first().title   ).to.equal(result_Title)
      expect(data.results.first().link    ).to.equal(result_Link)
      expect(data.results.first().id      ).to.equal(result_Id)
      expect(data.results.first().summary ).to.equal(result_Summary)
      expect(data.results.first().score   ).to.equal(result_Score)

      firstFilter = data.filters.first()
      expect(firstFilter.title                ).to.equal(view_Title)
      expect(firstFilter.results              ).to.be.an('Array' )
      expect(firstFilter.results.first().title).to.equal(view_result_Title)
      expect(firstFilter.results.first().size ).to.equal(view_result_Size)

      done()

    graphService.createSearchData viewName, checkSearchData
###