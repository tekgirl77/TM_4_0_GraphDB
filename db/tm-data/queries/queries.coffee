get_Graph = (options, callback)->

  importService = options.importService

  db =importService.graph.db
  db.search [
              { subject: db.v('object'), object:'Technology'}
              { subject: db.v('object'), predicate: db.v('predicate'), object: db.v('subject')}
            ], (err, data)->
                importService.new_Data_Import_Util(data).graph_From_Data (graph)->
                  callback(graph)

module.export = get_Graph