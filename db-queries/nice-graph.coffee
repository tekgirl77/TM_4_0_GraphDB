mapNodes_by_Id_and_by_Is = (graphData, callback) ->
  nodes_by_Id = {}
  nodes_by_Is = {}
  for node in graphData.nodes
    nodes_by_Id[node.id]= { text: node.label, edges: {}}

  for edge in graphData.edges
    edges = nodes_by_Id[edge.from].edges
    edges[edge.label] = [] if edges[edge.label] is undefined
    edges[edge.label].push(edge.to)

    if (edge.label =='is')
      nodes_by_Is[edge.to] = [] if nodes_by_Is[edge.to] is undefined
      nodes_by_Is[edge.to].push(edge.from)

  graphData.nodes_by_Id = nodes_by_Id
  graphData.nodes_by_Is = nodes_by_Is
  callback(graphData)

get_Graph = (graphService, callback)->
  graphService.query "all", null, (data) =>
    DataSet   = require('vis/lib/DataSet')
    nodesAdded   = []
    nodesMapping = {}
    nodes        = []
    edges        = []

    setNodeStyle = (node)->
      node.mass = 7
      node.shape = 'box'
      node.color = {}


    setEdgeStyle = (edge)->
      fromNode = nodesMapping[edge.from]
      toNode = nodesMapping[edge.to]
      #if(edge.to.length < 30)
      #    fromNode.title += '\n - ' + edge.to
      switch(edge.label)
        when 'is'
          fromNode.fontSize  = 24
          switch (edge.to)
            when 'Search'
              fromNode.color.background =  "#c3c335"
              fromNode.fontSize  = 50

            when 'Articles','Queries', 'Metadatas'
              fromNode.color.background = "#92a792"
              fromNode.fontSize  = 50
          #fromNode.mass = 10
            when 'Query'     then fromNode.color.background = "#e6b1b1"
            when 'Article'   then fromNode.color.background = "#97d997"
            when 'Metadata'  then fromNode.color.background = "#95bff7"
            when 'XRef'
              fromNode.color.background = '#000000'
              fromNode.shape           = 'dot'
              fromNode.radiusMax       = '10'
          #fromNode.fontColor        = '#ffffff'
            else
              fromNode.color.background =  "#FFc335"

          toNode.visible     = false

        when 'title'
          fromNode.label  = edge.to #+ ":\n\n" + fromNode.label
          toNode.visible = false

        when 'guid','weight', 'summary'
          toNode.visible = false

      edge.style = 'arrow'
      edge.fontSize = 10
      edge.length  = 150
      switch (edge.label)
        when 'target'
          xrefTarget = nodesMapping[toNode.id]
          fromNode.label = xrefTarget.label
          fromNode.title += '<br/>....ArticleId: ' + toNode.id
          fromNode.fontSize  = 20
          return false
        when 'weight'
          fromNode.value = toNode.label
          fromNode.title += '<br/>....Weight: ' + toNode.label
          return false
      return true


    addNode = (nodeId)->
      #if (not nodeId or nodeId.length >30 or nodeId.length < 4)
      #    return
      if nodeId not in nodesAdded
        nodesAdded.push(nodeId)
        node = {
          id       : nodeId
          label    : nodeId
          title    : nodeId
          visible  : true
        }
        setNodeStyle(node)
        nodes.push(node)
        nodesMapping[nodeId] = node

    addEdge = (item)->
      edge = {
                from      : item.subject
                to        : item.object
                label     : item.predicate
              }

      if setEdgeStyle(edge)
        edges.push(edge)

    for item in data #.splice(0,40)
      addNode(item.subject)
      addNode(item.object)
      addEdge(item)

    nodes = (node for node in nodes when node.visible)

    graphData = { nodes: nodes, edges: edges }
    graphData.refresh = false
    mapNodes_by_Id_and_by_Is(graphData, callback)

module.exports = get_Graph