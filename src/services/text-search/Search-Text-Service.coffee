Cache_Service = null

loaded_Search_Mappings = null

class Search_Text_Service

  dependencies: ->
    Cache_Service   = require('teammentor').Cache_Service

  constructor: (options)->
    @.dependencies()
    @.options         = options || {}
    @.cache_Search    = new Cache_Service("search_cache")

  search_Mappings: (callback)=>
    if loaded_Search_Mappings
      return callback loaded_Search_Mappings

    key = 'search_mappings.json'
    if @.cache_Search.has_Key key
      data = @.cache_Search.get key
      loaded_Search_Mappings = data.json_Parse()
      return callback loaded_Search_Mappings

    callback {}

  word_Data: (word, callback)=>
    @.search_Mappings (mappings)->
      callback mappings[word]

  word_Score: (word, callback)=>
    results = []
    @.search_Mappings (mappings)->
      for article_Id, data of mappings[word]
        result = {id : article_Id, score: 0, why: ''}
        for tag in data.where
          score = 1
          switch tag
            when 'title'
              score = 10
            when 'h1'
              score = 5
            when 'h2'
              score = 4
            when 'em'
              score = 3
            when 'b'
              score = 3
            when 'a'
              score = -4

          result.score += score
          result.why +="#{tag}:#{score} , "
        results.push result

      results = (results.sort (a,b)-> a.score > b.score).reverse()

      callback results

  words_List: (callback)=>
    @.search_Mappings (mappings)->
      words_List = (word for word of mappings)
      callback words_List

  #tags_List: (callback)=>
  #  @.search_Mappings (mappings)->
  #    tags_List = for word,mapping of mappings
  #                  for article,data of mapping
  #                    for where in data.where
  #                      log where
  #                      #where
  #    callback tags_List


module.exports = Search_Text_Service