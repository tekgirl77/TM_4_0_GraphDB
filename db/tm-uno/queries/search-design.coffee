get_Graph = (options, callback)->

  importService = options.importService
  params        = options.params
  graph         = importService.new_Vis_Graph()
  db            = importService.graph.db

  loadData =  (queryValue, next)=>
    console.log(queryValue)

    #importService.graph.allData (data)->
      #console.log data.size()

    #db.nav(queryTitle).archIn('is').bind('Query')
    #                  .solutions (error, data)->
    searchTerms = [{ subject: db.v('article_Id') , predicate: db.v('bb'), object: queryValue}
                   { subject: db.v('article_Id'), predicate: 'is', object: 'Article'}]
    db.search searchTerms, (error, data)->
      console.log data.size()
      console.log data
      #graph.add_Node("asd")
      next()

  searchTerm = 'Design'
  #searchTerm = 'C++'

  loadData searchTerm, ->
    callback(graph)

module.exports = get_Graph