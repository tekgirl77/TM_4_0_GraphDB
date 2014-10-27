add_Data = (graphService, callback)->
  graphService.db.put [{ subject: 'a', predicate : 'b1', object:'c1'}, { subject: 'a', predicate : 'd1', object:'f1'}], callback
module.exports = add_Data