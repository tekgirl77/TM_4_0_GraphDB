require 'fluentnode'
Cache_Service = require('./../../src/services/Cache-Service')
expect        = require('chai').expect

describe 'services | test-Cache-Service |', ->
    
  cacheService = new Cache_Service()

  it 'Cache-Service ctor',->
    expect(Cache_Service).to.be.an('Function')

    expect(cacheService               ).to.be.an('Object')
    expect(cacheService._cacheFolder  ).to.be.an('String')

    expect(cacheService._cacheFolder   ).to.equal('./.tmCache')
    expect(cacheService._forDeletionTag).to.equal('.deleteCacheNext')
    expect(cacheService.area).to.equal(null)
    expect(cacheService.cacheFolder()  ).to.equal('./.tmCache'.realPath())
    expect(new  Cache_Service('aaaa').area).to.equal('aaaa')



  it 'cacheFolder', ->
    expect(cacheService.cacheFolder).to.be.an('Function')
    expect(cacheService.cacheFolder()).to.equal(process.cwd().path_Combine(cacheService._cacheFolder))

  it 'delete', ->
      expect(cacheService.delete).to.be.an('Function')

  it 'path_Key',->
    expect(cacheService.path_Key('aa')).to.equal(cacheService.cacheFolder().path_Combine('aa'))
    expect(cacheService.path_Key(null)).to.equal(null)

  it 'put, get, delete', ->
    key_Name  = 'key_'.add_Random_String(5)
    key_Value = 'value_'.add_Random_String(5)
    key_Path  = cacheService.path_Key(key_Name);

    expect(key_Path    .file_Exists()          ).to.equal(false)
    expect(cacheService.put(key_Name,key_Value)).to.equal(key_Value)
    expect(key_Path    .file_Exists()          ).to.equal(true)
    expect(cacheService.get(key_Name)          ).to.equal(key_Value)
    expect(key_Path    .file_Delete()          ).to.equal(true)

  it 'setup', ->
    expect(cacheService.setup).to.be.an('Function')
    expect(cacheService.cacheFolder().file_Exists()).to.be.true

  describe 'separate Cache_Service |', ->

    it 'customArea', ->
      area = "_tmp_area_".add_5_Random_Letters()
      cacheService = new Cache_Service(area)
      cacheFolder  = cacheService.cacheFolder()
      expect(cacheService.area      ).to.equal(area)
      expect(cacheFolder            ).to.contain('.tmCache')
      expect(cacheFolder            ).to.contain(cacheService.area)
      expect(cacheFolder.file_Name()).to.equal(area)
      expect(cacheFolder.exists()   ).to.be.true
      expect(cacheFolder.delete_Folder()).to.be.true


    it 'markForDeletion and delete', ->
      expect(cacheService.delete         ).to.be.an('Function')
      expect(cacheService.markForDeletion).to.be.an('Function')

      cacheService = new Cache_Service()
      cacheService._cacheFolder = "./.tmCache".add_Random_String(5)
      expect(cacheService.cacheFolder().exists()).to.be.false
      cacheService.setup()
      expect(cacheService.cacheFolder().exists()).to.be.true


      forDeleleTag_File = cacheService.cacheFolder().path_Combine(cacheService._forDeletionTag)
      expect(forDeleleTag_File).to.not.equal(cacheService.cacheFolder())
      forDeleleTag_File.file_Delete()
      expect(forDeleleTag_File             .exists()      ).to.equal(false)
      expect(cacheService.cacheFolder()    .exists()      ).to.equal(true)
      expect(cacheService.markForDeletion().file_Exists() ).to.equal(true)
      expect(forDeleleTag_File             .exists()      ).to.equal(true, 'forDeleleTag_File should exist')
      expect(cacheService.cacheFolder()    .files().size()).to.be.above(0)

      cacheService.setup()
      expect(cacheService.cacheFolder()    .exists()      ).to.equal(true)
      expect(cacheService.cacheFolder()    .files().size()).to.equal(0)

      cacheService.setup()
      expect(cacheService.cacheFolder()    .exists()      ).to.equal(true)
      expect(cacheService.cacheFolder().folder_Delete_Recursive()).to.equal.true