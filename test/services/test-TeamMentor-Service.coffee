TeamMentor_Service   = require('./../../src/services/TeamMentor-Service')

describe 'services | test-TeamMentor-Service |', ->

  describe 'core',->
    teamMentorService = new TeamMentor_Service()

    it 'check ctor', ->
      TeamMentor_Service.assert_Is_Function()

      teamMentorService.name        .assert_Is_String()
      teamMentorService.tmServer    .assert_Is_String()
      teamMentorService.cacheService.assert_Is_Object()
      teamMentorService.asmx        .assert_Is_Object()

      teamMentorService.name           .assert_Is '_tm_data'
      teamMentorService.name           .assert_Is teamMentorService.cacheService.area
      teamMentorService.tmServer       .assert_Is 'https://tmdev01-sme.teammentor.net'

    it 'tmServerVersion', (done)->
      teamMentorService.tmServerVersion.assert_Is_Function()
      teamMentorService.tmServerVersion (version)->
        version.assert_Is('3.5.0.0')
        done()

    it 'libraries', (done)->
      teamMentorService.libraries.assert_Is_Function()
      teamMentorService.libraries (libraries)->
        libraries.assert_Is_Object();
        (Object.keys(libraries).size() > 10).assert_Is_True()
        libraries['UNO']     .assert_Is_Object()
        libraries['UNO'].name.assert_Is('UNO')
        done()

    it 'library', (done)->
      teamMentorService.library.assert_Is_Function()
      teamMentorService.library 'UNO', (library)->
        library.assert_Is_Object()
        library.name = 'UNO'
        done()

  describe 'asmx',->
    teamMentorService = new TeamMentor_Service()
    asmx              = teamMentorService.asmx

    it '.ctor', ->
      asmx.teamMentor  .assert_Is_Equal_To(teamMentorService)
      asmx.asmx_BaseUrl.assert_Is_Equal_To(teamMentorService.tmServer + '/Aspx_Pages/TM_WebServices.asmx/')

    it '_json_Post', (done)->

      methodName = 'Ping'
      asmx._json_Post methodName, {message:''}, (response)->
        response.d.assert_Contains('received ping: ')
        done()

    it 'ping', (done)->
      value = (5).random_Letters()
      asmx.ping '', (data)->
        data.assert_Contains('received ping: ')
        done()

    it 'getFolderStructure_Libraries', (done)->
      asmx.getFolderStructure_Libraries (data)->
        data.assert_Is_Array()
        data.first().assert_Is_Object()
        data.first().__type       .assert_Is 'TeamMentor.CoreLib.Library_V3'
        data.first().libraryId    .assert_Is 'ea854894-8e16-46c8-9c61-737ef46d7e82'
        data.first().name         .assert_Is '.NET 2.0'
        data.first().subFolders   .assert_Is_Array()
        data.first().views        .assert_Is_Array()
        data.first().guidanceItems.assert_Is_Array()
        done()

