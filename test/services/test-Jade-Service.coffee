fs            = require('fs')
expect        = require('chai'         ).expect
Jade_Service  = require('./../../src/services/Jade-Service')

describe 'services | test-Jade-Service |', ->

  it 'check ctor', ->
    jadeService  = new Jade_Service()
    expect(Jade_Service      ).to.be.an  ('Function')
    expect(jadeService       ).to.be.an  ('Object'  )
    expect(jadeService.config               ).to.be.an('Object');
    expect(jadeService.targetFolder         ).to.be.an('String');

    expect(jadeService.compileJadeFileToDisk).to.be.an('function');
    expect(jadeService.calculateTargetPath  ).to.be.an('function');
    expect(jadeService.enableCache          ).to.be.an('function');
    expect(jadeService.cacheEnabled         ).to.be.an('function');

    expect(jadeService.targetFolder         ).to.equal(jadeService.config.jade_Compilation)


  it 'enableCache , cacheEnabled', ->
    jadeService = new Jade_Service();
    expect(jadeService.cacheEnabled()    ).to.be.false
    expect(jadeService.enableCache()     ).to.equal(jadeService)
    expect(jadeService.cacheEnabled()    ).to.be.true
    expect(jadeService.enableCache(false)).to.equal(jadeService)
    expect(jadeService.cacheEnabled()    ).to.be.false
    expect(jadeService.enableCache (true )).to.equal(jadeService)
    expect(jadeService.cacheEnabled()    ).to.be.true


  it 'calculateTargetPath', ->
    jadeService = new Jade_Service();
    targetFolder        = jadeService.targetFolder;

    expect(targetFolder                   ).to.equal(jadeService.config.jade_Compilation);
    expect(jadeService.calculateTargetPath).to.be.an('Function');
    expect(jadeService.calculateTargetPath('aaa'             )).to.equal(targetFolder.path_Combine('aaa.txt'             ));
    expect(jadeService.calculateTargetPath('aaa/bbb'         )).to.equal(targetFolder.path_Combine('aaa_bbb.txt'         ));
    expect(jadeService.calculateTargetPath('aaa/bbb/ccc'     )).to.equal(targetFolder.path_Combine('aaa_bbb_ccc.txt'     ));
    expect(jadeService.calculateTargetPath('aaa/bbb.jade'    )).to.equal(targetFolder.path_Combine('aaa_bbb_jade.txt'    ));
    expect(jadeService.calculateTargetPath('aaa/bbb.ccc.jade')).to.equal(targetFolder.path_Combine('aaa_bbb_ccc_jade.txt'));
    expect(targetFolder.folder_Exists()).to.be.true

  it 'compileJadeFileToDisk', ()->
    jadeService = new Jade_Service()

    expect(jadeService.compileJadeFileToDisk('a')).to.equal(false)

    defaultJadeFile = '/views/index.jade'
    targetPath    = jadeService.calculateTargetPath(defaultJadeFile);
    if (targetPath.file_Not_Exists())
      expect(jadeService.compileJadeFileToDisk(defaultJadeFile)).to.be.true
    jadeTemplate  = require(targetPath)
    expect(jadeTemplate  ).to.be.an('function')
    expect(jadeTemplate()).to.be.an('string')

    html = jadeTemplate()
    expect(html).to.contain '<!DOCTYPE html><html lang="en"><head>'



  it 'renderJadeFile', ()->
    jadeService = new Jade_Service().enableCache();

    renderedJade = jadeService.renderJadeFile('/views/index.jade');

    expect(renderedJade).to.not.equal("");
    expect(renderedJade).to.contain  ('<!DOCTYPE html><html lang="en"><head></head><body><h2 id="title">')


    expect(jadeService.renderJadeFile('a')).to.equal    ("");



