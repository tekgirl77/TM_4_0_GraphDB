Content_Service = require '../../src/services/Content-Service'

describe '| services | Content-Service.test', ->

  contentService = null

  before ->
    contentService  = new Content_Service()

  it 'constructor',->
    using contentService, ->
      @.options    .assert_Is {}
      @.configService.constructor.name.assert_Is('Config_Service')

  it 'construtor (with params)',->
    options = { configService: 'abc'}
    using new Content_Service(options), ->
      @.options      .assert_Is(options)
      @.configService.assert_Is(options.configService)

  it 'library_Folder', (done)->
    using contentService,->
      @.library_Folder (folder)->
        folder.assert_Folder_Exists()
              .assert_Contains('.tmCache/_TM_3_5_Content')
              .assert_Contains('Lib_Vulnerabilities')
              .assert_Contains(process.cwd())
        done()

  it 'library_Json_Folder', (done)->
    using contentService,->
      @.library_Folder (folder)=>
        @.library_Json_Folder (json_Folder, library_Folder)->
          library_Folder.assert_Is(folder)
          json_Folder   .assert_Is(library_Folder.append('-json'))
          done()

  it 'load_Library_Data',(done)->
    @timeout(10000)         # git it time to clone
    using contentService,->
      @.library_Folder (folder)=>
        @.load_Library_Data (result)->
          folder.assert_Contains(folder)
          done()

  it.only 'convert_Library_Data', (done)->
    using contentService,->
      @.convert_Library_Data ()->

        done()