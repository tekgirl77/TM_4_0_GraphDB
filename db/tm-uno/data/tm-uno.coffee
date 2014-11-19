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
    importUtil.add_Triplet target_Id, 'is', 'Metadata'
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

  add_Article_Summary = ()=>
    html       = article_Data.Content.Data_Json
    summary    = ""
    if (article_Data.Content.DataType.lower() is 'html')
      $          = cheerio.load(html.substring(0,400))
      summary    = $('p').text().substring(0,200).trim()
    else
      summary = html.substring(0,200).replace(/\*/g,'').replace(/\=/g,'')

    importUtil.add_Triplet(article_Id, 'summary', summary)

  add_Metadata_Target(target) for target in ['Category', 'Phase', 'Technology', 'Type']
  add_Article_Summary();

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

module.exports = addData
