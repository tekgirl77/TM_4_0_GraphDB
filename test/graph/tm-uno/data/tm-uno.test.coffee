TM_Guidance         = require '../../../../src/graph/tm-uno/data/tm-uno'
Import_Service = require '../../../../src/services/Import-Service'

describe '| graph | tm-uno | data', ->

  tmGuidance = null

  beforeEach ->
    options = { importService : new Import_Service() }
    tmGuidance  = new TM_Guidance options

  afterEach (done)->
    tmGuidance.importService.graph.closeDb ->
      done()

  it 'constructor',->
    TM_Guidance.assert_Is_Function()
    tmGuidance.importService.assert_Is_Object()
    #tm_uno.library_Name = 'Guidance'

  it 'setupDb', (done)->
    tm_uno = new TM_Guidance()

    using tmGuidance, ->
      @.setupDb ->
        @.library.assert_Is_Object()
        done();

  it 'create_Metadata_Global_Nodes', (done)->
    using tmGuidance, ->
      @.setupDb =>
        @.create_Metadata_Global_Nodes =>
          @.importService.graph.allData (data)->
            data.assert_Size_Is(12)
            done()

  it '(add library query)', (done)->
    using tmGuidance, ->
      @.setupDb =>
        @.importService.library (library)=>
          @.importService.add_Db_using_Type_Guid_Title 'Query', library.id, library.name, (library_Id)=>
            @.importService.graph.allData (data)->
              data.first() .object   .assert_Is_String()
              data.second().object   .assert_Is_String()
              data.third() .predicate.assert_Is('guid')
              done()

  it 'import_Articles',(done)->
    using tmGuidance, ->
      @.setupDb =>
        @.importService.library (library)=>
          @.create_Metadata_Global_Nodes =>
            @.importService.add_Db_using_Type_Guid_Title 'Query', library.id, library.name, (library_Id)=>
              @.import_Articles library.id, library.articles.take(1), =>
                @.importService.graph.allData (data)->
                  data.assert_Size_Is(36)
                  done()

  it 'load_Data', (done)->
    @timeout 10000
    using tmGuidance, ()->
      @.load_Data ()=>
        @.importService.graph.allData (data)->
          data.assert_Size_Is_Bigger_Than(1941)
          done()