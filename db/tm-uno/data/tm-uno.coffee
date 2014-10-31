Data_Service     = require('/src/services/Data-Service'.append_To_Process_Cwd_Path())
#Data_Import_Util = require('/src/utils/Data-Import-Util'.append_To_Process_Cwd_Path())
Guid             = require('/src/utils/Guid'.append_To_Process_Cwd_Path())

addData = (dataImport)->

  dataService = new Data_Service('tm-uno')
  import_Folder = dataService.path_Name.path_Combine('_xml_import')                              .assert_That_Folder_Exists()
  data_File     = import_Folder        .path_Combine('be5273b1-d682-4361-99d9-6234f2d47eb7.json').assert_That_File_Exists()
  uno_Json      = data_File.file_Contents()                                                      .assert_Is_Json()
#  #console.log json
#
#  dataImport = new Data_Import_Util()
#
  guid = new Guid('library', uno_Json.id)
  library_id = guid.short
  dataImport.add_Triplet(library_id, 'guid' , uno_Json.id)
  dataImport.add_Triplet(library_id, 'is'   , 'Library')
  dataImport.add_Triplet(library_id, 'title', uno_Json.name)

  for folder in uno_Json.data.subFolders
    search_id = new Guid('search', folder.folderId).short
    dataImport.add_Triplet(search_id, 'guid' , folder.folderId)
    dataImport.add_Triplet(search_id, 'is'   , 'Search')
    dataImport.add_Triplet(search_id, 'title', folder.name)

    dataImport.add_Triplet(library_id, 'contains', search_id)

    #console.log folder
    for view in folder.views
      queries_id = new Guid('queries', view.viewId).short
      dataImport.add_Triplet(queries_id, 'guid' , view.viewId)
      dataImport.add_Triplet(queries_id, 'is'   , 'Queries')
      dataImport.add_Triplet(queries_id, 'title', view.caption)

      dataImport.add_Triplet(search_id, 'contains', queries_id)

      #articles_query_id = new Guid('articles').short

      #dataImport.add_Triplet(articles_query_id, 'is'   , 'Articles')
      #dataImport.add_Triplet(articles_query_id, 'title', 'Articles')

      #dataImport.add_Triplet(queries_id, 'contains', articles_query_id)

      for guidanceItem in view.guidanceItems
        article_id = new Guid('articles', guidanceItem).short
        dataImport.add_Triplet(article_id, 'guid' , guidanceItem)
        dataImport.add_Triplet(article_id, 'is'   , 'Article')
        dataImport.add_Triplet(article_id, 'title', guidanceItem)

        dataImport.add_Triplet(queries_id, 'contains', article_id)

      #console.log view
      #break
    #break

#
#  console.log dataImport.data
#
#  dataImport.graph_From_Data callback
#  console.log Object.keys(json).size()

module.exports = addData

