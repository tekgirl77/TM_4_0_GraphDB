Config_Service = require '../../src/services/Config-Service'

describe 'services | Config-Service.test', ->

  options       = null
  configService = null

  beforeEach ->
    options = { config_File: '_tmp-tm-Config.json'}
    configService = new Config_Service(options)
    configService.config_File_Path().assert_File_Not_Exists()

  afterEach ->
    configService.config_File_Path()
                 .file_Delete().assert_Is_True()

  it 'construtor',->
    using new Config_Service(), ->
      @.options    .assert_Is {}
      @.config_File.assert_Is '.tm-Config.json'

  it 'construtor (with params)',->
    configService.assert_Is_Object()
    configService.options.assert_Is(options)    # set in beforeEach

  it 'config_File_Path', ->
    using configService.config_File_Path(), ->
      @.parent_Folder().path_Combine('package.json')
                       .assert_File_Exists('path should be in the root of the repo')
      @.file_Name()    .assert_Is(options.config_File)

  it 'get_Config', (done)->
    using configService, ->
      @.get_Config (config)=>
        @.config_File_Path().assert_File_Exists()
        config.assert_Is_Object()
        done()

  it 'get_Defaults', ()->
    using configService.get_Defaults(), ->
      @.tm_3_5_Server.assert_Is 'https://tmdev01-uno.teammentor.net'
      @.content_Folder.assert_Is './.tmCache/_TM_3_5_Content'

  it 'save_Config', (done)->
    done()