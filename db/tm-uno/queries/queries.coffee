async = require 'async'

get_Graph = (options, callback)->

  importService = options.importService
  graph         = importService.new_Vis_Graph()
  db            = importService.graph.db

 #add_Metadata_Mappings = (next)->
 #  add_Mapping_For 'category',->
 #    add_Mapping_For 'phase',->
 #      add_Mapping_For 'technology',->
 #        add_Mapping_For 'type',->
 #          next()

 #add_Mapping_For = (target , next)->
 #  mappings = {}
 #  importService.graph.get_Predicate target, (data)->
 #    if data
 #      for item in data #.take(50)
 #        query_Id = item.object
 #        mapping  = item.predicate
 #        mappings[mapping] ?= []
 #        if (mappings[mapping].not_Contains(query_Id))
 #          mappings[mapping].push(query_Id)

 #      entries = []
 #      metadata_Node = graph.add_Node('Metadata').dot()._mass(15)
 #      for mapping of mappings
 #        graph.add_Node(mapping).circle().black()._mass(15)
 #        metadata_Node.add_Edge(mapping)
 #        for entry in mappings[mapping]
 #          graph.add_Edge(mapping, entry)
 #          entries.push(entry)

 #      #console.log entries.unique()
 #      #async.each entries.unique(), resolve_Node_Title, ->
 #      #format_Main_Nodes ->
 #      #  next()

 #    next()

  add_Queries_Mappings = (next)->
    searchTerms = [
                    { subject: db.v('query_A') , predicate: 'is'            , object: 'Query'}
                    { subject: db.v('query_A') , predicate: 'contains-query', object: db.v('query_B')}
                  ]
    db.search searchTerms, (error, data)->

      for item in data
        graph.add_Edge(item.query_A, item.query_B, 'contains-query')
      next()

  resolve_Node_Title = (node,next) ->
    db.get {subject:node.id, predicate:'title'}, (error,data)->
      
      if (data and not data.empty())
        node._label(data.first().object)
        node._title(node.id)
        #">> mapped #{node.id} to #{data.first().object}".log()
      #else
      #  "<< no data for #{node.id}".log()
      next()

  format_Main_Nodes = (next)->

    format_Metadata_Node = (target)=>
      target.circle().black()._mass(2)

    format_Global_Node = (target)=>
      target.circle().black()._mass(10)
      target_Edges = (edge.to_Node() for edge in graph.edges when edge.from_Node().label == target.label)
      for edge in target_Edges
        edge.circle()._color('#CCFFAA')._mass(20)

    #'Guidance',
    format_Metadata_Node(node) for node in graph.nodes when ['Category', 'Phase', 'Technology', 'Type'].contains(node.label)
    format_Global_Node(node)   for node in graph.nodes when ['Guidance'].contains(node.label)

    next()
   #importService.find_Using_Title 'Guidance', (data)->
   #  root_Id = data.first()
   #  if (graph.node(root_Id))
   #    graph.node(root_Id).circle().black()._mass(15)
   #    db.nav(root_Id).archOut('contains-query').as('query')
   #    .solutions (error,data)->
   #      for item in data
   #        graph.node(item.query).circle()._color('#CCFFAA')._mass(15)
   #      next()
   #  else
   #    next()

  resolve_Titles = (next)->
    async.each graph.nodes, resolve_Node_Title, ->
      format_Main_Nodes ->
        next()

  add_Queries_Mappings ->
    #add_Metadata_Mappings ->
      resolve_Titles ->
        #importService.graph.allData (data)->
        #  console.log data
          callback graph
          return;


module.exports = get_Graph