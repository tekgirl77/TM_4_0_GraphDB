get_Graph = (graphService, callback)->

  graphService.allData (data)->
    nodes = []
    edges = []

    addNode =  (node)->
      nodes.push(node) if node not in nodes

    addEdge =  (from,to)->
      edges.push({from: from , to: to})

    for triplet in data
      addNode(triplet.subject)
      addNode(triplet.object)
      addEdge(triplet.subject, triplet.object)

    nodes = ({id: node} for node in nodes)

    graph = { nodes: nodes, edges: edges }

    callback(graph)

module.exports = get_Graph