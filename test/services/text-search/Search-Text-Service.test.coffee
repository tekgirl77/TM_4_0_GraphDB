Search_Text_Service = require './../../../src/services/text-search/Search-Text-Service'

describe '| services | text-search | Search-Text-Service.test', ->

  search_Text = null

  before (done)->
    search_Text = new Search_Text_Service()
    done()

  it 'search_Mappings', (done)->
    search_Text.search_Mappings (data)->
      data.assert_Is_Object()
      done()

  it 'word_Data', (done)->
    search_Text.word_Data 'injection', (results)->
      results.assert_Not_Empty()
      log results.first()
      done()

  it 'words_List ', (done)->
    search_Text.words_List (words)->
      words.assert_Bigger_Than 100
      "there are #{words.size()} unique words".log()
      done()