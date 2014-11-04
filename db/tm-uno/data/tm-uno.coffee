async             = require 'async'
Import_Service    = require '/src/services/Import-Service'.append_To_Process_Cwd_Path()
importService     = null
library           = null
library_Name      = 'UNO'

library_Name = global.request_Params.query['library']

if not library_Name
  library_Name = 'UNO'

console.log "[tm-uno] Library name is: #{library_Name}"

#library_Name      = 'Java'
#library_Name       = 'iOS'
#library_Name       = 'C++'
#library_Name       = "PCI DSS Compliance"
#library_Name       = "CWE"

setupDb = (callback)=>
  importService     = new Import_Service('tm-uno')
  importService.db.setup()
  importService.graph.deleteDb ->
    importService.graph.openDb ->
      importService.teamMentor.library library_Name, (data) ->
        library = data
        callback()

import_Article = (article, next)->
  importService.teamMentor.article article.guid, (articleData)->
    title = articleData.Metadata.Title
    importService.add_Db_using_Type_Guid_Title 'Article', article.guid, title, (article_Id)->
      importService.add_Db_Contains article.parent, article_Id, ->
        next()

import_Articles = (parent, article_Ids, next)->
  articlesToAdd = ({guid: article_Id, parent:parent} for article_Id in article_Ids)
  async.each articlesToAdd, import_Article, next

import_View = (view, next)->
  importService.add_Db_using_Type_Guid_Title 'View', view.guid, view.title, (view_Id)->
    importService.add_Db_Contains view.parent, view_Id, ->
      import_Articles view_Id, view.articles, next

import_Views = (parent, views, next)->
  viewsToAdd = ({guid: view.viewId, title: view.caption, parent:parent,articles: view.guidanceItems} for view in views)
  async.each viewsToAdd, import_View, next

import_Folder = (folder, next)->
  importService.add_Db_using_Type_Guid_Title 'Folder', folder.guid, folder.title, (folderId)->
    importService.add_Db_Contains folder.parent, folderId, ->
      import_Views folderId, folder.views , next

import_Folders = (parent, folders, next)->
  foldersToAdd = ({guid: folder.folderId, title: folder.name, parent:parent, views:folder.views} for folder in folders)
  async.each foldersToAdd, import_Folder,-> next()

addData = (dataImport,callback)->
  setupDb ->
      importService.add_Db_using_Type_Guid_Title 'Library', library.libraryId, library.name, (library_Id)->
        #importService.graph.closeDb ->
        import_Folders library_Id, library.subFolders, ->
          import_Views library_Id, library.views, ->
            callback()


module.exports = addData