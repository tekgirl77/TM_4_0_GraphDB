{Cache_Service}  = require('teammentor')
Swagger_GraphDB  = require '../../../src/api/base-classes/Swagger-GraphDB'

describe.only '| api | base-classes | Swagger-GraphDB.test', ->
  tmp_Cache = null

  before ->
    tmp_Cache = new Cache_Service("tmp_Cache")

  after ->
    tmp_Cache.delete_CacheFolder()

  it 'constructor', ->
    using new Swagger_GraphDB(), ->
      @.options      .assert_Is {}
      @.cache.area   .assert_Is 'data_cache'
      @.cache_Enabled.assert_Is_True()

  it 'constructor (with options)', ->
    options =  { cache: tmp_Cache, cache_Enabled:false, area:'cccc',  swaggerService: 'dddd'}
    using new Swagger_GraphDB(options), ->
      @.options       .assert_Is options
      @.cache         .assert_Is options.cache
      @.cache_Enabled .assert_Is_False()
      @.area          .assert_Is options.area
      @.swaggerService.assert_Is options.swaggerService

  it 'close_Import_Service_and_Send', (done)->
    temp_Data     = 'data_'.add_5_Letters()
    temp_Key      = 'key_'.add_5_Letters()
    importService =
      graph:
        closeDb: (callback)=>
          callback()
    res =
      send: (data)=>
        data.assert_Is (temp_Data.json_Str())
        tmp_Cache.get(temp_Key).assert_Is temp_Data
        done()

    options =
      cache: tmp_Cache

    using new Swagger_GraphDB(options), ->
      @.close_Import_Service_and_Send importService, res, temp_Data, temp_Key

  it 'save_To_Cache',->
    using new Swagger_GraphDB(cache: tmp_Cache), ->
      tmp_Cache.has_Key('a').assert_False()
      tmp_Cache.has_Key('b').assert_False()
      tmp_Cache.has_Key('c').assert_False()
      tmp_Cache.has_Key('d').assert_False()
      @.save_To_Cache('a', 123)
      @.save_To_Cache('b', '123')
      @.save_To_Cache('c', {key:'value'})
      @.save_To_Cache('d', ['0','1','2'])
      tmp_Cache.get('a').assert_Is 123
      tmp_Cache.get('b').assert_Is '123'
      tmp_Cache.get('c').json_Parse().assert_Is {key:'value'}
      tmp_Cache.get('d').json_Parse().assert_Is ['0','1','2']

  it 'save_To_Cache (empty data)',->
    key   = 'a_'.add_5_Letters()
    value = 'aaa'.add_5_Letters()
    tmp_Cache.put key, value

    check_Value = ()->
      tmp_Cache.get(key).assert_Is(value)

    using new Swagger_GraphDB(cache: tmp_Cache), ->
      check_Value(@.save_To_Cache key)
      check_Value(@.save_To_Cache key, null)
      check_Value(@.save_To_Cache key, undefined)
      check_Value(@.save_To_Cache key, [])
      check_Value(@.save_To_Cache key, {})

