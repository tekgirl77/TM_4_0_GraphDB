expect         = require('chai'         ).expect
Data_Service   = require('./../../src/services/Data-Service')
Graph_Service  = require('./../../src/services/Graph-Service')

describe 'test-Data-Service |', ->
  describe 'core |', ->
    it 'check ctor',->
      dataService  = new Data_Service()
      expect(Data_Service             ).to.be.an  ('function')
      expect(dataService              ).to.be.an  ('object')
      expect(dataService.name         ).to.be.an  ('string')
      expect(dataService.graphService ).to.be.an  ('object')
      expect(dataService.path_Root    ).to.be.an  ('string')
      expect(dataService.path_Name    ).to.be.an  ('string')
      expect(dataService.path_Data    ).to.be.an  ('string')
      expect(dataService.path_Queries ).to.be.an  ('string')

      expect(dataService.name         ).to.equal  ('test')
      expect(dataService.path_Root    ).to.equal  ('db'             .realPath())
      expect(dataService.path_Name    ).to.equal  ('db/test'        .realPath())
      expect(dataService.path_Data    ).to.equal  ('db/test/data'   .realPath())
      expect(dataService.path_Queries ).to.equal  ('db/test/queries'.realPath())

      expect(dataService.graphService       ).to.be.instanceof(Graph_Service)
      expect(dataService.graphService.dbName).to.equal('test')

      dataService  = new Data_Service('aaaa')
      expect(dataService.name               ).to.equal('aaaa')
      expect(dataService.path_Name          ).to.equal('db/aaaa'        .realPath())
      expect(dataService.path_Data          ).to.equal('db/aaaa/data'   .realPath())
      expect(dataService.path_Queries       ).to.equal('db/aaaa/queries'.realPath())
      expect(dataService.graphService.dbName).to.equal('aaaa')

      expect(dataService.path_Name.folder_Delete_Recursive()).to.be.true


    it 'data_Files',->
      dataService  = new Data_Service()
      expect(dataService.data_Files  ).to.be.an("function")
      expect(dataService.data_Files()).to.be.an("array")
      test_Data = "{ test: 'data'}"
      test_File = dataService.path_Data.path_Combine("testData.json")
      expect(test_Data.saveAs(test_File)).to.be.true
      expect(dataService.data_Files()   ).to.be.not.empty
      expect(dataService.data_Files()   ).to.deep.contain(test_File.realPath())
      expect(test_File.file_Delete()    ).to.be.true
      expect(dataService.data_Files()   ).to.deep.not.contain(test_File.realPath())

    it 'query_Files',->
      dataService  = new Data_Service()
      expect(dataService.query_Files  ).to.be.an("function")
      expect(dataService.query_Files()).to.be.an("array")
      test_Data = "{ test: 'query'}"
      test_File = dataService.path_Data.path_Combine("testQuery.json")
      expect(test_Data.saveAs(test_File)) .to.be.true
      expect(dataService.query_Files()  ).to.be.not.empty
      expect(dataService.query_Files()  ).to.deep.contain(test_File.realPath())
      expect(test_File.file_Delete()    ).to.be.true
      expect(dataService.query_Files()  ).to.deep.not.contain(test_File.realPath())

  describe 'load data |', ->

    dataService   = new Data_Service()
    path_Data     = dataService.path_Data

    json_File_1   = path_Data.path_Combine("testData_1.json"  )
    json_File_2   = path_Data.path_Combine("testData_2.json"  )
    coffee_File_1 = path_Data.path_Combine("testData_1.coffee")
    coffee_File_2 = path_Data.path_Combine("testData_2.coffee")
    dot_File_1    = path_Data.path_Combine("testData_1.dot"   )
    dot_File_2    = path_Data.path_Combine("testData_2.dot"   )

    json_Data_1   = JSON.stringify [{ subject: 'a', predicate : 'b', object:'c'}, { subject: 'a', predicate : 'd', object:'f'}]
    json_Data_2   = JSON.stringify [{ subject: 'g', predicate : 'b', object:'c'}, { subject: 'g', predicate : 'd', object:'f'}]
    coffee_Data_1   = '''add_Data = (graphService, callback)->
                           graphService.db.put [{ subject: 'a1', predicate : 'b1', object:'c1'}, { subject: 'a1', predicate : 'd1', object:'f1'}], callback
                         module.exports = add_Data '''
    coffee_Data_2   = '''add_Data = (graphService, callback)->
                           graphService.db.put [{ subject: 'g1', predicate : 'b1', object:'c1'}], callback
                         module.exports = add_Data '''
    dot_Data_1      = '''graph graphname {
                                            a2 -- b2 -- c2;
                                            b2 -- d2;
                                          }'''
    dot_Data_2      = '''{ d2 -- e3 }'''

    before ->
      expect(dataService.load_Data  ).to.be.an("function")

    afterEach (done)->
      file.file_Delete() for file in  path_Data.files()
      expect(path_Data.files()).to.be.empty
      dataService.graphService.deleteDb ->
        done()

    it 'load_Data (json)', (done)->
      json_Data_1.saveAs(json_File_1)
      json_Data_2.saveAs(json_File_2)
      expect(path_Data.files().size()).to.equal(2)
      dataService.load_Data ->
        dataService.graphService.allData (data)->
          expect(data).to.not.be.empty
          expect(data.length).to.equal(4)
          done()

    it 'load_Data (coffee)', (done)->
      coffee_Data_1.saveAs(coffee_File_1)
      coffee_Data_2.saveAs(coffee_File_2)
      expect(path_Data.files().size()).to.equal(2)
      dataService.load_Data ->
        dataService.graphService.allData (data)->
          expect(data).to.not.be.empty
          expect(data.length).to.equal(3)
          done()

    it 'load_Data (dot)', (done)->
      dot_Data_1.saveAs(dot_File_1)
      dot_Data_2.saveAs(dot_File_2)
      expect(path_Data.files().size()).to.equal(2)

      dataService.load_Data ->
        dataService.graphService.allData (data)->
          expect(data).to.not.be.empty
          expect(data.length).to.equal(4)
          done()

    it 'load_Data (all formats)', (done)->
      coffee_Data_1.saveAs(coffee_File_1)
      coffee_Data_2.saveAs(coffee_File_2)
      json_Data_1  .saveAs(json_File_1  )
      json_Data_2  .saveAs(json_File_2  )
      dot_Data_1   .saveAs(dot_File_1   )
      dot_Data_2   .saveAs(dot_File_2   )

      expect(path_Data.files().size()).to.equal(6)

      dataService.load_Data ->
        dataService.graphService.allData (data)->
          expect(data).to.not.be.empty
          expect(data.length).to.equal(11)
          done()
