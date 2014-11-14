get_Data = (params, callback)->
  graph = params.graph

  nodes = {}
  (nodes[node.id]={ node: node, edges:[]} for node in graph.nodes)
  (nodes[edge.from].edges.push(edge.to)   for edge in graph.edges)

  folder_Id = nodes.keys().starts_With('folder-').first()
  searchData = {}
  searchData.title        = 'no results'
  searchData.containers   = []
  searchData.resultsTitle = "Showing 0 results"
  searchData.results      = []
  searchData.filters      = []

  if (folder_Id and nodes[folder_Id])
    from_Node = nodes[folder_Id]
    searchData.title = from_Node.node.label.replace('folder: ','')
    for edge in from_Node.edges
      to_Node = nodes[edge]
      total = 0
      for to_edge in to_Node.edges
        #console.log '---- ' + to_edge + ' : ' + nodes[to_edge]
        total+= nodes[to_edge].edges.size()
      title =to_Node.node.label.replace('view: ','')
      container = { id: to_Node.node.id, title: title, size: total } # / 4 }
      searchData.containers.push(container)

    articles = {}
    (articles[node.guid]= node for node in graph.nodes when node.label == 'A').unique().size()


    for article_id in articles.keys()
      article = articles[article_id]
      result = { title: article.title, guid: article.guid , id: article.id, summary: article.summary, score : null }
      searchData.results.push(result)


    searchData.resultsTitle = "Showing #{searchData.results.size()} articles"

    add_Filter = (filter_Name)->
      filter_Name.log()
      filter = {}
      filter.title   = filter_Name
      filter.results = []
      mappings = {}
      for technology in nodes[filter_Name].edges
        mappings[technology] ?= 0
        mappings[technology]++
      for mapping in mappings.keys()
        result = { title : mapping ,id: '', size: mappings[mapping]}
        filter.results.push(result)
      searchData.filters.push(filter)

    add_Filter('Category')
    add_Filter('Phase')
    add_Filter('Technology')
    add_Filter('Type')
    console.log 'here'
  else
    'no folder- found!'.log()
  callback(searchData)
module.exports = get_Data