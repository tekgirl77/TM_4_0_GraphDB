get_Graph = (params, callback)->
  graph = { nodes: [{'a','b'}] , edges: [{from:'a' , to: 'b'}] }
  callback(graph)
module.exports = get_Graph 