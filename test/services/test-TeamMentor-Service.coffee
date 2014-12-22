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
      teamMentorService.tmServer       .assert_Is 'https://uno.teammentor.net'

    it 'tmServerVersion', (done)->
      teamMentorService.tmServerVersion.assert_Is_Function()
      teamMentorService.tmServerVersion (version)->
        version.assert_Is('3.5.0.0')
        done()

    it 'libraries', (done)->
      teamMentorService.libraries.assert_Is_Function()
      teamMentorService.libraries (libraries)->
        libraries.assert_Is_Object();
        Object.keys(libraries).assert_Size_Is(2)
        libraries['Guidance']     .assert_Is_Object()
        libraries['Guidance'].name.assert_Is('Guidance')
        done()

    it 'library', (done)->
      teamMentorService.library.assert_Is_Function()
      teamMentorService.library 'Guidance', (library)->
        library.assert_Is_Object()
        library.name = 'Guidance'
        done()

    it 'article', (done)->
      article_Guid = '6cdd9588-3483-4054-8bb7-17f790dedf10'
      teamMentorService.article.assert_Is_Function()
      teamMentorService.article article_Guid, (article)->
        article.assert_Is_Object()
        article.Metadata      .assert_Is_Object()
        article.Metadata.Id   .assert_Is(article_Guid)
        article.Metadata.Title.assert_Is('Constrain, Reject, And Sanitize Input')
        done()

    it 'login (good pwd)', (done)->
      teamMentorService.login_Rest "graph123","aaaaaa", (data)->
        data.assert_Is('00000000-0000-0000-0000-000000000000')
        done()

  describe 'asmx',->
    teamMentorService = new TeamMentor_Service()
    asmx              = teamMentorService.asmx

    it '.ctor', ->
      asmx.teamMentor  .assert_Is_Equal_To(teamMentorService)
      asmx.asmx_BaseUrl.assert_Is_Equal_To(teamMentorService.tmServer + '/Aspx_Pages/TM_WebServices.asmx/')

    it '_json_Post', (done)->
      @timeout 10000        # in case the .NET server needs to wake up
      methodName = 'Ping'
      asmx._json_Post methodName, {message:''}, (response)->
        #console.log response
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
        data.first().libraryId    .assert_Is 'de693015-55c9-4328-bbc8-42db82ae8b7a'
        data.first().name         .assert_Is 'Gateways'
        data.first().subFolders   .assert_Is_Array()
        data.first().views        .assert_Is_Array()
        data.first().guidanceItems.assert_Is_Array()
        done()

    it 'login (bad pwd)', (done)->
      asmx.login "aaa","bbb", (data)->
        data.assert_Is('00000000-0000-0000-0000-000000000000')
        done()


