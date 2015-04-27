Article    = require '../../src/graph/Article'


describe '| graph | Article', ->
  @.timeout 5000

  article = new Article();

  it 'constructor',->
    article.assert_Instance_Of Article

  it 'folder_Search_Data', ()->
    article.folder_Search_Data().assert_Folder_Exists()

  it 'html', (done)->
    article.raw_Articles_Html (raw_Articles_Html)->
      article_Id = raw_Articles_Html.keys().first()
      article.html article_Id, (html)->
        html.assert_Contains '<h2>'
        done()
  it 'html (bad guid)', (done)->
    article.html '1231231-13123-1231', (html)->
      assert_Is_Undefined html
      done()

  it 'raw_Articles_Html', (done)->
    article.raw_Articles_Html (raw_Articles_Html)->
      raw_Articles_Html.keys().assert_Not_Empty()
      done()