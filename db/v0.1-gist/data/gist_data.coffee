GitHub_Service = require(process.cwd() + '/src/services/GitHub-Service')

add_Data = (dataUtil)->
  gist_Id   = '456938ffc68d151bea96'
  gist_File = 'article-data.json'
  new GitHub_Service().enableCache().gist gist_Id, gist_File, (gistData) ->
    dataUtil.data = JSON.parse(gistData.content)
module.exports = add_Data