require('fluentnode')

Graph_Service = require './Graph-Service'
Dot_Service   = require './Dot-Service'

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
              add_Data = require(file)
              if typeof add_Data is 'function'
                add_Data @graphService, loadNextFile
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
      get_Graph = require(queryFile.fullPath())
      if typeof get_Graph is 'function'
        get_Graph @graphService, callback
        return
    callback({})

module.exports = Data_Service