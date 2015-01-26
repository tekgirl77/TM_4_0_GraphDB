Import_Service = require('./../../src/services/Import-Service')
async          = require('async')

describe '| services | Import-Service.test', ->

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
      importService.path_Data   .assert_Is_String()
      importService.path_Queries.assert_Is_String()

      importService.name        .assert_Is 'Import-Service.test'
      importService.path_Root   .assert_Is('.tmCache')
      importService.path_Name   .assert_Is('.tmCache/Import-Service.test')
      importService.path_Data   .assert_Is('.tmCache/Import-Service.test/data')
      importService.path_Queries.assert_Is('.tmCache/Import-Service.test/queries')
      importService.path_Name.folder_Delete_Recursive().assert_Is_True()

    it 'check ctor (name)', (done)->
      aaaa_ImportService  = new Import_Service('aaaa')
      aaaa_ImportService.name         .assert_Is 'aaaa'
      aaaa_ImportService.path_Name    .assert_Is '.tmCache/aaaa'
      aaaa_ImportService.path_Data    .assert_Is '.tmCache/aaaa/data'
      aaaa_ImportService.path_Queries .assert_Is '.tmCache/aaaa/queries'
      aaaa_ImportService.graph.dbName .assert_Is 'aaaa'
      aaaa_ImportService.graph.deleteDb ->
        aaaa_ImportService.cache.cacheFolder().folder_Delete_Recursive()
        done()

    it 'setup', (done)->
      importService.setup.assert_Is_Function()
      (importService.graph.db is null).assert_Is_True()
      importService.setup ->
        #importService.graph.db.assert_Is_Object()
        importService.path_Data.assert_That_File_Exists()
        importService.path_Queries.assert_That_File_Exists()
        importService.graph.dbPath.assert_That_File_Exists()
        done()

    it 'data_Files',->
      #importService  = new Db_Service().setup()
      importService.data_Files    .assert_Is_Function()
      importService.data_Files() .assert_Is_Array()
      test_Data = "{ test: 'data'}"
      test_File = importService.path_Data.path_Combine("testData.json")
      test_Data.saveAs(test_File).assert_Is_True()
      importService.data_Files() .assert_Not_Empty()
      importService.data_Files() .assert_Contains(test_File.realPath())
      test_File.file_Delete()    .assert_Is_True()
      importService.data_Files() .assert_Not_Contains(test_File.realPath())

    it 'query_Files',->
      importService.query_Files  .assert_Is_Function()
      importService.query_Files().assert_Is_Array()
      test_Data = "{ test: 'query'}"
      test_File = importService.path_Queries.path_Combine("testQuery.json")
      test_Data.saveAs(test_File).assert_Is_True()
      importService.query_Files().assert_Not_Empty()
      importService.query_Files().assert_Contains(test_File.realPath())
      test_File.file_Delete()    .assert_Is_True()
      importService.query_Files().assert_Not_Contains(test_File.realPath())


    it 'run_Query', (done)->
      importService.run_Query.assert_Is_Function()

      query_Name = 'testQuery'
      coffee_Query = '''get_Graph = (params, callback)->
                          graph = { nodes: [{'a','b'}] , edges: [{from:'a' , to: 'b'}] }
                          callback(graph)
                        module.exports = get_Graph '''
      coffee_File = importService.path_Queries.path_Combine("#{query_Name}.coffee")
      coffee_Query.saveAs(coffee_File).assert_Is_True()

      importService.run_Query query_Name, {}, (graph)->
        graph.assert_Is_Object()

        graph.nodes.assert_Is_Array()
        graph.edges.assert_Is_Array()
        graph.nodes.first().assert_Is_Equal_To({'a','b'})
        graph.edges.first().assert_Is_Equal_To({from:'a' , to: 'b'})
        done()

    it 'run_Query (bad query)', (done)->
      importService.run_Query null, null, ->
        importService.run_Query 'aaaa', null, ->
          done()

    it 'run_Filter', (done)->
      importService.setup ->
        importService.run_Query.assert_Is_Function()

        filter_Name = 'testFilter'
        coffee_Query = '''get_Data = (params, callback)->
                            graph = params.graph
                            data = { number_of_nodes : graph.nodes.length , number_of_edges: graph.edges.length }
                            callback(data)
                          module.exports = get_Data '''
        coffee_File = importService.path_Filters.path_Combine("#{filter_Name}.coffee")
        coffee_Query.saveAs(coffee_File).assert_Is_True()
        graph = { nodes: [{'a','b'}] , edges: [{from:'a' , to: 'b'}] }
        importService.run_Filter filter_Name, graph, (data)->
          data.assert_Is_Object()
          data.number_of_nodes.assert_Is_Equal_To(graph.nodes.size())
          data.number_of_edges.assert_Is_Equal_To(graph.nodes.size())
          done()

    it 'run_Filter (bad data)', (done)->
      importService.run_Filter null,null,->
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

    it 'new_Vis_Graph', ->
      importService.new_Vis_Graph.assert_Is_Function()
                                 .ctor().nodes.assert_Is_Array()

    it 'load_Data_From_Coffee (bad data)',(done)->
      importService.load_Data_From_Coffee null , ->
        importService.load_Data_From_Coffee '', ->
          importService.load_Data_From_Coffee 'aaaaaaaa', ->
            importService.load_Data_From_Coffee {}.notHere , ->
              done()

    it 'load_Data_From_Coffee (no data returns)',(done)->
      tmp_File = '_tmp_Coffee.coffee'.append_To_Process_Cwd_Path()
      "add_Data = (options, callback)-> callback();
       module.exports = add_Data".saveAs(tmp_File);
      importService.load_Data_From_Coffee tmp_File, (data)->
        assert_Is_Undefined(data)
        tmp_File.file_Delete().assert_Is_True()
        done()

    it 'get_Subject_Data (bad data)', (done)->
      importService.get_Subject_Data null, ->
        done()

  describe '| load data |', ->
    importService = null
    path_Data     = null
    json_File_1   = null
    json_File_2   = null
    coffee_File_1 = null
    coffee_File_2 = null
    dot_File_1    = null
    dot_File_2    = null

    json_Data_1   = JSON.stringify [{ subject: 'a', predicate : 'b', object:'c'}, { subject: 'a', predicate : 'b', object:'f'}]
    json_Data_2   = JSON.stringify [{ subject: 'g', predicate : 'b', object:'c'}, { subject: 'g', predicate : 'd', object:'f'}]
    coffee_Data_1   = '''add_Data = (options,callback)->
                           options.data.addMappings('a1', [{'b1':'c1'},{ 'd1':'f1'}])
                           callback()
                         module.exports = add_Data '''
    coffee_Data_2   = '''add_Data = (options,callback)->
                           options.data.addMapping('g1','b1','c1')
                           callback()
                         module.exports = add_Data '''
    dot_Data_1      = '''graph graphname {
                                            a2 -- b2 -- c2;
                                            b2 -- d2;
                                          }'''
    dot_Data_2      = '''{ d2 -- e3 }'''

    before (done)->
      importService = new Import_Service('temp_load')
      importService.setup ->
        path_Data     = importService.path_Data
        json_File_1   = path_Data.path_Combine("testData_1.json"  )
        json_File_2   = path_Data.path_Combine("testData_2.json"  )
        coffee_File_1 = path_Data.path_Combine("testData_1.coffee")
        coffee_File_2 = path_Data.path_Combine("testData_2.coffee")
        dot_File_1    = path_Data.path_Combine("testData_1.dot"   )
        dot_File_2    = path_Data.path_Combine("testData_2.dot"   )
        done()

    beforeEach ->
      importService.path_Data.folder_Create()

    afterEach (done)->
      file.file_Delete() for file in  path_Data.files()
      path_Data.files().assert_Empty()
      importService.graph.deleteDb ->
        importService.cache.cacheFolder().folder_Delete_Recursive()
        done()

    after ->
      importService.path_Name.folder_Delete_Recursive().assert_Is_True()

    it 'load_Data (json)', (done)->
      json_Data_1.saveAs(json_File_1)
      json_Data_2.saveAs(json_File_2)
      path_Data.files().assert_Size_Is(2)
      importService.load_Data ->
        importService.graph.allData (data)->
          data.assert_Is_Array().assert_Size_Is(4)
          done()

    it 'load_Data (coffee)', (done)->
      coffee_Data_1.saveAs(coffee_File_1)
      coffee_Data_2.saveAs(coffee_File_2)
      path_Data.files().assert_Size_Is(2)
      importService.load_Data ->
        importService.graph.allData (data)->
          data.assert_Is_Array().assert_Size_Is(3)
          done()


    it 'load_Data (dot)', (done)->
      dot_Data_1.saveAs(dot_File_1)
      dot_Data_2.saveAs(dot_File_2)
      path_Data.files().assert_Size_Is(2)

      importService.load_Data ->
        importService.graph.allData (data)->
          data.assert_Is_Array().assert_Size_Is(4)
          done()

    it 'load_Data (all formats)', (done)->
      coffee_Data_1.saveAs(coffee_File_1)
      coffee_Data_2.saveAs(coffee_File_2)
      json_Data_1  .saveAs(json_File_1  )
      json_Data_2  .saveAs(json_File_2  )
      dot_Data_1   .saveAs(dot_File_1   )
      dot_Data_2   .saveAs(dot_File_2   )

      path_Data.files().assert_Size_Is(6)

      importService.load_Data ->
        importService.graph.allData (data)->
          data.assert_Is_Array().assert_Size_Is(11)
          #log data
          importService.get_Subject_Data "a", (data)->
            data.assert_Is({ b: [ 'c', 'f' ] })
            importService.get_Subject_Data "g", (data)->
              data.assert_Is({ b: 'c', d:'f'})

              importService.get_Subjects_Data null, (data)->
                data.assert_Is({})
                importService.get_Subjects_Data 'aaaa', (data)->
                  data.assert_Is({'aaaa':{}})
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
              @.articles.assert_Size_Is_Bigger_Than(50)
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
          root_Queries.articles.assert_Size_Is_Bigger_Than 100
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
      using importService, ->
        @.find_Root_Queries (root_Queries)=>
          query_Id = root_Queries.queries.first().id
          @.get_Query_Tree query_Id, (query_Tree)->
            query_Tree.id.assert_Is query_Id
            log query_Tree
            done()

    it 'get_Query_Tree_Filters', (done)->
      using importService, ->
        @find_Articles (articles)=>
          article_Ids = [articles.first(), articles.second()]
          @.get_Query_Tree_Filters article_Ids, (filters)->
            log filters
            done()

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
          @.map_Article_Parent_Queries null, article_Id, (article_Parent_Queries)->
            using article_Parent_Queries, ->
              @.articles.keys().assert_Size_Is(1)
              @.articles[@.articles.keys().first()].parent_Queries.assert_Size_Is_Bigger_Than(10)
              @.queries.keys().assert_Size_Is_Bigger_Than(10)
              done();

    it 'map_Articles_Parent_Queries', (done)->
      using importService, ->
        @find_Articles (articles)=>
          article_Ids = [articles.first(), articles.second()]
          @.map_Articles_Parent_Queries article_Ids, (articles_Parent_Queries)->
            using articles_Parent_Queries, ->
              @.articles.keys().assert_Size_Is(2)
              @.articles[@.articles.keys().first()].parent_Queries.assert_Size_Is_Bigger_Than(10)
              @.queries.keys().assert_Size_Is_Bigger_Than(13)
              done()

    #it.only 'map_Query_Tree', (done)->
    #  using importService, ->
    #    @.find_Root_Queries (queries)=>
    #      @.map_Query_Tree queries.first(), (queryTree)=>
    #        log queryTree
    #        done()
