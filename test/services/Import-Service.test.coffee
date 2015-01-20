Import_Service = require('./../../src/services/Import-Service')
async          = require('async')

describe '| services | Import-Service.test', ->

  describe 'core', ->
    importService = null

    before ->
      importService = new Import_Service('Import-Service.test')

    after (done)->
      #add importService cache removals
      importService.graph.deleteDb ->

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
   #   importService.name        .assert_Is importService.cache.area
   #   importService.name        .assert_Is importService.graph.dbName
      importService.path_Root   .assert_Is('db')
      importService.path_Name   .assert_Is('db/Import-Service.test')
      importService.path_Data   .assert_Is('db/Import-Service.test/data')
      importService.path_Queries.assert_Is('db/Import-Service.test/queries')
      importService.path_Name.folder_Delete_Recursive().assert_Is_True()

    it 'check ctor (name)', ->
      aaaa_ImportService  = new Import_Service('aaaa')
      aaaa_ImportService.name         .assert_Is 'aaaa'
      aaaa_ImportService.path_Name    .assert_Is 'db/aaaa'
      aaaa_ImportService.path_Data    .assert_Is 'db/aaaa/data'
      aaaa_ImportService.path_Queries .assert_Is 'db/aaaa/queries'
      aaaa_ImportService.graph.dbName .assert_Is 'aaaa'
      aaaa_ImportService.path_Name.folder_Delete_Recursive().assert_Is_True()

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

  describe '| load data', ->
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

    afterEach (done)->
      file.file_Delete() for file in  path_Data.files()
      path_Data.files().assert_Empty()
      importService.graph.deleteDb ->
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


  describe '| load Library data',->
    importService = null

    before (done)->
      using new Import_Service(), ->
        importService = @
        @.content.load_Data ->
          done()

    it 'library', (done)->
      importService.library (library)->
        library.assert_Is_Object()
        using library.guidanceExplorer.library.first()["$"],->
          @.name.assert_Is 'be5273b1-d682-4361-99d9-6204f2d47eb7'
          @.caption.assert_Is 'Vulnerabilities'
          done()


  return

  describe 'load Uno library',->
    importService = null
    db            = null
    cache         = null
    graph         = null
    teamMentor    = null
    uno_Library   = null;

    @timeout 10000

    before (done)->
      importService = new Import_Service('_temp_Uno')
      cache         = importService.cache
      graph         = importService.graph
      teamMentor    = importService.teamMentor

      importService.setup ->
        importService.teamMentor.library 'Guidance', (library) ->
          uno_Library = library.assert_Is_Object()
          done()

    after (done)->
      importService.path_Name.folder_Delete_Recursive()    .assert_Is_True()
      cache.delete_CacheFolder()                  .assert_Is_True()

      graph.deleteDb ->
        graph.dbPath              .assert_That_Folder_Not_Exists()
        importService.path_Data   .assert_That_Folder_Not_Exists()
        importService.path_Queries.assert_That_Folder_Not_Exists()
        cache.cacheFolder().assert_That_Folder_Not_Exists()
        done()

    it 'check that data is empty', (done)->
      graph.allData (result)->
        result.assert_Is_Array().assert_Is_Array()
        done()

    it 'add Library', (done)->
      importService.add_Db_using_Type_Guid_Title 'Library', uno_Library.libraryId, uno_Library.name, (new_Id)->
        importService.get_Libraries_Ids (libraries_Ids) ->
          libraries_Ids.assert_Size_Is(1)
          libraries_Ids.first().assert_Is(new_Id)
          importService.get_Subject_Data libraries_Ids.first(), (result)->
            result.assert_Is_Object()
            result.is.assert_Is('Library')
            result.title.assert_Is('Guidance')
            result.guid.assert_Is('be5273b1-d682-4361-99d9-6234f2d47eb7')
            done()

    it 'add Library folders', (done)->
      foldersToAdd = ({guid: folder.folderId, title: folder.name} for folder in uno_Library.subFolders)
      importService.get_Library_Id 'Guidance', (libraryId)->

        addFolder = (folder, next)->
          importService.add_Db_using_Type_Guid_Title 'Folder', folder.guid, folder.title, (folderId)->
            importService.add_Db_Contains libraryId, folderId, ->
              next()

        async.each foldersToAdd, addFolder,()->
          graph.allData (data)->
            #console.log data
            done()

    it 'get_Library_Folders_Ids and get_Subjects_Data', (done)->
      importService.get_Library_Folders_Ids 'Guidance', (folders_Ids)->
        folders_Ids.assert_Size_Is(13)
        importService.get_Subjects_Data folders_Ids, (folders_Data)->
          Object.keys(folders_Data).assert_Size_Is(13)
          folders_Data[folders_Ids.first()].assert_Is_Object()
          folders_Data[folders_Ids.first()].title.assert_Is('Authorization')
          done()

    it 'add folder views', (done)->
      folder = uno_Library.subFolders.first()
      importService.find_Using_Is_and_Title 'Folder', folder.name, (folder_Id)->
        view = folder.views.first()
        guid  = view.viewId
        title = view.caption
        importService.add_Db_using_Type_Guid_Title 'View', guid, title, (view_Id)->
          importService.add_Db_Contains folder_Id.first(), view_Id, ->
            importService.find_Using_Is 'View',  (data)->
              data.assert_Size_Is(1)
              importService.get_Subject_Data folder_Id.first(), (data)->
                data.contains.assert_Is(view_Id)
                done()

    it 'add view articles', (done)->
      folder  = uno_Library.subFolders.first()
      view    = folder.views.first()
      article = { articleId: view.guidanceItems.first()}
      using importService,->
        @add_Db_using_Type_Guid_Title 'Folder', folder.folderId, folder.name, (folder_Id)=>
          @add_Db_using_Type_Guid_Title 'View', view.viewId, view.caption, (view_Id)=>
            id = '8dfa8088-a6cb-4062-8a44-0df8f2bc1cc4'
            title = 'All Input Is Validated'
            @add_Db_using_Type_Guid_Title 'Article', id, title, (article_Id)=>
              article_Id.assert_Is('article-' + id.split('-').last())
              @find_Using_Is 'Article',  (data)=>
                data.assert_Size_Is(1)
                @get_Subject_Data article_Id, (data)=>
                  data.guid.assert_Is(id)
                  data.title.assert_Is(title)
                  done()
