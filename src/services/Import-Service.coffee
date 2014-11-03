Cache_Service      = require('./Cache-Service')
Db_Service         = require('./Db-Service')
#GitHub_Service     = require('./GitHub-Service')
Graph_Service      = require('./Graph-Service')
TeamMentor_Service = require('./TeamMentor-Service')
Guid               = require('../utils/Guid')
Data_Import_Util   = require('../utils/Data-Import-Util')

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

  add_To_Db: (id_Title, guid, data, callback)->
    library_Id = @new_Short_Guid(id_Title,guid)
    importUtil = @new_Data_Import_Util()
    importUtil.add_Triplets(library_Id, data)
    @graph.db.put importUtil.data, callback

  find_Subject: (subject, callback)=>
    @graph.db.get {subject: subject}, (error, data)=>
      result = {}
      result[subject] = {}
      for item in data
        result[subject][item.predicate] = item.object
      callback(result)

  get_Libraries_Ids: (callback)=>
    @graph.db.nav('Library').archIn('is').solutions (err,data) ->
      callback (item.x0 for item in data)

module.exports = ImportService
