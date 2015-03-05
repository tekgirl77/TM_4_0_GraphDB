Search_Text_Service = require './../../../src/services/text-search/Search-Text-Service'

describe.only '| services | text-search | Search-Text-Service.test', ->

  search_Text = null

  before (done)->
    search_Text = new Search_Text_Service()
    done()

  it 'search_Mappings', (done)->
    search_Text.search_Mappings (data)->
      data.words.assert_Is_Object()
      done()

  it 'words_List ', (done)->
    search_Text.words_List (words)->
      log words.size()
      done()