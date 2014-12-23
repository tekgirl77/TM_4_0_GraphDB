levelgraph      = require('levelgraph'   )
GitHub_Service  = require('teammentor').GitHub_Service

class GraphService

  @open_Dbs: {}

  constructor: (dbName)->
    @dbName     = if  dbName then dbName else '_tmp_db'.add_Random_String(5)
    @dbPath     = "./.tmCache/#{@dbName}"#.create_Dir()
    @db         = null

  #Setup methods

  openDb : (callback)=>
    if GraphService.open_Dbs[@dbPath]
      #"[openDb]reusing".log()
      @db = GraphService.open_Dbs[@dbPath]
    else
      #"[openDb]creating".log()
      @db = levelgraph(@dbPath)
      GraphService.open_Dbs[@dbPath] = @db
    callback()

  closeDb: (callback)=>
    #"--- In CLOSE DB".log()
    if (@db)
      @db.close =>
        @db    = null
        @level = null
        delete GraphService.open_Dbs[@dbPath]
        callback()
    else
      callback()

  deleteDb: (callback)=>
    "[Graph-Service] Deleting The DB".log()
    @closeDb =>
      @dbPath.folder_Delete_Recursive()
      callback();

  add: (subject, predicate, object, callback)=>
    @db.put([{ subject:subject , predicate:predicate  , object:object }], callback)

  del: (subject, predicate, object, callback)=>
    @db.del { subject:subject , predicate:predicate  , object:object }, (err)->
      throw err if err
      callback()

  get_Subject: (subject, callback)->
    @db.get {subject:subject}, (err,data)->
      throw err if err
      callback(data)

  get_Predicate: (predicate, callback)->
    @db.get {predicate:predicate}, (err,data)->callback(data)

  get_Object: (object, callback)->
    @db.get {object:object}, (err,data)->callback(data)

  allData: (callback)=>
    @db.search [{
      subject  : @db.v("subject"),
      predicate: @db.v("predicate"),
      object   : @db.v("object"),
    }], (err, data)->callback(data)

  query: (key, value, callback)->
    switch key
      when "subject"      then @db.get { subject: value}  , (err, data) -> callback(data)
      when "predicate"    then @db.get { predicate: value}, (err, data) -> callback(data)
      when "object"       then @db.get { object: value}   , (err, data) -> callback(data)
      when "all"          then @allData callback
      else callback(null,[])

module.exports = GraphService