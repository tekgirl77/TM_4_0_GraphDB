get_Graph = (graphService, callback)->

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
                      #console.log(results)
                      callback(results)
                    else
                      articleId = articleIds.shift()
                      db.get {subject:articleId , predicate:'title'}, (err, data)->
                        result = { article_id: articleId, weight: weights[articleId], title: data.first().object}
                        db.get {subject:articleId , predicate:'guid'}, (err, data)->
                          result.guid = data.first().object
                          results.push result
                          #console.log(articleId + " : " + weights[articleId] +  " : " + data.first().object)
                          loadArticleIdData(articleIds)

                  loadArticleIdData(sorted_Articles)

module.export = get_Graph