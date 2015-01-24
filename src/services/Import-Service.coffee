require('fluentnode')
coffeeScript       = require 'coffee-script'
async              = require('async')

Cache_Service      = require('teammentor').Cache_Service
Dot_Service        = require './Dot-Service'
Graph_Service      = require('./Graph-Service')
#TeamMentor_Service = require('teammentor').TeamMentor_Service
Guid               = require('teammentor').Guid
Data_Import_Util   = require('../utils/Data-Import-Util')
Vis_Graph          = require('teammentor').Vis_Graph
Content_Service    = require('./Content-Service')

Local_Cache        = { Queries_Mappings : null , }

class ImportService

  constructor: (name)->
    @name          = name || '_tmp_import'
    @cache         = new Cache_Service("#{@name}_cache")
    @graph         = new Graph_Service("#{@name}")
    @content       = new Content_Service()
    #@teamMentor    = new TeamMentor_Service({tmConfig_File: '.tm-Config.json'});
    @path_Root     = "db"
    @path_Name     = "db/#{@name}"
    @path_Data     = "#{@path_Name}/data"
    @path_Filters  = "#{@path_Name}/filters"
    @path_Queries  = "#{@path_Name}/queries"

  setup: (callback)->
    @path_Root   .folder_Create()
    @path_Name   .folder_Create()
    @path_Data   .folder_Create()
    @path_Filters.folder_Create()
    @path_Queries.folder_Create()
    @graph.openDb ->
      callback()

    #@load_Data(callback)

  #Load DB data
  data_Files: =>
    @path_Data.files()

  query_Files: =>
    @path_Queries.files()

  load_Data_From_Coffee: (file,callback) =>
    if file != '' and file?
      code = file.file_Contents()
      if code != null
        add_Mappings = require('coffee-script').eval(code)
        if typeof add_Mappings is 'function'
          dataImport = new Data_Import_Util()
          options = {data: dataImport, importService: @}
          add_Mappings options, =>
            if dataImport.data.empty()
              callback()
            else
              @graph.db.put dataImport.data , callback
          return
    callback()

  load_Data: (callback)=>
    #"[Import-Service] load_data".log()
    @graph.openDb =>
      files = @path_Data.files()
      loadNextFile = =>
        file = files.pop()
        if file is undefined
          callback()
        else
          switch file.file_Extension()
            when '.json'
              file_Data = JSON.parse(file.file_Contents())
              @graph.db.put file_Data, loadNextFile
            when '.coffee'
              @load_Data_From_Coffee(file, loadNextFile)
            when '.dot'
              dot_Data = file.file_Contents()
              new Dot_Service().dot_To_Triplets dot_Data, (triplets)=>
                @graph.db.put triplets, loadNextFile
            else
              loadNextFile()
      loadNextFile()

  run_Query: (queryName, params, callback)=>
    queryFile = @path_Queries.path_Combine("#{queryName}.coffee")
    if(queryFile.file_Not_Exists())
      queryFile = process.cwd().path_Combine('db-queries').path_Combine("#{queryName}.coffee")
    if(queryFile.file_Not_Exists())
      queryFile = __dirname.path_Combine('../graph/tm-uno/queries').path_Combine("#{queryName}.coffee")
      #log queryFile

    if(queryFile?.fullPath()?.file_Exists())
      get_Graph = coffeeScript.eval(queryFile.fullPath().file_Contents())
      if typeof get_Graph is 'function'
        options = {importService:@ , params: params}
        get_Graph options, callback
        return
    callback({})

  run_Filter: (filterName, graph, callback)=>
    filterFile = @path_Filters.path_Combine("#{filterName}.coffee")
    if(filterFile.file_Not_Exists())
      filterFile = __dirname.path_Combine('../graph/tm-uno/filters').path_Combine("#{filterName}.coffee")

    if(filterFile.file_Exists())
      get_Data = coffeeScript.eval(filterFile.fullPath().file_Contents())
      if typeof get_Data is 'function'
        options = {importService:@ , graph: graph}
        get_Data options, callback
        return
    callback({})

  #new object Utils
  new_Short_Guid: (title, guid)->
    new Guid(title, guid).short

  new_Data_Import_Util: (data)->
    new Data_Import_Util(data)

  new_Vis_Graph: ->
    new Vis_Graph()


  #add data to GraphDB
  add_Db: (type, guid, data, callback)->
    id = @new_Short_Guid(type,guid)
    importUtil = @new_Data_Import_Util()
    importUtil.add_Triplets(id, data)
    @graph.db.put importUtil.data, -> callback(id)

  add_Db_Contains: (source, target, callback)->
    @graph.add(source, 'contains', target, callback)

  add_Db_using_Type_Guid_Title: (type, guid, title, callback)->
    @add_Db type.lower(), guid, {'guid' : guid, 'is' :type, 'title': title}, callback

  add_Is: (id, is_Value, callback)->
    @graph.add id,'is',is_Value, callback

  add_Title: (id, title_Value, callback)->
    @graph.add id,'title',title_Value, callback

  #SEARCH Data

  find_Using_Is: (value, callback)=>
    @graph.db.nav(value).archIn('is')
                        .solutions (err,data) ->
                          callback (item.x0 for item in data)

  find_Using_Title: (value, callback)=>
    @graph.db.nav(value).archIn('title')
                        .solutions (err,data) ->
                          callback (item.x0 for item in data)

  find_Using_Is_and_Title: (is_value, title_value, callback)=>
    @graph.db.nav(is_value).archIn('is').as('id')
                           .archOut('title').as('title')
                           .bind(title_value)
                           .solutions (err,data) ->
                              callback (item.id for item in data)


  #Legacy: TO Remove
  find_Subject_Contains: (subject, callback)=>
      @graph.db.nav(subject).archOut('contains')
               .solutions (err,data) ->
                  callback (item.x0 for item in data)

  find_Articles: (callback)=>
    @graph.db.nav('Article').archIn('is').as('article')
                            .solutions (err,data) ->
                              callback (item.article for item in data)

  find_Queries: (callback)=>
    @graph.db.nav('Query').archIn('is').as('query')
                           .solutions (err,data) ->
                              callback (item.query for item in data)

  find_Query_Articles: (query_Id, callback)=>
    @graph.db.nav(query_Id).archOut('contains-article').as('article')
                           .solutions (err,data) ->
                              callback (item.article for item in data)

  find_Query_Queries: (query_Id, callback)=>
    @graph.db.nav(query_Id).archOut('contains-query').as('query')
                           .solutions (err,data) ->
                              callback (item.query for item in data)

  find_Article_Parent_Queries: (article_Id, callback)=>
    @graph.db.nav(article_Id).archIn('contains-article').as('query')
                             .solutions (err,data) ->
                                callback (item.query for item in data)

  find_Query_Parent_Queries: (query_Id, callback)=>
    @graph.db.nav(query_Id).archIn('contains-query').as('query')
                           .solutions (err,data) ->
                              callback (item.query for item in data)

  find_Root_Queries: (callback)=>
    rootQueries = []

    check_Query = (queryId, next)=>
      @find_Query_Parent_Queries queryId, (parentQueries)->
        rootQueries.add(queryId) if parentQueries.empty()
        next()

    @.find_Queries (queries)->
      async.each queries, check_Query, ->
        callback rootQueries


  get_Queries_Mappings: (callback)=>
    ( callback(Local_Cache.Queries_Mappings);return) if (Local_Cache.Queries_Mappings)

    @find_Queries (query_Ids)=>
      @get_Subjects_Data query_Ids, (queries)=>

        map_Contains_Article = (article_Ids, target)->
            if article_Ids
              if typeof article_Ids is 'string'
                article_Ids = [article_Ids]
              for article_Id in article_Ids || []
                target.add(new String(article_Id))

        for query_Id in query_Ids
          query = queries[query_Id]
          query.queries ?= []
          query.articles ?= []

          child_Query_Ids = query['contains-query']
          if child_Query_Ids
            if typeof child_Query_Ids is 'string'
              child_Query_Ids = [child_Query_Ids]

          for child_Query_Id in child_Query_Ids || []
            child_Query = queries[child_Query_Id]
            child_Query.id = child_Query_Id
            query.queries.add(child_Query)
            child_Query.parents ?= []
            child_Query.parents.add(query_Id)
            map_Contains_Article child_Query['contains-article'],query.articles

          map_Contains_Article query['contains-article'],query.articles

        for query_Id in query_Ids
          query = queries[query_Id]
          delete query['contains-query']
          delete query['contains-article']

        Local_Cache.Queries_Mappings = queries
        callback(queries)

  get_Query_Mappings: (query_Id,callback)=>
    @get_Queries_Mappings (queries_Mappings)=>
      callback queries_Mappings[query_Id]

  get_Query_Tree: (query_Id,callback)=>
    @get_Query_Mappings query_Id, (query_Mappings)=>
      query_Tree =
        id          : query_Id
        title       : query_Mappings?.title
        resultsTitle: "Showing #{query_Mappings?.articles.size()} articles",
        containers  : []
        results     : []
        filters     : []
      if not query_Mappings
        callback query_Tree
      else
        for query in query_Mappings.queries
          container =
            id   : query.id
            title: query.title
            size : query.articles.size()
          query_Tree.containers.add container

        @get_Subjects_Data query_Mappings.articles, (data)=>
          for article_Id in query_Mappings.articles
            query_Tree.results.add data[article_Id]

          callback query_Tree

     #@get_Articles_Queries (articles_Queries)=>
     #  add_Mapping =  (title, next)=>
     #    @find_Using_Title (title), (data)=>
     #      query_Id = data.first()
     #      filter =
     #        title: title
     #        results: []
     #      #for article_Id in query_Mappings.articles
     #      #  article_Queries = articles_Queries[article_Id].queries
     #      #  for article_Query_Id in article_Queries.keys()
     #          #filter.results.add article_Queries[article_Query_Id]

     #        #for query in articles_Queries[article_Id].queries
     #        #  filter.results.add(query)
     #        #if query
     #        #  filter.results[query_Id] ?= { title: query.title , id:query_Id, size: 0}
     #        #  filter.results[query_Id].size++

     #      query_Tree.filters.add(filter)
     #      next()

     #  add_Mapping 'Category', =>
     #    add_Mapping 'Technology', =>
     #      add_Mapping 'Type', =>
     #        add_Mapping 'Phase', =>
     #          callback query_Tree


  get_Articles_Queries: (callback)=>
    @get_Queries_Mappings (queries_Mappings)=>
      articles_Queries = {}

      for query_Id in queries_Mappings.keys()
        query = queries_Mappings[query_Id]
        for article_Id in  query.articles
          articles_Queries[article_Id] ?= []
          query = queries_Mappings[query_Id]
          articles_Queries[article_Id].add(query_Id) #[query_Id] = { title: query.title , is: query.is }

      callback articles_Queries, queries_Mappings

  map_Article_Parent_Queries:  (article_Id, callback)=>
    @get_Articles_Queries (articles_Queries,queries_Mappings)=>
      parent_Queries = articles_Queries[article_Id]

      result = { id: article_Id , parent_Queries: {}}
      if parent_Queries
        for parent_Query_Id in parent_Queries
          query = queries_Mappings[parent_Query_Id]
          result[query.id] ?= { count:0 , title: query.title, parents: query.parents}
          result[query.id].count++
      callback(result)





  #######

  get_Subject_Data: (subject, callback)=>
    if not subject
      callback {}   #
    else
      @graph.db.get {subject: subject}, (error, data)=>
        result = {}
        throw error if error
        for item in data
          key = item.predicate
          value = item.object
          if (result[key])         # if there are more than one hit, return an array with them
            if typeof(result[key])=='string'
              result[key] = [result[key]]
            result[key].push(value)
          else
            result[key] = value
        callback(result)

  get_Subjects_Data:(subjects, callback)=>
    result = {}
    if not subjects
      callback result
      return
    if(typeof(subjects) == 'string')
      subjects = [subjects]

    map_Subject_data = (subject, next)=>
      @get_Subject_Data subject, (subjectData)=>
        result[subject] = subjectData
        next()

    async.each subjects, map_Subject_data, -> callback(result)


 #get_Libraries_Ids: (callback)=>
 #  @graph.db.nav('Library').archIn('is').solutions (err,data) ->
 #    callback (item.x0 for item in data)

 #get_Library_Id: (title, callback)=>
 #  @graph.db.nav('Library').archIn('is').as('id')
 #                          .archOut('title').as('title')
 #                          .bind(title)
 #                          .solutions (err,data) ->
 #                            callback if data.first() then data.first().id else null

 #get_Library_Folders_Ids: (title, callback)=>
 #  folders_Ids = []
 #  @get_Library_Id title, (library_id)=>
 #    @find_Subject_Contains library_id, callback

 #    #callback(folders_Ids)
 #    #@graph.db.nav('Folder').archIn('is').as('id')
 #    #                       .archOut('title').as('title')
 #    #                       .bind('Canonicalization')
 #    #                        #.archOut('contains')


  convert_To_Ids: (values,callback)->
    result = {}

    resolve_Id = (value,next)=>
      @find_Using_Title value, (data)=>
        next data.first()

    resolve_Title = (query_Id,next)=>
      @.graph.search query_Id, 'title', undefined, (data)=>
        next data.first()?.object

    map_Data = (target, id, title, next)=>
      using target, ->
        if id
          @.id    = id
          @.title = title
        next()

    convert_Value = (value,next)=>

      value  = value.trim()
      target = result[value] = {}
      resolve_Title value , (title)=>
        if title
          map_Data target, value, title, next
        else
          resolve_Id value, (id)=>
            resolve_Title id, (title)=>
              map_Data target, id, title, next

    if values
      async.each values.split(','), convert_Value, ->
        callback result




  #Library JSON Import (move to another file

  # assumes that there is only one Xml file which represents the library

  library_Json: (callback)=>
    @.content.library_Json_Folder (folder)->
      if  folder.files().empty()
        callback null
      else
        callback folder.files().first().load_Json()

  add_Json_Folder: (target_Folders, json_Folder)->
    all_Articles = []
    folder =
      id       : json_Folder['$'].folderId
      name     : json_Folder['$'].caption
      folders  : []
      views    : []

    for view in  json_Folder.view
      view_Articles = @add_Json_View folder.views, view
      all_Articles = all_Articles.concat(view_Articles)

    #log json_Folder
    #log folder
    target_Folders.push folder
    all_Articles

  add_Json_View: (target_Views, json_View)->
    view =
      id       : json_View['$'].id
      name     : json_View['$'].caption
      articles : json_View.items.first().item || []
    target_Views.push view
    view.articles


  parse_Library_Json: (json,callback)=>
    library =
      id      : null
      name    : null
      folders : []
      views   : []
      articles: []

    json_Library    = json.guidanceExplorer.library.first()
    library.id      = json_Library["$"].name
    library.name    = json_Library["$"].caption

    for item in json_Library.libraryStructure
      if (item.folder)
        for folder in item.folder
          library.articles = @add_Json_Folder library.folders,  folder
    callback(library)

  library: (callback)=>
    @library_Json (json)=>
      @parse_Library_Json json, callback

  article_Data: (articleId, callback)=>
    @.content.article_Data articleId, (article_Data)->
      callback article_Data

module.exports = ImportService
