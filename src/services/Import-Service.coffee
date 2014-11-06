Cache_Service      = require('./Cache-Service')
Db_Service         = require('./Db-Service')
#GitHub_Service     = require('./GitHub-Service')
Graph_Service      = require('./Graph-Service')
TeamMentor_Service = require('./TeamMentor-Service')
Guid               = require('../utils/Guid')
Data_Import_Util   = require('../utils/Data-Import-Util')
Vis_Graph          = require('../utils/Vis-Graph')

async              = require('async')

class ImportService

  constructor: (name)->
    @name = name || '_tmp_import'
    @cache      = new Cache_Service(@name)
    @db         = new Db_Service(@name)
    @graph      = @db.graphService
    @teamMentor = new TeamMentor_Service();
 
  setup: (callback)->
    @db.setup()
       .load_Data(callback)

  new_Short_Guid: (title, guid)->
    new Guid(title, guid).short

  new_Data_Import_Util: ->
    new Data_Import_Util()

  new_Vis_Graph: ->
    new Vis_Graph()



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
                             #callback if data.first() then data.first().id else null
                            callback (item.id for item in data)


  find_Subject_Contains: (subject, callback)=>
      @graph.db.nav(subject).archOut('contains')
               .solutions (err,data) ->
                  callback (item.x0 for item in data)

  get_Subject_Data: (subject, callback)=>
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
