Cache_Service    = require('./../../../src/services/Cache-Service')
Data_Service     = require('./../../../src/services/Db-Service')
Data_Import_Util = require('./../../../src/utils/Data-Import-Util')
Guid             =  require('./../../../src/utils/Guid')

return
describe 'db | tm-data | test-data-import |', ->

  dataService = new Db_Service('tm-uno-first')
  import_Folder = dataService.path_Name.path_Combine('_xml_import')                              .assert_That_Folder_Exists()
  data_File     = import_Folder        .path_Combine('be5273b1-d682-4361-99d9-6234f2d47eb7.json').assert_That_File_Exists()
  json          = data_File.file_Contents()                                                      .assert_Is_Json();

  it 'check json data', ->
    json.name .assert_Is_Equal_To('Uno')
    json.id   .assert_Is_Equal_To('be5273b1-d682-4361-99d9-6234f2d47eb7')
    json.repo .assert_Is_Equal_To('https://github.com/TMContent/Lib_UNO')
    json.site .assert_Is_Equal_To('https://tmdev01-sme.teammentor.net/')
    json.title.assert_Is_Equal_To('Index')
    json.data .assert_Is_Object()
              .guidanceItems.assert_Is_Array()
                            .assert_Size_Is(1726)

    json.data .subFolders.assert_Is_Array()
                         .assert_Size_Is(13)

    json.data .subFolders.first().assert_Is_Object()
                                 .name.assert_Is_Equal_To('Data Validation')
    json.data .subFolders.first()
                         .views.assert_Is_Array()
                               .assert_Size_Is(8)
  it 'Simulate data import', ->
    dataImport = new Data_Import_Util()
    dataImport.data.assert_Is_Array()

    #guid = dataImport.new_Guid()

    #console.log json.name
    #console.log(dataImport.guid__With_Title())

    #dataUtil.add_Triplets
    #dataUtil.addMappings "keyword_00000762fc3e",  [ { title     : "SQL Injection"                  },
    #  { is        : "Search"                           },
    #  { contains  : "queries-00002762fc3e"             },
    guid = new Guid('search', json.id)
    dataImport.add_Triplet(guid.short, 'guid', json.id)
    dataImport.add_Triplet(guid.short, 'is', 'Search')
    dataImport.add_Triplet(guid.short, 'title', json.name)
    #dataImport.add_Triplet('a','b','c')
    #console.log dataImport.data
    return

    dataImport.graph_From_Data (graph)->
      #console.log graph

  xit 'tm-uno-first', (done)->
    @timeout(5000)
    dataService = new Db_Service('tm-uno-first')
    dataService.load_Data ->
      dataService.graphService.allData (data)->
        console.log(data.length)
        dataService.graphService.deleteDb ->
          done()
    #dataService.run_Query 'tm-uno', (data)->
    #  console.log data
    #  #expect(data.size()).to.be.above(5)
    #  done()

  it 'tm-uno-first | tm-graph (query)', (done)->
    dataService = new Db_Service('tm-uno-first')
    dataService.load_Data ->
      #dataService.graphService.allData (data)->
      #  console.log(data.length)
      #  dataService.graphService.deleteDb ->
      #    done()
      dataService.run_Query 'tm-graph',{},  (data)->
        #console.log data.nodes.length
        #  #expect(data.size()).to.be.above(5)
        done()

  it 'test tm-sme (JSON data)', (done)->
    guidanceItem = 'a330bfdd-9576-40ea-997e-e7ed2762fc3e'
    url = 'https://tmdev01-sme.teammentor.net/jsonp/' + guidanceItem
    json_Cache = new Cache_Service('tmdev01')

    json_Cache.json_GET url, (data)->
      data.assert_Is_Object()
      data.Metadata.assert_Is_Object()
      data.Metadata.Title.assert_Is('All Input Is Validated')
      done()