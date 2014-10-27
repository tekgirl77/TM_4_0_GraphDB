require('fluentnode')
dot = require(process.cwd().path_Combine('node_modules/vis/lib/network/dotparser.js'));

class Dot_Service
  constructor: ()->
    @dot           = dot

  dot_To_Graph: (dotData, callback) =>
    graph = @dot.parseDOT(dotData);
    callback(graph)

  dot_To_Triplets: (dotData, callback) =>
    @dot_To_Graph dotData, (graph) =>
      @graph_To_Triplets graph, (triplets) =>
        callback(triplets)

  graph_To_Triplets: (graph, callback) =>
    "in graph_To_Triplets"
    triplets = []
    for edge in graph.edges
      triplets.push({ subject: edge.from , predicate: edge.type , object: edge.to })
    callback(triplets)

module.exports = Dot_Service
