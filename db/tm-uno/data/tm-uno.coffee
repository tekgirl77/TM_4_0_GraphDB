async             = require 'async'
cheerio           = require 'cheerio'
importService     = null
library           = null
library_Name      = 'Guidance'
metadata_Queries  = null
library_Name = if (global.request_Params) then global.request_Params.query['library'] else null

if not library_Name
  library_Name = 'Guidance'

take = -1
#console.log "[tm-uno] Library name is: #{library_Name} \n"

#library_Name      = 'Java'
#library_Name       = 'iOS'
#library_Name       = 'C++'
#library_Name       = "PCI DSS Compliance"
#library_Name       = "CWE"

setupDb = (callback)=>
  importService.graph.deleteDb =>
    importService.graph.openDb =>
      importService.teamMentor.library library_Name, (data) =>
        library = data
        callback()


create_Metadata_Global_Nodes = (next)=>
  metadata_Queries  = {}
  importUtil = importService.new_Data_Import_Util()

  add_Metadata_Global_Node = (target)=>
    target_Id = importService.new_Short_Guid('query')
    importUtil.add_Triplet target_Id, 'title', target
    importUtil.add_Triplet target_Id, 'is', 'Query'
    metadata_Queries[target] = target_Id

  add_Metadata_Global_Node(target) for target in ['Category', 'Phase', 'Technology', 'Type']

  importService.graph.db.put importUtil.data, ()=>
    next()

import_Article_Metadata = (article_Id, article_Data, next)->
  importUtil = importService.new_Data_Import_Util()

  add_Metadata_Target= (target)=>
    target_Value     = article_Data.Metadata[target]
    if (target_Value)
      target_Global_Id = metadata_Queries[target]
      target_Id        = metadata_Queries[target_Value]

      if not target_Id
        target_Id = metadata_Queries[target_Value] = importService.new_Short_Guid('query')
        importUtil.add_Triplet(target_Id       , 'is','Query')
        importUtil.add_Triplet(target_Global_Id, 'contains-query',target_Id)
      importUtil.add_Triplet(target_Id         , 'contains-article', article_Id)
      importUtil.add_Triplet(target_Id         , 'title', target_Value)

  add_Metadata_Target(target) for target in ['Category', 'Phase', 'Technology', 'Type']

  importService.graph.db.put importUtil.data, ()=>
    next()

_import_Article_Metadata = (article_Id, article_Data, next)->
  #console.log article_Id
  #console.log article_Data

  #category   = article_Data.Metadata.Category
  #phase      = article_Data.Metadata.Phase
  technology = article_Data.Metadata.Technology
  #type       = article_Data.Metadata.Type
  html       = article_Data.Content.Data_Json

  #category_Id   = if metadata_Queries[category]   then metadata_Queries[category]   else metadata_Queries[category]   = importService.new_Short_Guid('query')
  #phase_Id      = if metadata_Queries[phase]      then metadata_Queries[phase]      else metadata_Queries[phase]      = importService.new_Short_Guid('query')
  #technology_Id = if metadata_Queries[technology] then metadata_Queries[technology] else metadata_Queries[technology] = importService.new_Short_Guid('query')
  #type_Id       = if metadata_Queries[type]       then metadata_Queries[type]       else metadata_Queries[type]       = importService.new_Short_Guid('query')

  summary    = ""
  if (article_Data.Content.DataType.lower() is 'html')
    $          = cheerio.load(html.substring(0,400))
    summary    = $('p').text().substring(0,200).trim()
  else
    summary = html.substring(0,200).replace(/\*/g,'').replace(/\=/g,'')

  importUtil = importService.new_Data_Import_Util()

  #if (category)
  #  importUtil.add_Triplet article_Id   , 'category'  , category_Id
  #  importUtil.add_Triplet category_Id  , 'title'     , category
  #  importUtil.add_Triplet category_Id  , 'is'        , 'Query'

  #if (phase)
  #  importUtil.add_Triplet article_Id   , 'phase'     , phase_Id
  #  importUtil.add_Triplet phase_Id     , 'title'     , phase
  #  importUtil.add_Triplet phase_Id     , 'is'        , 'Query'

  #if (technology)
  #  importUtil.add_Triplet article_Id   , 'technology', technology_Id
  #  importUtil.add_Triplet technology_Id, 'title'     , technology
  #  importUtil.add_Triplet technology_Id, 'is'        , 'Query'

  #if (type)
  #  importUtil.add_Triplet article_Id   , 'type'  , type_Id
  #  importUtil.add_Triplet type_Id      , 'title'     , type
  #  importUtil.add_Triplet type_Id      , 'is'        , 'Query'

  importService.graph.db.put importUtil.data, ()=>
    next()



import_Article = (article, next)->
  importService.teamMentor.article article.guid, (article_Data)->
    title = article_Data.Metadata.Title
    importService.add_Db_using_Type_Guid_Title 'Article', article.guid, title, (article_Id)->
      importService.graph.add article.parent, 'contains-article', article_Id, ->
      #importService.add_Db_Query article.parent, article_Id, ->
        import_Article_Metadata article_Id, article_Data, next

import_Articles = (parent, article_Ids, next)->
  articlesToAdd = ({guid: article_Id, parent:parent} for article_Id in article_Ids).take(take)
  async.each articlesToAdd, import_Article, next

import_View = (view, next)->
  importService.add_Db_using_Type_Guid_Title 'Query', view.guid, view.title, (view_Id)->
    importService.graph.add view.parent, 'contains-query', view_Id, ->
    #importService.add_Db_Query view.parent, view_Id, ->
      import_Articles view_Id, view.articles, next

import_Views = (parent, views, next)->
  viewsToAdd = ({guid: view.viewId, title: view.caption, parent:parent,articles: view.guidanceItems} for view in views).take(take)
  async.each viewsToAdd, import_View, next

import_Folder = (folder, next)->
  importService.add_Db_using_Type_Guid_Title 'Query', folder.guid, folder.title, (folderId)->
    importService.graph.add folder.parent, 'contains-query', folderId, ->
    #importService.add_Db_Query folder.parent, folderId, ->
      import_Views folderId, folder.views , next

import_Folders = (parent, folders, next)->
  foldersToAdd = ({guid: folder.folderId, title: folder.name, parent:parent, views:folder.views} for folder in folders).take(take)
  async.each foldersToAdd, import_Folder,-> next()

addData = (params,callback)->
  #"[tm-uno] addData".log()
  importService = params.importService
  setupDb =>
    create_Metadata_Global_Nodes =>
      importService.add_Db_using_Type_Guid_Title 'Query', library.libraryId, library.name, (library_Id)=>
        import_Articles library_Id, library.guidanceItems, =>
          import_Folders library_Id, library.subFolders, ->
            import_Views library_Id, library.views, ->
              importService.graph.closeDb =>
                importService.graph.openDb =>
                  "[tm-uno] finished loading data".log()
                  callback()
          #callback()

module.exports = addData
