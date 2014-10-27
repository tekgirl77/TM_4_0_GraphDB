GitHub_Service = require('./../../../src/services/GitHub-Service')

add_Data = (graphService, callback)->
  gist_Id   = '456938ffc68d151bea96'
  gist_File = 'article-data.json'
  new GitHub_Service().enableCache().gist gist_Id, gist_File, (gistData) ->
    data = JSON.parse(gistData.content)
    graphService.db.put data, callback
module.exports = add_Data