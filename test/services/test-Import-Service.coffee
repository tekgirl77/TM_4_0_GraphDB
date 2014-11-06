Import_Service = require('./../../src/services/Import-Service')
async          = require('async')

describe.only 'services | test-Import-Service |', ->
  describe 'core', ->
    importService = new Import_Service()

    after ->
      importService.graph.deleteDb ->
        importService.db.path_Name.folder_Delete_Recursive().assert_Is_True()

    it 'check ctor', ->
      Import_Service.assert_Is_Function()
      importService             .assert_Is_Object()
      importService.name        .assert_Is_String()
      importService.cache       .assert_Is_Object()#.assert_Instance_Of()
      importService.db          .assert_Is_Object()
      importService.graph       .assert_Is_Object()
      importService.teamMentor  .assert_Is_Object()

      importService.name        .assert_Is '_tmp_import'
      importService.name        .assert_Is importService.cache.area
      importService.name        .assert_Is importService.db.name
      importService.name        .assert_Is importService.db.graphService.dbName
      importService.name        .assert_Is importService.graph.dbName

    it 'setup', (done)->
      importService.setup.assert_Is_Function()
      (importService.graph.db is null).assert_Is_True()
      importService.setup ->
        importService.graph.db.assert_Is_Object()
        importService.graph.dbPath.assert_That_File_Exists()
        importService.db.path_Data.assert_That_File_Exists()
        importService.db.path_Queries.assert_That_File_Exists()
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

    it 'new_Short_Guid', ->
      importService.new_Short_Guid.assert_Is_Function()
      importService.new_Short_Guid('aaa').starts_With('aaa').assert_Is_True()
      importService.new_Short_Guid('bbb','b56ddd610d9e'    ).assert_Is('bbb-b56ddd610d9e')

    it 'new_Data_Import_Util', ->
      importService.new_Data_Import_Util.assert_Is_Function()
      importService.new_Data_Import_Util().assert_Is_Object()

    it 'new_Data_Import_Util', ->
      importService.new_Vis_Graph.assert_Is_Function()
                                 .ctor().nodes.assert_Is_Array()

  describe 'load Uno library',->
    importService = null
    db            = null
    cache         = null
    graph         = null
    teamMentor    = null
    uno_Library   = null;

    before (done)->
      importService = new Import_Service('_temp_Uno')
      db            = importService.db
      cache         = importService.cache
      graph         = importService.graph
      teamMentor    = importService.teamMentor

      importService.setup ->
        importService.teamMentor.library 'UNO', (library) ->
          uno_Library = library.assert_Is_Object()
          done()

    after (done)->
      db.path_Name.folder_Delete_Recursive()    .assert_Is_True()
      cache.delete_CacheFolder()                  .assert_Is_True()
      #teamMentor.cacheService.delete_CacheFolder().assert_Is_True()
      graph.deleteDb ->
        graph.dbPath       .assert_That_Folder_Not_Exists()
        db.path_Data       .assert_That_Folder_Not_Exists()
        db.path_Queries    .assert_That_Folder_Not_Exists()
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
            result.title.assert_Is('UNO')
            result.guid.assert_Is('be5273b1-d682-4361-99d9-6234f2d47eb7')
            done()

    it 'add Library folders', (done)->
      foldersToAdd = ({guid: folder.folderId, title: folder.name} for folder in uno_Library.subFolders)
      importService.get_Library_Id 'UNO', (libraryId)->

        addFolder = (folder, next)->
          importService.add_Db_using_Type_Guid_Title 'Folder', folder.guid, folder.title, (folderId)->
            importService.add_Db_Contains libraryId, folderId, ->
              next()

        async.each foldersToAdd, addFolder,()->
          graph.allData (data)->
            #console.log data
            done()

    it 'get_Library_Folders_Ids and get_Subjects_Data', (done)->
      importService.get_Library_Folders_Ids 'UNO', (folders_Ids)->
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
      importService.add_Db_using_Type_Guid_Title 'Folder', folder.folderId, folder.name, (folder_Id)->
        importService.add_Db_using_Type_Guid_Title 'View', view.viewId, view.caption, (view_Id)->
          teamMentor.article article.articleId, (article)->
            importService.add_Db_using_Type_Guid_Title 'Article', article.Metadata.Id, article.Metadata.Title, (article_Id)->
              importService.find_Using_Is 'Article',  (data)->
                data.assert_Size_Is(1)
                importService.get_Subject_Data article_Id, (data)->
                  data.guid.assert_Is('a330bfdd-9576-40ea-997e-e7ed2762fc3e')
                  data.title.assert_Is('All Input Is Validated')
                  done()

  #return
  # temporarily here
  describe 'load tm-uno data set', ->
    Db_Service    = require('./../../src/services/Db-Service')
    dbService     = null

    before (done)->
      dbService     = new Db_Service('tm-uno')
      dbService.graphService.openDb done

    it 'loadData',  (done)->
      dbService.load_Data ->
        dbService.graphService.allData (data)->
          data.assert_Is_Array()
          #console.log data.length
          done()

    #it 'test query',(done)->
    #  title = 'UNO'
    #  importService.get_Library_Id title, (library_Id)->
    #    #console.log library_Id
    #    #graph.db.nav('Library').archIn('is').archOut('title').solutions (err,data)->
    #    #  console.log data
    #    done()

    xit 'run query - library', (done)->
        dbService.run_Query 'library', (graph)->
          #console.log graph
          graph.nodes.assert_Is_Object()
          done()

    xit 'run query - folders-and-views', (done)->
      dbService.run_Query 'folders-and-views', (graph)->
        #console.log graph.json_pretty()
        graph.nodes.assert_Is_Object()
        done()

    it 'run query - article', (done)->
      dbService.run_Query 'article', (graph)->
        #console.log graph.json_pretty()
        graph.nodes.assert_Is_Object()
        done()