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

  words_List: (callback)=>
    @.search_Mappings (mappings)->
      words_List = (word for word of mappings)
      callback words_List



module.exports = Search_Text_Service