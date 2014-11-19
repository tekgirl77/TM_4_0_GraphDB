get_Data = (params, callback)->
  graph = params.graph

  nodes = {}
  (nodes[node.id]={ node: node, edges:[]} for node in graph.nodes)
  (nodes[edge.from].edges.push(edge)   for edge in graph.edges)


  root_Node_Id     = graph.options['root-node'    ] #= nodes.keys().starts_With('folder-').first()
  articles_Node_Id = graph.options['articles-node']
  metadata_Node_Id = graph.options['metadata-node']
  queries_Node_Id  = graph.options['queries-node' ]


  searchData = {}
  searchData.title        = 'no results'
  searchData.containers   = []
  searchData.resultsTitle = "Showing 0 results"
  searchData.results      = []
  searchData.filters      = []

  if (root_Node_Id and articles_Node_Id and metadata_Node_Id and queries_Node_Id)

    searchData.title = nodes[root_Node_Id].node.label

    from_Node = nodes[queries_Node_Id]
    #console.log from_Node.edges

    for edge in from_Node.edges
      to_Node = nodes[edge.to].node
      container = { id: to_Node.id, title: to_Node.label, size: edge.label }
      searchData.containers.push(container)

  #   total = 0
  #   for to_edge in to_Node.edges
  #     if (nodes[to_edge].edges.size())
  #       total+= nodes[to_edge].edges.size()
  #     else
  #       total++
  #     #console.log nodes[to_edge].edges.size()
  #   title =to_Node.node.label.replace('view: ','')
  #   container = { id: to_Node.node.id, title: title, size: total } # / 4 }
  #   searchData.containers.push(container)

    #console.log nodes[articles_Node_Id]
    articles = {}
    (articles[edge.to]= nodes[edge.to] for edge in nodes[articles_Node_Id].edges)


    for article_id in articles.keys()
      article = articles[article_id].node
      result = { title: article.title, guid: article.guid , id: article.id, summary: article.summary, score : null }
      searchData.results.push(result)

    searchData.resultsTitle = "Showing #{searchData.results.size()} articles"

    add_Filter = (filter_Name)->
      filter_Id      = (key for key in nodes.keys() when nodes[key].node.label is filter_Name)
      filter         = {}
      filter.title   = filter_Name
      filter.results = []
      mappings = {}
      if (nodes[filter_Id])
        #console.log filter_Name + ' : ' + nodes[filter_Id].edges.size()
        for filter_Edge in nodes[filter_Id].edges
          to_Node = nodes[filter_Edge.to].node
          result = { title : to_Node.label ,id: to_Node.id, size: filter_Edge.label}
          filter.results.push(result)

      searchData.filters.push(filter)

    add_Filter('Category')
    add_Filter('Phase')
    add_Filter('Technology')
    add_Filter('Type')

  else
    'no folder- found!'.log()
  callback(searchData)
module.exports = get_Data