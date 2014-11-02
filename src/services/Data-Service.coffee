require('fluentnode')
coffeeScript     = require 'coffee-script'
Graph_Service    = require './Graph-Service'
Dot_Service      = require './Dot-Service'
Data_Import_Util = require './../utils/Data-Import-Util'

class Data_Service
  constructor: (name)->
    @name         = if (name) then name else 'test'
    @graphService = new Graph_Service(@name)
    @path_Root    = "db"
    @path_Name    = "db/#{@name}"
    @path_Data    = "#{@path_Name}/data"
    @path_Queries = "#{@path_Name}/queries"

  setup: ->
    @path_Root   .folder_Create()
    @path_Name   .folder_Create()
    @path_Data   .folder_Create()
    @path_Queries.folder_Create()
    @

  data_Files: =>
    @path_Data.files()

  query_Files: =>
    @path_Queries.files()

  load_Data_From_Coffee: (file,callback) =>
    add_Mappings = require('coffee-script').eval(file.file_Contents())
    #add_Mappings = require(file)
    if typeof add_Mappings is 'function'
      dataImport = new Data_Import_Util()
      add_Mappings dataImport, =>
        @graphService.db.put dataImport.data , callback
    else
      callback

  load_Data: (callback)=>
    @graphService.openDb =>
      files = @path_Data.files()
      loadNextFile = =>
        file = files.pop()
        if file is undefined
          callback()
        else
          switch file.file_Extension()
            when '.json'
              file_Data = JSON.parse(file.file_Contents())
              @graphService.db.put file_Data, loadNextFile
            when '.coffee'
              @load_Data_From_Coffee(file, loadNextFile)
            when '.dot'
              dot_Data = file.file_Contents()
              new Dot_Service().dot_To_Triplets dot_Data, (triplets)=>
                @graphService.db.put triplets, loadNextFile
            else
              console.log("not supported" + file.path_Extension())
              loadNextFile()
      loadNextFile()

  run_Query: (queryName, callback)=>
    queryFile = @path_Queries.path_Combine("#{queryName}.coffee")
    if(queryFile.file_Not_Exists())
      queryFile = process.cwd().path_Combine('db-queries').path_Combine("#{queryName}.coffee")
    if(queryFile.file_Exists())
      get_Graph = coffeeScript.eval(queryFile.fullPath().file_Contents())
      if typeof get_Graph is 'function'
        get_Graph @graphService, callback
        return
    callback({})

module.exports = Data_Service