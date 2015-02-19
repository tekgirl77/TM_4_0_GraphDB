async = require 'async'

class Graph_Find
  constructor: (graph)->
    @.graph = graph

  convert_To_Ids: (values,callback)->
    if @graph.db is null
      callback null
      return

    result = {}

    resolve_Id = (value,next)=>
      @find_Using_Title value, (data)=>
        next data.first()

    resolve_Title = (query_Id,next)=>
      @.graph.search query_Id, 'title', undefined, (data)=>
        next data?.first()?.object

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

  find_Using_Is: (value, callback)=>
    if @graph.db is null
      callback null
      return
    @graph.db.nav(value).archIn('is')
                        .solutions (err,data) ->
                          callback (item.x0 for item in data)

  find_Using_Title: (value, callback)=>
    if @graph.db is null
      callback null
      return
    @graph.db.nav(value).archIn('title')
                        .solutions (err,data) ->
                          callback (item.x0 for item in data)

  find_Using_Is_and_Title: (is_value, title_value, callback)=>
    if @graph.db is null
      callback null
      return
    @graph.db.nav(is_value).archIn('is').as('id')
                           .archOut('title').as('title')
                           .bind(title_value)
                           .solutions (err,data) ->
                              callback (item.id for item in data)


  find_Subject_Contains: (subject, callback)=>            #Legacy: TO Remove
    if @graph.db is null
      callback null
      return
    @graph.db.nav(subject).archOut('contains')
             .solutions (err,data) ->
                callback (item.x0 for item in data)

  find_Articles: (callback)=>
    @graph.db.nav('Article').archIn('is').as('article')
                            .solutions (err,data) ->
                              callback (item.article for item in data)

  find_Queries: (callback)=>
    if @graph.db is null
      callback null
      return
    @graph.db.nav('Query').archIn('is').as('query')
                           .solutions (err,data) ->
                              callback (item.query for item in data)

  find_Query_Articles: (query_Id, callback)=>
    if @graph.db is null
      callback null
      return
    @graph.db.nav(query_Id).archOut('contains-article').as('article')
                           .solutions (err,data) ->
                              callback (item.article for item in data)

  find_Query_Queries: (query_Id, callback)=>
    if @graph.db is null
      callback null
      return
    @graph.db.nav(query_Id).archOut('contains-query').as('query')
                           .solutions (err,data) ->
                              callback (item.query for item in data)

  find_Article_Parent_Queries: (article_Id, callback)=>
    if @graph.db is null
      callback null
      return
    @graph.db.nav(article_Id).archIn('contains-article').as('query')
                             .solutions (err,data) ->
                                callback (item.query for item in data)

  find_Query_Parent_Queries: (query_Id, callback)=>
    if @graph.db is null
      callback null
      return
    @graph.db.nav(query_Id).archIn('contains-query').as('query')
                           .solutions (err,data) ->
                              callback (item.query for item in data)

  get_Subject_Data: (subject, callback)=>
    if @graph.db is null
      callback null
      return
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
        if not result['id']
          result['id'] = subject.valueOf()
        callback(result)

  get_Subjects_Data:(subjects, callback)=>
    if @graph.db is null
      callback null
      return
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

module.exports = Graph_Find