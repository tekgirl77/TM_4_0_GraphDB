Cache_Service    = require('/src/services/Cache-Service'.append_To_Process_Cwd_Path())
#Import_Service     = require('/src/services/Import-Service'.append_To_Process_Cwd_Path())
#Data_Import_Util = require('/src/utils/Data-Import-Util'.append_To_Process_Cwd_Path())
Guid             = require('/src/utils/Guid'.append_To_Process_Cwd_Path())
async            = require 'async'

addData = (options,callback)->
  dataImport = options.data

  #dataService = new Import_Service('tm-uno-first')
  dataService = options.importService
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

  queries_id = ''
  search_id = ''
  folder_Queries_id   = ''
  folder_Articles_id  = ''
  folder_Metadatas_id = ''


  mappedIds = {}

  add_Xref = (target, weight)->
    xref_id = new Guid('xref').short

    dataImport.add_Triplet(xref_id, 'is'     , 'XRef')
    dataImport.add_Triplet(xref_id, 'target' , target)
    dataImport.add_Triplet(xref_id, 'weight' , weight)
    return xref_id

  add_Metadata = (query, title)->
    key = "#{query}_#{title}"
    if not mappedIds[key]
      metadata_Id = new Guid('metadata').short
      dataImport.add_Triplet(metadata_Id, 'is'    , 'Metadata')
      dataImport.add_Triplet(metadata_Id, 'title' , title)
      mappedIds[key] = metadata_Id
    else
    return mappedIds[key]


  add_Query = (title)->
    key = "#{title}"
    if not mappedIds[key]
      query_Id = new Guid('query').short
      dataImport.add_Triplet(query_Id, 'is', 'Query')
      dataImport.add_Triplet(query_Id, 'title', title)
      dataImport.add_Triplet(folder_Metadatas_id, 'contains', query_Id)

      mappedIds[key] = query_Id
    return mappedIds[key]

  handle_Metadata = (article_id,metadata) ->
    technology_Id  = add_Query('Technology')
    xref_id       = add_Xref(article_id, '1')
    metadata_Id   = add_Metadata('Technology', metadata.Technology)
    dataImport.add_Triplet(technology_Id, 'contains', metadata_Id)

    #query_Id      = add_Query(metadata.Technology)
    #dataImport.add_Triplet(query_Id, 'contains', metadata_Id)
    dataImport.add_Triplet(metadata_Id, 'xref', xref_id)
    #dataImport.add_Triplet(article_id, 'technology' , metadata.Technology)

  handle_GuidanceItem = (guidanceItem,next) ->
    article_id = new Guid('article', guidanceItem).short
    dataImport.add_Triplet(article_id, 'guid' , guidanceItem)
    dataImport.add_Triplet(article_id, 'is'   , 'Article')

    dataImport.add_Triplet(folder_Articles_id, 'contains', article_id)

    dataImport.add_Triplet(queries_id, 'contains', add_Xref(article_id,'2'))


    url = 'https://tmdev01-sme.teammentor.net/jsonp/' + guidanceItem
    json_Cache = new Cache_Service('tmdev01')

    json_Cache.json_GET url, (data)->
      dataImport.add_Triplet(article_id, 'title', data.Metadata.Title)
      #console.log '   - ' +  data.Metadata.Title
      handle_Metadata(article_id, data.Metadata)
      next()

  handle_View = (view,next) ->
    queries_id = new Guid('queries', view.viewId).short
    dataImport.add_Triplet(queries_id, 'guid' , view.viewId)
    dataImport.add_Triplet(queries_id, 'is'   , 'Query')
    dataImport.add_Triplet(queries_id, 'title', view.caption)

    dataImport.add_Triplet(folder_Queries_id, 'contains', queries_id)
    guidanceItems = view.guidanceItems #.splice(0,1)
    async.each guidanceItems, handle_GuidanceItem, ->
      #console.log ' * View : ' + view.caption
      next()

  handle_Folder = (folder, next)->
    #console.log ' -> Folder : ' + folder.name
    search_id = new Guid('search', folder.folderId).short
    dataImport.add_Triplet(search_id, 'guid' , folder.folderId)
    dataImport.add_Triplet(search_id, 'is'   , 'Search')
    dataImport.add_Triplet(search_id, 'title', folder.name)

    dataImport.add_Triplet(library_id, 'contains', search_id)

    #folder_Queries_id
    folder_Queries_id = new Guid('queries').short
    dataImport.add_Triplet(folder_Queries_id, 'is', 'Queries')
    dataImport.add_Triplet(folder_Queries_id, 'title', 'Queries')
    dataImport.add_Triplet(search_id, 'contains', folder_Queries_id)

    #folder_Metadatas_id
    folder_Metadatas_id = new Guid('metadatas').short
    dataImport.add_Triplet(folder_Metadatas_id, 'is', 'Metadatas')
    dataImport.add_Triplet(folder_Metadatas_id, 'title', 'Metadatas')
    dataImport.add_Triplet(search_id, 'contains', folder_Metadatas_id)

    #folder_Metadatas_id
    folder_Articles_id = new Guid('articles').short
    dataImport.add_Triplet(folder_Articles_id, 'is', 'Articles')
    dataImport.add_Triplet(folder_Articles_id, 'title', 'Articles')
    dataImport.add_Triplet(search_id, 'contains', folder_Articles_id)

    #console.log folder
    views = folder.views #.splice(0,2)
    async.each  views, handle_View , ->
      #console.log ' -> Folder : ' + folder.name
      next()

  folders = uno_Json.data.subFolders #.splice(0,1)

  dataService.graph.deleteDb ->
    dataService.graph.openDb ->
      async.each folders , handle_Folder , (err)->
      callback()





module.exports = addData

