Import_Service   = require('./../../src/services/Import-Service')

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

    it 'new_Short_Guid', ->
      importService.new_Short_Guid.assert_Is_Function()
      importService.new_Short_Guid('aaa').starts_With('aaa').assert_Is_True()
      importService.new_Short_Guid('bbb','b56ddd610d9e'    ).assert_Is('bbb-b56ddd610d9e')

    it 'new_Data_Import_Util', ->
      importService.new_Data_Import_Util.assert_Is_Function()
      importService.new_Data_Import_Util().assert_Is_Object()

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

    it 'add Library Node', (done)->
      importService.add_To_Db 'library', uno_Library.libraryId, {'guid' : uno_Library.libraryId, 'is' :'Library', 'title': uno_Library.name}, ->
        importService.get_Libraries_Ids (libraries_Ids) ->
          importService.find_Subject libraries_Ids.first(), (result)->
            console.log result
            graph.allData (data)->
              console.log data
              done()