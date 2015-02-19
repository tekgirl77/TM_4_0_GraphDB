levelgraph      = require('levelgraph'   )
GitHub_Service  = require('teammentor').GitHub_Service

class GraphService

  #@open_Dbs: {}
  locked = false

  constructor: (dbName)->
    @dbName     = if  dbName then dbName else '_tmp_db'.add_Random_String(5)
    @dbPath     = "./.tmCache/#{@dbName}"#.create_Dir()
    @db         = null

  #Setup methods

  openDb : (callback)=>
    "[Opening Db]: #{locked}".log()
    if locked
      "Error: [GraphDB] is in use".log()
      callback false
    else
      locked = true
      process.nextTick =>
        @db = levelgraph(@dbPath)
        process.nextTick =>
          callback true

  closeDb: (callback)=>
    "[closing Db]: #{locked} : #{@db is null}".log()
    if (@db)
      @db.close =>
        @db    = null
        @level = null
        locked = false
        callback()
    else
      callback()

  deleteDb: (callback)=>
    @closeDb =>
      @dbPath.folder_Delete_Recursive()
      callback();

  add: (subject, predicate, object, callback)=>
    if @.db is null
      callback null
      return
    @db.put([{ subject:subject , predicate:predicate  , object:object }], callback)

  del: (subject, predicate, object, callback)=>
    if @.db is null
      callback null
      return
    @db.del { subject:subject , predicate:predicate  , object:object }, (err)->
      throw err if err
      callback()

  get_Subjects: (callback)=>
    if @.db is null
      callback null
      return
    @db.search [{ subject  : @db.v("subject")}], (err, data)->
      resuls = (item.subject for item in data) .unique()
      callback(resuls)

  get_Predicates: (callback)=>
    if @.db is null
      callback null
      return
    @db.search [{ predicate  : @db.v("predicate")}], (err, data)->
      resuls = (item.predicate for item in data) .unique()
      callback(resuls)

  get_Objects: (callback)=>
    if @.db is null
      callback null
      return
    @db.search [{ object  : @db.v("object")}], (err, data)->
      resuls = (item.object for item in data) .unique()
      callback(resuls)

  get_Subject: (subject, callback)->
    if @.db is null
      callback null
      return
    @db.get {subject:subject}, (err,data)->
      throw err if err
      callback(data)

  get_Predicate: (predicate, callback)->
    if @.db is null
      callback null
      return
    @db.get {predicate:predicate}, (err,data)->callback(data)

  get_Object: (object, callback)->
    if @.db is null
      callback null
      return
    @db.get {object:object}, (err,data)->callback(data)

  allData: (callback)=>
    if @.db is null
      callback null
      return
    @db.search [{
      subject  : @db.v("subject"),
      predicate: @db.v("predicate"),
      object   : @db.v("object"),
    }], (err, data)->callback(data)

  search: (subject, predicate, object, callback)=>
    if @.db is null
      callback null
      return
    @db.search [{
      subject  : subject    || @db.v("subject")
      predicate: predicate  || @db.v("predicate")
      object   : object     || @db.v("object")
    }], (err, data)->callback(data)

  query: (key, value, callback)->
    if @.db is null
      callback null
      return
    switch key
      when "subject"      then @db.get { subject: value}  , (err, data) -> callback(data)
      when "predicate"    then @db.get { predicate: value}, (err, data) -> callback(data)
      when "object"       then @db.get { object: value}   , (err, data) -> callback(data)
      when "all"          then @allData callback
      else callback(null)

module.exports = GraphService