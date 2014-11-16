#return #long running test - move into CI server
async            = require 'async'
Cache_Service    = require('./../../src/services/Cache-Service')
Graph_Service    = require('./../../src/services/Graph-Service')
Import_Service   = require('./../../src/services/Import-Service')
Data_Import_Util = require('./../../src/utils/Data-Import-Util')
Guid             =  require('./../../src/utils/Guid')

describe '_to_move_to_ci | test-tm-uno | test-data-import |', ->

  describe 'load tm-uno data set', ->
    #@timeout 10000  # for the cases when data needs to be loaded from the network
    importService     = null

    before (done)->
      importService     = new Import_Service('tm-uno')
      #"opening the db".log()
      importService.graph.openDb ->
        done()

    after (done)->
      #"closing the db".log()
      importService.graph.closeDb ->
        done()


    it 'loadData',  (done)->
      importService.load_Data.assert_Is_Function()
      importService.load_Data ->
        importService.graph.allData (data)->
          data.assert_Is_Array()
          done()

    it 'run query - library', (done)->
      importService.run_Query 'library',  {},(graph)->
        #console.log graph.nodes.size()
        graph.nodes.assert_Is_Object()
        done()

    it 'run query - library-all', (done)->
      importService.run_Query 'library-all',  {},(graph)->
        #console.log graph
        graph.nodes.assert_Is_Object()
        done()

    it 'run query - folders-and-views', (done)->
      importService.run_Query 'folders-and-views', {}, (graph)->
        #console.log graph.json_pretty()
        graph.nodes.assert_Is_Object()
        done()

    it 'run query - folder-metadata', (done)->
      options = {show:'Top iOS Threats'}
      #{show:'Canonicalization'}
      options.show ="Test Folder"

      importService.load_Data ->
        importService.run_Query 'folder-metadata', options, (graph)->
          importService.graph.allData (allData)->
            #console.log graph.json_pretty()
            graph.nodes.assert_Is_Object()
            done()

    it 'run query - folder-metadata', (done)->
      options = {}
      #importService.load_Data ->
      importService.graph.openDb ->
        importService.run_Query 'folder-metadata', options, (graph)->
          "There are #{graph.nodes.size()} and #{graph.edges.size()} edges".log()
          #console.log graph
          done();

    it.only 'run query - search', (done)->
      #@timeout(20000)
      options = { show: 'iOS'}
      #importService.load_Data ->
      importService.graph.openDb ->
        importService.run_Query 'search', options, (graph)->
          "There are #{graph.nodes.size()} and #{graph.edges.size()} edges".log()
          importService.run_Filter 'tm-search' , graph, (data)->
            console.log data.containers
            done();


describe 'Filters', ->
  it 'tm-uno , folder-metadata tm-search',(done)->
    data_id   = 'tm-uno'          #'data-test'
    query_Id  = 'folder-metadata' # 'simple'
    filter_Id = 'tm-search'       #totals'
    options   = { show : 'Logging'}

    importService = new Import_Service(data_id)
    importService.setup ->
      importService.load_Data ->
      #importService.graph.openDb ->
        importService.run_Query query_Id, options, (graph)->
          importService.run_Filter filter_Id, graph, (data)->
            importService.graph.closeDb ->
              #console.log data
              data.title.assert_Is_String()
              #data.containers.assert_Not_Empty()
              #data.results.assert_Not_Empty()
              done()
