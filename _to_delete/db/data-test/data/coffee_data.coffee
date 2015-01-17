add_Data = (options, callback)->
  options.data.addMappings('a', [{'b1':'c1'},{ 'd1':'f1'}])
  callback()
module.exports = add_Data