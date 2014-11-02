expect         = require('chai'         ).expect
Data_Service   = require('./../../src/services/Data-Service')
Graph_Service  = require('./../../src/services/Graph-Service')

describe 'services | test-Data-Service |', ->
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
      expect(dataService.path_Root    ).to.equal  ('db'             )
      expect(dataService.path_Name    ).to.equal  ('db/test'        )
      expect(dataService.path_Data    ).to.equal  ('db/test/data'   )
      expect(dataService.path_Queries ).to.equal  ('db/test/queries')

      expect(dataService.graphService       ).to.be.instanceof(Graph_Service)
      expect(dataService.graphService.dbName).to.equal('test')

      dataService  = new Data_Service('aaaa')
      expect(dataService.name               ).to.equal('aaaa'           )
      expect(dataService.path_Name          ).to.equal('db/aaaa'        )
      expect(dataService.path_Data          ).to.equal('db/aaaa/data'   )
      expect(dataService.path_Queries       ).to.equal('db/aaaa/queries')
      expect(dataService.graphService.dbName).to.equal('aaaa'           )

      expect(dataService.path_Name.folder_Delete_Recursive()).to.be.true


    it 'data_Files',->
      dataService  = new Data_Service().setup()
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
      test_File = dataService.path_Queries.path_Combine("testQuery.json")
      expect(test_Data.saveAs(test_File)) .to.be.true
      expect(dataService.query_Files()  ).to.be.not.empty
      expect(dataService.query_Files()  ).to.deep.contain(test_File.realPath())
      expect(test_File.file_Delete()    ).to.be.true
      expect(dataService.query_Files()  ).to.deep.not.contain(test_File.realPath())

    it 'run_Query', (done)->
      dataService  = new Data_Service()
      expect(dataService.run_Query  ).to.be.an("function")

      query_Name = 'testQuery'
      coffee_Query = '''get_Graph = (graphService, callback)->
                          graph = { nodes: [{'a','b'}] , edges: [{from:'a' , to: 'b'}] }
                          callback(graph)
                        module.exports = get_Graph '''
      coffee_File = dataService.path_Queries.path_Combine("#{query_Name}.coffee")
      expect(coffee_Query.saveAs(coffee_File)) .to.be.true

      dataService.run_Query query_Name, (graph)->
        expect(graph).to.not.be.null
        expect(graph      ).to.be.an('object')
        expect(graph.nodes).to.be.an('array')
        expect(graph.edges).to.be.an('array')
        expect(graph.nodes.first()).to.deep.equal({'a','b'})
        expect(graph.edges.first()).to.deep.equal({from:'a' , to: 'b'})
        done()

  #expect(dataService.query_Files()   ).to.be.not.empty

      #console.log(dataService)

  describe 'load data |', ->

    dataService   = new Data_Service().setup()
    path_Data     = dataService.path_Data

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
      expect(dataService.load_Data  ).to.be.an("function")

    afterEach (done)->
      file.file_Delete() for file in  path_Data.files()
      expect(path_Data.files()).to.be.empty
      dataService.graphService.deleteDb ->
        done()

    after ->
      expect(dataService.path_Name.folder_Delete_Recursive()).to.be.true

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
