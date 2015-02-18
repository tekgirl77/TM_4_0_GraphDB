Import_Service = require('./../../../src/services/data/Import-Service')
async          = require('async')

describe '| services | data | Import-Service.test', ->

  describe 'core', ->
    importService = null

    before ->
      importService = new Import_Service('Import-Service.test')

    after (done)->
      importService.graph.deleteDb ->
        importService.cache.cacheFolder().folder_Delete_Recursive()
        done()

    it 'check ctor()', ->
      Import_Service.assert_Is_Function()
      importService             .assert_Is_Object()
      importService.name        .assert_Is_String()
      importService.cache       .assert_Is_Object()#.assert_Instance_Of()
      importService.graph       .assert_Is_Object()
      importService.path_Root   .assert_Is_String()
      importService.path_Name   .assert_Is_String()

      importService.name        .assert_Is 'Import-Service.test'
      importService.path_Root   .assert_Is('.tmCache')
      importService.path_Name   .assert_Is('.tmCache/Import-Service.test')
      importService.path_Name.folder_Delete_Recursive().assert_Is_True()

    it 'check ctor (name)', (done)->
      aaaa_ImportService  = new Import_Service('aaaa')
      aaaa_ImportService.name         .assert_Is 'aaaa'
      aaaa_ImportService.path_Name    .assert_Is '.tmCache/aaaa'
      aaaa_ImportService.graph.dbName .assert_Is 'aaaa'
      aaaa_ImportService.graph.deleteDb ->
        aaaa_ImportService.cache.cacheFolder().folder_Delete_Recursive()
        done()

    it 'setup', (done)->
      importService.setup.assert_Is_Function()
      (importService.graph.db is null).assert_Is_True()
      importService.setup ->
        importService.graph.dbPath.assert_That_File_Exists()
        done()

    it 'add_Db and find_Subject', (done)->
      type = 'test'
      guid = "aaaa-bbbc-cccc-dddd"
      data = { b:'c_'.add_Random_Letters() , d: 'e_'.add_5_Random_Letters()}
      importService.add_Db type, guid, data, (id)->
        importService.get_Subject_Data id, (id_Data)->
          id_Data.assert_Is_Object()
          id_Data.b.assert_Is(data.b)
          id_Data.d.assert_Is(data.d)
          done()

    it 'add_Is, find_Using_Is', (done)->
      id    = 'is_id'
      value = 'is_value'
      importService.add_Is id, value, ->
        importService.find_Using_Is value, (data)->
          data.first().assert_Is(id)
          done()

    it 'add_Is, find_Using_Title', (done)->
      id    = 'title_id'
      value = 'title_value'
      importService.add_Title id, value, ->
        importService.find_Using_Title value, (data)->
          data.first().assert_Is(id)
          done();


    it 'new_Short_Guid', ->
      importService.new_Short_Guid.assert_Is_Function()
      importService.new_Short_Guid('aaa').starts_With('aaa').assert_Is_True()
      importService.new_Short_Guid('bbb','b56ddd610d9e'    ).assert_Is('bbb-b56ddd610d9e')

    it 'new_Data_Import_Util', ->
      importService.new_Data_Import_Util.assert_Is_Function()
      importService.new_Data_Import_Util().assert_Is_Object()

    it 'get_Subject_Data (bad data)', (done)->
      importService.get_Subject_Data null, ->
        done()

  describe '| load Library data |',->
    importService = null

    before (done)->
      using new Import_Service('_load_library_data'), ->
        importService = @
        @.content.load_Data ->
          done()

    after ->
      importService.cache.cacheFolder().folder_Delete_Recursive()

    it 'library_Json', (done)->
      importService.library (library)->
        importService.library_Json (library_Json)->
          library_Json.assert_Is_Object()
          using library_Json.guidanceExplorer.library.first()["$"], ->
            @.name.assert_Is library.id
            @.caption.assert_Is library.name
            done()

    it 'parse_Library_Json', (done)->
      importService.library (library)->
        importService.library_Json (library_Json)->
          importService.library_Json (json)->
            importService.parse_Library_Json (json), (_library)->
              using _library, ->
                @.id      .assert_Is library.id
                @.name    .assert_Is library.name
                @.folders .assert_Size_Is_Bigger_Than(0)
                @.articles.assert_Size_Is_Bigger_Than(0)
                @.views   .assert_Empty()
                done()

    it 'library', (done)->
      importService.library (library)->
        library.name.assert_Is_String()
        done()

    it 'article_Data', (done)->
        using importService, ->
          @.library (library)=>
            @.article_Data library.articles.first(), (article_Data)->
              article_Data.assert_Is_Object()
              done()



  describe '| search Library data |',->

    importService = null

    before (done)->
      using new Import_Service('tm-uno'), ->
        importService = @
        @.content.load_Data =>
          importService.graph.openDb ->
            done()

    after (done)->
      importService.graph.closeDb ->
        done()

    it 'find_Queries', (done)->
      using importService, ->
        @find_Queries (queries)->
          queries.assert_Not_Empty()
          done()

    it 'find_Articles', (done)->
      using importService, ->
        @find_Articles (articles)->
          articles.assert_Not_Empty()
          done()

    it 'find_Articles, find_Article_Parent_Queries, find_Query_Articles', (done)->
      using importService, ->
        @.find_Articles (articles)=>
          @find_Article_Parent_Queries articles.first(), (parent_Queries)=>
            @find_Query_Articles parent_Queries.first(), (query_Articles)=>
              query_Articles.assert_Contains(articles.first())
              done()

    it 'find_Queries, find_Query_Parent_Queries, find_Query_Queries', (done)->
      using importService, ->
        @.find_Queries (queries)=>
          @find_Query_Parent_Queries queries.first(), (parent_Queries)=>
            @find_Query_Queries parent_Queries.first(), (query_Queries)=>
              query_Queries.assert_Contains(queries.first())
              done()

    it 'find_Root_Queries', (done)->
      using importService, ->
        @.find_Root_Queries (root_Queries)=>
          #log root_Queries
          root_Queries.id      .assert_Is 'Root-Queries'
          root_Queries.title   .assert_Is 'Root Queries'
          root_Queries.queries .assert_Size_Is_Bigger_Than 4
          root_Queries.articles.assert_Size_Is 0             # for now, no queries are returned in this top level list
          done()

    it 'get_Queries_Mappings', (done)->
      using importService, ->
        @.get_Queries_Mappings (queries_Mappings)=>
          queries_Mappings.keys().assert_Size_Is_Bigger_Than(10)
          query_Id = queries_Mappings.keys().first()
          query    = queries_Mappings[query_Id];
          query.assert_Is_Object()
          done();

    it 'get_Query_Tree', (done)->
      @timeout 5000
      using importService, ->
        @.find_Root_Queries (root_Queries)=>
          query_Id = root_Queries.queries.first().id
          @.get_Query_Tree query_Id, (query_Tree)->
            query_Tree.results.assert_Size_Is_Bigger_Than 10
            query_Tree.id.assert_Is query_Id
            done()

    it 'get_Query_Tree_Filters', (done)->
      using importService, ->
        @find_Articles (articles)=>
          article_Ids = [articles.first(), articles.second()]
          @.get_Query_Tree_Filters article_Ids, (filters)->
            filters.assert_Size_Is 3
            using filters.first(),->
              @.title.assert_Is 'Technology'
              @.results.assert_Not_Empty()
              using @.results.first(), ->
                @.id.assert_Is_String()
                @.title.assert_Is_String()
                @.size .assert_Is_Number()

            done()

    it 'apply_Query_Tree_Query_Id_Filter', (done)->
      @timeout 5000
      using importService, ->
        @.find_Root_Queries (root_Queries)=>
          query_Id = root_Queries.queries.first().id
          @.get_Query_Tree query_Id, (query_Tree)=>
            filter = query_Tree.filters.first().results.first()
            @.apply_Query_Tree_Query_Id_Filter query_Tree, filter.id, (filtered_Query_Tree)->
              filtered_Query_Tree.results.size().assert_Is(filter.size)
              done();

    it 'get_Articles_Queries', (done)->
      using importService, ->
        @.get_Articles_Queries (articles_Queries)->
          articles_Queries.keys().assert_Not_Empty()
          done();

    it 'get_Query_Mappings', (done)->
      using importService, ->
        @.get_Queries_Mappings (mappings)=>
          mappings.keys().assert_Not_Empty()
          query_Id = mappings.keys().first()
          @.get_Query_Mappings query_Id, (query_Mappings)=>
            query_Mappings.assert_Is_Object()
            query_Mappings.assert_Is(mappings[query_Id])
            done();

    it 'map_Article_Parent_Queries', (done)->
      using importService, ->
        @find_Articles (articles)=>
          article_Id = articles.first()
          @get_Articles_Queries (articles_Queries,queries_Mappings)=>
            article_Parent_Queries = @.map_Article_Parent_Queries articles_Queries,queries_Mappings, null, article_Id
            using article_Parent_Queries, ->
              @.articles.keys().assert_Size_Is(1)
              @.articles[@.articles.keys().first()].parent_Queries.assert_Size_Is_Bigger_Than(9)
              @.queries.keys().assert_Size_Is_Bigger_Than(9)
              done();

    it 'map_Articles_Parent_Queries', (done)->
      using importService, ->
        @find_Articles (articles)=>
          article_Ids = [articles.first(), articles.second()]
          @.map_Articles_Parent_Queries article_Ids, (articles_Parent_Queries)->
            using articles_Parent_Queries, ->
              @.articles.keys().assert_Size_Is(2)
              @.articles[@.articles.keys().first()].parent_Queries.assert_Size_Is_Bigger_Than(9)
              @.queries.keys().assert_Size_Is_Bigger_Than(13)
              done()

    #it.only 'map_Query_Tree', (done)->
    #  using importService, ->
    #    @.find_Root_Queries (queries)=>
    #      @.map_Query_Tree queries.first(), (queryTree)=>
    #        log queryTree
    #        done()
