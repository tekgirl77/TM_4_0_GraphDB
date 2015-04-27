Article    = require '../../src/graph/Article'


describe '| graph | Article', ->

  article = new Article();


  it 'constructor',->
    article.assert_Instance_Of Article
