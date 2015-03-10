Cache_Service            = null
Search_Artifacts_Service = null
async                    = null
loaded_Search_Mappings   = null

class Search_Text_Service

  dependencies: ->
    Cache_Service            = require('teammentor').Cache_Service
    Search_Artifacts_Service = require './Search-Artifacts-Service'
    async                    = require 'async'

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
    new Search_Artifacts_Service().create_Search_Mappings (search_Mappings)->
      callback search_Mappings

  word_Data: (word, callback)=>
    @.search_Mappings (mappings)->
      callback mappings[word]

  word_Score: (word, callback)=>
    word = word.lower()
    results = []
    @.search_Mappings (mappings)->
      for article_Id, data of mappings[word]
        result = {id : article_Id, score: 0, why: {}}
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
          result.why[tag]?=0
          result.why[tag]+=score
        results.push result

      results = (results.sort (a,b)-> a.score - b.score).reverse()

      callback results

  words_Score: (words, callback)=>
    words = words.lower()
    results = {}

    get_Score = (word,next)=>
      if word is ''
        return next()
      @word_Score word , (word_Results)->
        results[word] = word_Results
        next()

    async.eachSeries words.split(' '), get_Score , =>
      @.consolidate_Scores(results, callback)

  consolidate_Scores: (scores, callback)=>
    mapped_Scores = {}
    for word,results of scores
      for result in results
        mapped_Scores[result.id]?={}
        mapped_Scores[result.id][word]=result

    #log mapped_Scores

    results = []
    words_Size =  scores.keys().size()
    for id, id_Data of mapped_Scores
      if id_Data.keys().size() is words_Size
        result = {id: id, score:0 , why: {}}
        for word,word_Data of id_Data
          result.score +=  word_Data.score
          result.why[word] = word_Data.why
        results.push result

    #log results

    results = (results.sort (a,b)-> a.score - b.score).reverse()

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