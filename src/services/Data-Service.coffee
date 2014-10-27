require('fluentnode')

Graph_Service = require './Graph-Service'
Dot_Service   = require './Dot-Service'

class Data_Service
  constructor: (name)->
    @name         = if (name) then name else 'test'
    @graphService = new Graph_Service(@name)
    @path_Root    = "db"                   .folder_Create().realPath()
    @path_Name    = "db/#{@name}"          .folder_Create().realPath()
    @path_Data    = "#{@path_Name}/data"   .folder_Create().realPath()
    @path_Queries = "#{@path_Name}/queries".folder_Create().realPath()

  data_Files: =>
    @path_Data.files()

  query_Files: =>
    @path_Data.files()

  load_Data: (callback)=>
    @graphService.openDb =>
      files = @path_Data.files()
      loadNextFile = =>
        file = files.pop()
        if file is undefined
          callback()
        else
          switch file.path_Extension()
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

module.exports = Data_Service