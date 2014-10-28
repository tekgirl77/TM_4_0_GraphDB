get_Graph = (graphService, callback)->

  graphService.allData (data)->
    nodes = []
    edges = []

    addNode =  (node)->
      nodes.push(node) if node not in nodes

    addEdge =  (from, to, label)->
      edges.push({from: from , to: to , label: label})

    for triplet in data
      addNode(triplet.subject)
      addNode(triplet.object)
      addEdge(triplet.subject, triplet.object, triplet.predicate)

    nodes = ({id: node} for node in nodes)

    graph = { nodes: nodes, edges: edges }

    callback(graph)

module.exports = get_Graph