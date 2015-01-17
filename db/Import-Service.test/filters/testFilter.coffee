get_Data = (params, callback)->
  graph = params.graph
  data = { number_of_nodes : graph.nodes.length , number_of_edges: graph.edges.length }
  callback(data)
module.exports = get_Data 