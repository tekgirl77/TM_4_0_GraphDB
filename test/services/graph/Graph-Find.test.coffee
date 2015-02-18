Import_Service = require('./../../../src/services/data/Import-Service')

describe '| services | graph | Graph-Find.test', ->

  importService = null
  graph_Find    = null

  before (done)->
    using new Import_Service('tm-uno'), ->
      importService = @
      graph_Find    = @.graph_Find
      @.content.load_Data =>
        importService.graph.openDb ->
          done()

  after (done)->
    importService.graph.closeDb ->
      done()

  it 'find_Queries', (done)->
    using graph_Find, ->
      @find_Queries (queries)->
        queries.assert_Not_Empty()
        done()

  it 'find_Articles', (done)->
    using graph_Find, ->
      @find_Articles (articles)->
        articles.assert_Not_Empty()
        done()

  it 'find_Articles, find_Article_Parent_Queries, find_Query_Articles', (done)->
    using graph_Find, ->
      @.find_Articles (articles)=>
        @find_Article_Parent_Queries articles.first(), (parent_Queries)=>
          @find_Query_Articles parent_Queries.first(), (query_Articles)=>
            query_Articles.assert_Contains(articles.first())
            done()

  it 'find_Queries, find_Query_Parent_Queries, find_Query_Queries', (done)->
    using graph_Find, ->
      @.find_Queries (queries)=>
        @find_Query_Parent_Queries queries.first(), (parent_Queries)=>
          @find_Query_Queries parent_Queries.first(), (query_Queries)=>
            query_Queries.assert_Contains(queries.first())
            done()

  it 'get_Subject_Data (bad data)', (done)->
    graph_Find.get_Subject_Data null, ->
      done()