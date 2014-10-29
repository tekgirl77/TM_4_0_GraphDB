get_Graph = (graphService, callback)->

  db = graphService.db
  db.search [
              { subject: db.v('object'), object:'Article'}
              { subject: db.v('object'), predicate: db.v('predicate'), object: db.v('subject')}
            ], (err, data)->
                graphService.graph_From_Data data, (graph)->
                  callback(graph)

module.export = get_Graph