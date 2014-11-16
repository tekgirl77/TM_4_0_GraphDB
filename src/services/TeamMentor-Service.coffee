Cache_Service  = require('./Cache-Service')
xml2js         = require('xml2js');

class TeamMentor_Service
  constructor: (name)->
    @name         = name || '_tm_data'
    @cacheService = new Cache_Service(@name)
    #@tmServer     = 'https://tmdev01-sme.teammentor.net'
    @tmServer     = 'https://uno.teammentor.net'
    @asmx         = new TeamMentor_ASMX(@)

  tmServerVersion: (callback)->
    url = @tmServer + '/rest/version'
    @cacheService.http_GET url, (html)->
      xml2js.parseString html, (error, json) -> callback json.string._

  libraries: (callback)=>
    @asmx.getFolderStructure_Libraries (data)=>
      libraries = {}
      for libraryStructure in data
        libraries[libraryStructure.name] = libraryStructure
      callback(libraries)

  library: (name, callback)=>
    @libraries (libraries)=>
      callback(libraries[name])

  article: (guid, callback)=>
    if not guid
      callback null
    else
      url = @tmServer + "/jsonp/#{guid}"
      @cacheService.json_GET url, (article)->
        callback article

  login_Rest: (username,password, callback)=>
    url = @tmServer + "/rest/login/#{username}/#{password}"
    @cacheService.json_GET url, (article)->
      callback article


class TeamMentor_ASMX
  constructor: (teamMentorService)->
    @teamMentor   = teamMentorService
    @asmx_BaseUrl = @teamMentor.tmServer + '/Aspx_Pages/TM_WebServices.asmx/'

  _json_Post: (methodName, postData,callback) =>
    @teamMentor.cacheService.json_POST @asmx_BaseUrl + methodName, postData, callback

  ping: (message,callback) =>
    @_json_Post "Ping", {message:message}, (json, response) -> callback(json.d)

  getFolderStructure_Libraries: (callback) =>
    @_json_Post "GetFolderStructure_Libraries", {}, (json, response) ->  callback(json.d)

  login: (username, password, callback) =>
    @_json_Post "Login", {username:username, password:password}, (json, response) ->
      #console.log json
      callback(json.d)

module.exports = TeamMentor_Service