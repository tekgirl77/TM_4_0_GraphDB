expect          = require('chai'     ).expect

Data_Service = require('./../../../src/services/Data-Service')

describe 'db | tm-data | test-Queries |', ->

  dataService = new Data_Service('tm-data')
  graphService = dataService.graphService
  before (done)->
    expect(dataService ).to.be.an('object')
    expect(graphService).to.be.an('object')

    dataService.load_Data ->
      graphService.allData (data)->
        expect(data.length).to.be.above(50)
        done()

  after (done)->
    graphService.deleteDb done

  it.only 'misc test query',(done)->
    ###
    graphService.db.nav("XRef").archIn('is').as('xref')
                               .archOut('weight').as('weight')
                                  .solutions (err, results)->
                                    console.log results
                                    done()
    ###
    #graphService.get_Subject 'article-e7ed2762fc3e', (data)->
    #  console.log data

    #return
    #graphService.db.nav("article-e7ed2762fc3e").archOut('title'    )

    db = graphService.db
   #db.search [
   #            { subject: db.v('article-id')  , predicate: 'is'    , object: 'Article'}
   #            { subject: db.v('xref')        , predicate: 'target', object:db.v('article-id')}
   #            #{  predicate: 'weight', object: db.v('weight')}
   #          ]#,{ materialized: {
   #           #                   article_id      : db.v("article-id"),
   #           #                   xref            : db.v('xref')
   #           #                   weight          : db.v("weight")
   #           #                   #title     : db.v("title")
   #           #}}
   #            , (err, data)->
   #                console.log(data.size())
   #                done()

    db = graphService.db
    db.search [
                { subject: db.v('xref')      , predicate: 'weight', object: db.v('weight')}
                { subject: db.v('xref')      , predicate: 'target', object: db.v('article-id')}
              ],{ materialized: {
                                  xref      : db.v("xref"),
                                  article_id: db.v('article-id')
                                  weight    : db.v("weight")
                }}, (err, data)->
                    # calculate the articles weights
                    weights = {}
                    for item in data
                      weights[item.article_id] ?= 0
                      weights[item.article_id] += +item.weight

                    # sort articles_Weights
                    sorted_Articles = do (weights) ->
                                        Object.keys(weights).sort (a, b) -> weights[b] - weights[a]

                    results = []
                    loadArticleIdData = (articleIds)->
                      if(articleIds.empty())
                        console.log(results)
                        done()
                      else
                        articleId = articleIds.shift()
                        db.get {subject:articleId , predicate:'title'}, (err, data)->
                          results.push { article_id: articleId, weight: weights[articleId], title: data.first().object}
                          console.log(articleId + " : " + weights[articleId] +  " : " + data.first().object)
                          loadArticleIdData(articleIds)

                    loadArticleIdData(sorted_Articles)


  it.only 'query - articles', (done)->
    dataService.run_Query 'articles', (data)->
      #console.log data
      expect(data.nodes.size()).to.be.above(10)
      done()
  it.only 'query - articles-by-weight', (done)->
    dataService.run_Query 'articles-by-weight', (data)->
      console.log data
      expect(data.size()).to.be.above(5)
      done()