expect         = require('chai'         ).expect
Db_Service     = require('./../../src/services/Db-Service')
Graph_Service  = require('./../../src/services/Graph-Service')

describe 'services | test-Data-Service |', ->
  describe 'core |', ->
    it 'check ctor',->
      dbService  = new Db_Service()
      expect(Db_Service             ).to.be.an  ('function')
      expect(dbService              ).to.be.an  ('object')
      expect(dbService.name         ).to.be.an  ('string')
      expect(dbService.graphService ).to.be.an  ('object')
      expect(dbService.path_Root    ).to.be.an  ('string')
      expect(dbService.path_Name    ).to.be.an  ('string')
      expect(dbService.path_Data    ).to.be.an  ('string')
      expect(dbService.path_Queries ).to.be.an  ('string')

      expect(dbService.name         ).to.equal  ('test')
      expect(dbService.path_Root    ).to.equal  ('db'             )
      expect(dbService.path_Name    ).to.equal  ('db/test'        )
      expect(dbService.path_Data    ).to.equal  ('db/test/data'   )
      expect(dbService.path_Queries ).to.equal  ('db/test/queries')

      expect(dbService.graphService       ).to.be.instanceof(Graph_Service)
      expect(dbService.graphService.dbName).to.equal('test')

      dbService  = new Db_Service('aaaa')
      expect(dbService.name               ).to.equal('aaaa'           )
      expect(dbService.path_Name          ).to.equal('db/aaaa'        )
      expect(dbService.path_Data          ).to.equal('db/aaaa/data'   )
      expect(dbService.path_Queries       ).to.equal('db/aaaa/queries')
      expect(dbService.graphService.dbName).to.equal('aaaa'           )

      expect(dbService.path_Name.folder_Delete_Recursive()).to.be.true


    it 'data_Files',->
      dbService  = new Db_Service().setup()
      expect(dbService.data_Files  ).to.be.an("function")
      expect(dbService.data_Files()).to.be.an("array")
      test_Data = "{ test: 'data'}"
      test_File = dbService.path_Data.path_Combine("testData.json")
      expect(test_Data.saveAs(test_File)).to.be.true
      expect(dbService.data_Files()   ).to.be.not.empty
      expect(dbService.data_Files()   ).to.deep.contain(test_File.realPath())
      expect(test_File.file_Delete()    ).to.be.true
      expect(dbService.data_Files()   ).to.deep.not.contain(test_File.realPath())

    it 'query_Files',->
      dbService  = new Db_Service()
      expect(dbService.query_Files  ).to.be.an("function")
      expect(dbService.query_Files()).to.be.an("array")
      test_Data = "{ test: 'query'}"
      test_File = dbService.path_Queries.path_Combine("testQuery.json")
      expect(test_Data.saveAs(test_File)) .to.be.true
      expect(dbService.query_Files()  ).to.be.not.empty
      expect(dbService.query_Files()  ).to.deep.contain(test_File.realPath())
      expect(test_File.file_Delete()    ).to.be.true
      expect(dbService.query_Files()  ).to.deep.not.contain(test_File.realPath())

    it 'run_Query', (done)->
      dbService  = new Db_Service()
      expect(dbService.run_Query  ).to.be.an("function")

      query_Name = 'testQuery'
      coffee_Query = '''get_Graph = (graphService, callback)->
                          graph = { nodes: [{'a','b'}] , edges: [{from:'a' , to: 'b'}] }
                          callback(graph)
                        module.exports = get_Graph '''
      coffee_File = dbService.path_Queries.path_Combine("#{query_Name}.coffee")
      expect(coffee_Query.saveAs(coffee_File)) .to.be.true

      dbService.run_Query query_Name, (graph)->
        expect(graph).to.not.be.null
        expect(graph      ).to.be.an('object')
        expect(graph.nodes).to.be.an('array')
        expect(graph.edges).to.be.an('array')
        expect(graph.nodes.first()).to.deep.equal({'a','b'})
        expect(graph.edges.first()).to.deep.equal({from:'a' , to: 'b'})
        done()

  #expect(dbService.query_Files()   ).to.be.not.empty

      #console.log(dbService)

  describe 'load data |', ->

    dbService   = new Db_Service().setup()
    path_Data     = dbService.path_Data

    json_File_1   = path_Data.path_Combine("testData_1.json"  )
    json_File_2   = path_Data.path_Combine("testData_2.json"  )
    coffee_File_1 = path_Data.path_Combine("testData_1.coffee")
    coffee_File_2 = path_Data.path_Combine("testData_2.coffee")
    dot_File_1    = path_Data.path_Combine("testData_1.dot"   )
    dot_File_2    = path_Data.path_Combine("testData_2.dot"   )

    json_Data_1   = JSON.stringify [{ subject: 'a', predicate : 'b', object:'c'}, { subject: 'a', predicate : 'd', object:'f'}]
    json_Data_2   = JSON.stringify [{ subject: 'g', predicate : 'b', object:'c'}, { subject: 'g', predicate : 'd', object:'f'}]
    coffee_Data_1   = '''add_Data = (data,callback)->
                           data.addMappings('a1', [{'b1':'c1'},{ 'd1':'f1'}])
                           callback()
                         module.exports = add_Data '''
    coffee_Data_2   = '''add_Data = (data,callback)->
                           data.addMapping('g1','b1','c1')
                           callback()
                         module.exports = add_Data '''
    dot_Data_1      = '''graph graphname {
                                            a2 -- b2 -- c2;
                                            b2 -- d2;
                                          }'''
    dot_Data_2      = '''{ d2 -- e3 }'''

    before ->
      expect(dbService.load_Data  ).to.be.an("function")

    afterEach (done)->
      file.file_Delete() for file in  path_Data.files()
      expect(path_Data.files()).to.be.empty
      dbService.graphService.deleteDb ->
        done()

    after ->
      expect(dbService.path_Name.folder_Delete_Recursive()).to.be.true

    it 'load_Data (json)', (done)->
      json_Data_1.saveAs(json_File_1)
      json_Data_2.saveAs(json_File_2)
      expect(path_Data.files().size()).to.equal(2)
      dbService.load_Data ->
        dbService.graphService.allData (data)->
          expect(data).to.not.be.empty
          expect(data.length).to.equal(4)
          done()

    it 'load_Data (coffee)', (done)->
      coffee_Data_1.saveAs(coffee_File_1)
      coffee_Data_2.saveAs(coffee_File_2)
      expect(path_Data.files().size()).to.equal(2)
      dbService.load_Data ->
        dbService.graphService.allData (data)->
          expect(data).to.not.be.empty
          expect(data.length).to.equal(3)
          done()

    it 'load_Data (dot)', (done)->
      dot_Data_1.saveAs(dot_File_1)
      dot_Data_2.saveAs(dot_File_2)
      expect(path_Data.files().size()).to.equal(2)

      dbService.load_Data ->
        dbService.graphService.allData (data)->
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

      dbService.load_Data ->
        dbService.graphService.allData (data)->
          expect(data).to.not.be.empty
          expect(data.length).to.equal(11)
          done()
