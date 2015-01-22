
get_Graph = (options, callback)->

  importService = options.importService
  graphService = importService.graph

  graphService.query "all", null, (data) =>
    DataSet   = require('vis/lib/DataSet')
    nodesAdded   = []
    nodesMapping = {}
    nodes        = []
    edges        = []

    setNodeStyle = (node)->
      node.mass = 7
      node.shape = 'box'
      node.color = {  highlight: {
                                    background: 'pink',
                                    border: 'red'
                                 } }

    setEdgeStyle = (edge)->
      fromNode = nodesMapping[edge.from]
      toNode = nodesMapping[edge.to]
      #if(edge.to.length < 30)
      #    fromNode.title += '\n - ' + edge.to
      switch(edge.label)
        when 'is'
          fromNode.fontSize  = 24
          switch (edge.to)
            when 'Library'
              fromNode.color.background =  "#030335"
              fromNode.fontColor =  "#FFFFFF"
              fromNode.fontSize  = 30
            when 'Search'
              fromNode.color.background =  "#c3c335"
              fromNode.fontSize  = 30

            when 'Articles','Queries', 'Metadatas'
              fromNode.color.background = "#92a792"
              fromNode.fontSize  = 30
            when 'Query'     then fromNode.color.background = "#e6b1b1"
            when 'Article'   then fromNode.color.background = "#97d997"
            when 'Metadata'  then fromNode.color.background = "#95bff7"
            when 'XRef'
              fromNode.color.background = '#000000'
              fromNode.shape           = 'dot'
              fromNode.radiusMax       = '10'
            else
              fromNode.color.background =  "#FFc335"

          toNode.color.background =  "#AAAAAA"
          toNode.visible     = false

        when 'title'
          toNode.fontFill  = "#DDDDFF"
        #  fromNode.label  = edge.to #+ ":\n\n" + fromNode.label
        #  toNode.visible = false

        #when 'guid','weight', 'summary'
        #  toNode.visible = false

      edge.style = 'arrow'
      edge.fontSize = 30
      edge.length  = 150
      #switch (edge.label)
      #  when 'target'
      #    xrefTarget = nodesMapping[toNode.id]
      #    fromNode.label = xrefTarget.label
      #    fromNode.title += '<br/>....ArticleId: ' + toNode.id
      #    fromNode.fontSize  = 20
      #    return false
      #  when 'weight'
      #    fromNode.value = toNode.label
      #    fromNode.title += '<br/>....Weight: ' + toNode.label
      #    return false
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
    callback(graphData)
    #mapNodes_by_Id_and_by_Is(graphData, callback)

module.exports = get_Graph