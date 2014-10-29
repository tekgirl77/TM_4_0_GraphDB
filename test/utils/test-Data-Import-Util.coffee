expect          = require('chai'     ).expect
Data_Import_Util = require('./../../src/utils/Data-Import-Util')

describe 'utils | test-Data-Import-Util |', ->

  it 'check ctor',->
    dataImport = new Data_Import_Util()
    expect(Data_Import_Util).to.be.an('function')
    expect(dataImport      ).to.be.an('object')
    expect(dataImport.data ).to.be.an('array')
    expect(dataImport.data ).to.be.empty

  it 'guid', ->
    dataImport = new Data_Import_Util()
    expect(dataImport.guid         ).to.be.an('function')
    expect(dataImport.guid()       ).to.be.an('string')
    expect(dataImport.guid().size()).to.equal(36)

  it 'addMapping', ->
    dataImport = new Data_Import_Util()
    expect(dataImport.addMapping   ).to.be.an('function')
    expect(dataImport.addMapping('a','b','c')).to.equal(dataImport)
    expect(dataImport.data.size()           ).to.equal(1)
    expect(dataImport.data.first().subject  ).to.equal('a')
    expect(dataImport.data.first().predicate).to.equal('b')
    expect(dataImport.data.first().object   ).to.equal('c')

  it 'addMappings (using array)', ->
    subject = 'a'
    mappings = [{ b: 'c'} , {d:'f'}]
    result =   [ { subject: 'a', predicate: 'b', object: 'c' },
                 { subject: 'a', predicate: 'd', object: 'f' } ]

    dataImport = new Data_Import_Util()
    expect(dataImport.addMappings(subject,mappings)).to.equal(dataImport)
    expect(dataImport.data                         ).to.deep.equal(result)

  it 'addMappings (using object)', ->
    data = []
    subject = 'a'
    mappings = { b: 'c' , d:'f'}
    result =   [ { subject: 'a', predicate: 'b', object: 'c' },
                 { subject: 'a', predicate: 'd', object: 'f' } ]

    dataImport = new Data_Import_Util()
    expect(dataImport.addMappings(subject,mappings)).to.equal(dataImport)
    expect(dataImport.data                         ).to.deep.equal(result)

  it 'addMappings (using object with array)', ->
    subject = 'a'
    mappings = { b: 'c' , d: ['f','g']}
    result =   [ { subject: 'a', predicate: 'b', object: 'c' },
                 { subject: 'a', predicate: 'd', object: 'f' }
                 { subject: 'a', predicate: 'd', object: 'g' }]

    dataImport = new Data_Import_Util()
    expect(dataImport.addMappings(subject,mappings)).to.equal(dataImport)
    expect(dataImport.data                         ).to.deep.equal(result)