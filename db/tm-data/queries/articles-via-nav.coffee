get_Graph = (options, callback)->

  db = options.importService.graph.db

  db.nav("Article").archIn('is').as('articleId')
                   .archOut('title').as('title')
                   .solutions (err, results)->
                     mapData(results)


  mapData = (data)->
    nodes = []
    edges = []

    id =0;
    add_Node = (label)->
      nodes.push({ id: ++id, label:label})
      id

    add_Edge = (from, to, label)->
      edges.push({from:from,  to:to, label:label})

    add_Node("Articles")

    for item in data
      id_articleId = add_Node(item.articleId)
      id_title     = add_Node(item.title)
      add_Edge(1, id_articleId)
      add_Edge(id_articleId, id_title)

    graph = { nodes: nodes, edges:edges}
    callback graph


module.exports = get_Graph