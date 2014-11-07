async             = require 'async'
Import_Service    = require '/src/services/Import-Service'.append_To_Process_Cwd_Path()

get_Graph = (graphService, params, callback)->
  importService     = new Import_Service('tm-uno')
  importService.db.setup()
  importService.graph = graphService;

  nodes     = []
  edges     = []
  fromNodes = []

  addNode =  (node)->
    nodes.push(node) if node not in nodes

  addEdge =  (from, to, label)->
    addNode(from)
    addNode(to)
    edge = {from: from , to: to , label: label}
    switch label
      when 'folder'
        edge.length  = 700
        edge.color = 'orange'
      when 'view'
        edge.length  = 250
        edge.color = 'green'

      when 'article'
        edge.color = 'black'
      else
        edge.length  = 500
    edges.push(edge)

    fromNodes.push(from) if from not in fromNodes

  sendData = ->

    nodes = ({id: node, label:'', title: node , shape: 'dot'} for node in nodes)

    for node in nodes
      if (node.id in fromNodes)
        node.label = node.id
        node.shape = 'box'
        node.fontSize = 10
        node.color = {border: 'black'}

    options =
              edges:      { }
           #   clustering: true
           #  clustering: {
           #                initialMaxNodes: 40,
           #                clusterThreshold:500,
           #                reduceToNodes:300,
           #                chainThreshold: 0.4,
           #                clusterEdgeThreshold: 2,
           #                sectorThreshold: 100,
           #                screenSizeThreshold: 0.2,
           #                fontSizeMultiplier:  4.0,
           #                maxFontSize: 1000,
           #                forceAmplification:  0.1,
           #                distanceAmplification: 0.1,
           #                edgeGrowth: 20,
           #                nodeScaling: {width:  1, height: 1, radius: 1},
           #                maxNodeSizeIncrements: 600,
           #                activeAreaBoxSize: 100,
           #                clusterLevelDifference: 2
           #              }

    graph = { nodes: nodes, edges: edges , options:options}
    #console.log "graph created with: #{graph.nodes.size()} nodes and  #{graph.edges.size()} edges"
    callback(graph)

  map_Article = (article, next) ->
    addEdge(article.parent, article.title, 'article')
    next()

  #map_Articles = (view)
  map_View = (view, next) ->
    addEdge(view.parent, view.title, 'view')
    importService.find_Subject_Contains view.id, (article_Ids)->
      importService.get_Subjects_Data article_Ids, (article_Data)->
        articlesToMap = ({id: article_Id, title: article_Data[article_Id].title, parent:view.title} for article_Id of article_Data)
        async.each articlesToMap, map_Article, next

  map_Folder = (folder, next) ->
    addEdge(folder.parent, folder.title, 'folder')
    importService.find_Subject_Contains folder.id, (view_ids)->
      importService.get_Subjects_Data view_ids, (views_Data)->
        viewsToMap = ({id: view_Id, title: views_Data[view_Id].title, parent:folder.title} for view_Id of views_Data)
        async.each viewsToMap, map_View, next

  map_Folders = (parent, folders_Ids, next)->
    importService.get_Subjects_Data folders_Ids, (folders_Data)->
      foldersToMap = ({id: folder_Id, title: folders_Data[folder_Id].title, parent:parent} for folder_Id of folders_Data)
      async.each foldersToMap, map_Folder, next



  #step 1
  #console.log('here')
  importService.find_Using_Is 'Library', (library_Ids)->
    library_Id = library_Ids.first()
    importService.get_Subject_Data library_Id, (library_Data)->
      library_Name = library_Data.title
      importService.get_Library_Folders_Ids library_Name, (folders_Ids)->
        map_Folders(library_Name, folders_Ids, sendData)




module.exports = get_Graph