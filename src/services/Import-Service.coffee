require('fluentnode')
coffeeScript       = require 'coffee-script'
async              = require('async')

Cache_Service      = require('./Cache-Service')
#Db_Service         = require('./Db-Service')
Dot_Service        = require './Dot-Service'
#GitHub_Service     = require('./GitHub-Service')
Graph_Service      = require('./Graph-Service')
TeamMentor_Service = require('./TeamMentor-Service')
Guid               = require('../utils/Guid')
Data_Import_Util   = require('../utils/Data-Import-Util')
Vis_Graph          = require('../utils/Vis-Graph')


class ImportService

  constructor: (name)->
    #@name = name || '_tmp_import'
    @name          = if (name) then name else 'test'
    @cache      = new Cache_Service(@name)
    @graph      = new Graph_Service(@name)
    @teamMentor = new TeamMentor_Service();
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
    @graph.openDb()
    callback()

    #@load_Data(callback)

  #Load DB data
  data_Files: =>
    @path_Data.files()

  query_Files: =>
    @path_Queries.files()

  load_Data_From_Coffee: (file,callback) =>
    #jsFile = file.replace('/db/','/.dist/db/').replace('.coffee','.js')
    #if (jsFile and jsFile.file_Exists())
    #  "executing js version of file: #{jsFile}".log()
    #  add_Mappings = eval(jsFile.file_Contents().replace('}).call(this);', 'return addData;}).call(this);'))
    #else
    #  "executing coffee version of file: #{file}".log()
    #  add_Mappings = require('coffee-script').eval(file.file_Contents())
    add_Mappings = require('coffee-script').eval(file.file_Contents())
    if typeof add_Mappings is 'function'
      dataImport = new Data_Import_Util()
      options = {data: dataImport, importService: @}
      add_Mappings options, =>
        @graph.db.put dataImport.data , callback
    else
      callback()

  load_Data: (callback)=>
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
              console.log("not supported" + file.path_Extension())
              loadNextFile()
      loadNextFile()

  run_Query: (queryName, params, callback)=>
    queryFile = @path_Queries.path_Combine("#{queryName}.coffee")
    if(queryFile.file_Not_Exists())
      queryFile = process.cwd().path_Combine('db-queries').path_Combine("#{queryName}.coffee")
    if(queryFile.file_Exists())
      get_Graph = coffeeScript.eval(queryFile.fullPath().file_Contents())
      if typeof get_Graph is 'function'
        options = {importService:@ , params: params}
        get_Graph options, callback
        return
    callback({})

  run_Filter: (filterName, graph, callback)=>
    filterFile = @path_Filters.path_Combine("#{filterName}.coffee")
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

  find_Using_Is: (value, callback)=>
    @graph.db.nav(value).archIn('is')
                        .solutions (err,data) ->
                          callback (item.x0 for item in data)

  find_Using_Is_and_Title: (is_value, title_value, callback)=>
    @graph.db.nav(is_value).archIn('is').as('id')
                           .archOut('title').as('title')
                           .bind(title_value)
                           .solutions (err,data) ->
                              callback (item.id for item in data)


  find_Subject_Contains: (subject, callback)=>
      @graph.db.nav(subject).archOut('contains')
               .solutions (err,data) ->
                  callback (item.x0 for item in data)

  get_Subject_Data: (subject, callback)=>
    #console.log subject
    if not subject
      callback {}
    else
      @graph.db.get {subject: subject}, (error, data)=>
        result = {}
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


  get_Libraries_Ids: (callback)=>
    @graph.db.nav('Library').archIn('is').solutions (err,data) ->
      callback (item.x0 for item in data)

  get_Library_Id: (title, callback)=>
    @graph.db.nav('Library').archIn('is').as('id')
                            .archOut('title').as('title')
                            .bind(title)
                            .solutions (err,data) ->
                              callback if data.first() then data.first().id else null

  get_Library_Folders_Ids: (title, callback)=>
    folders_Ids = []
    @get_Library_Id title, (library_id)=>
      @find_Subject_Contains library_id, callback

      #callback(folders_Ids)
      #@graph.db.nav('Folder').archIn('is').as('id')
      #                       .archOut('title').as('title')
      #                       .bind('Canonicalization')
      #                        #.archOut('contains')

module.exports = ImportService