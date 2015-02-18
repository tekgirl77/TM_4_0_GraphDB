expect         = require('chai'         ).expect

Dot_Service   = require('./../../../src/services/import/Dot-Service')

describe '| services | import | test-Dot-Service |', ->

  dotService  = new Dot_Service()

  it 'check ctor',->
    Dot_Service.assert_Is_Function()
    using dotService, ->
      @                  .assert_Is_Object()
      @.dot              .assert_Is_Object()
      @.dot_To_Graph     .assert_Is_Function()
      @.dot_To_Triplets  .assert_Is_Function()
      @.graph_To_Triplets.assert_Is_Function()

  it 'dot_To_Graph (simple)', (done)->

    # using code sample from http://en.wikipedia.org/wiki/DOT_(graph_description_language)#Undirected_graphs

    dot_String = '''graph graphname {
                                       a -- b -- c;
                                       b -- d;
                                    }'''

    expected_graph =
                     type: 'graph'
                     id: 'graphname'
                     nodes: [ { id: 'a' }, { id: 'b' }, { id: 'c' }, { id: 'd' } ]
                     edges:
                       [ { from: 'a', to: 'b', type: '--', attr: {} },
                         { from: 'b', to: 'c', type: '--', attr: {} },
                         { from: 'b', to: 'd', type: '--', attr: {} } ]


    dotService.dot_To_Graph dot_String, (graph)->
      expect(graph).to.be.an('object')
      expect(graph).to.deep.equal(expected_graph)
      done();

  it 'dot_To_Triplets' , (done)->
    dot_String        = '''{ a -- b -- c}'''
    expected_Triplets =  [{ subject: 'a', predicate: '--', object: 'b' }
                          { subject: 'b', predicate: '--', object: 'c' } ]

    dotService.dot_To_Triplets dot_String, (triplets)->
      expect(triplets).to.deep.equal(expected_Triplets)
      done()

  it 'graph_To_Triplets' , (done)->
    dot_String = '''graph graphname { a -- b -- c; b -- d; }'''
    expected_Triplets = [ { subject: 'a', predicate: '--', object: 'b' },
                          { subject: 'b', predicate: '--', object: 'c' },
                          { subject: 'b', predicate: '--', object: 'd' } ]

    dotService.dot_To_Graph dot_String, (graph)->
      dotService.graph_To_Triplets graph, (triplets)->
        expect(triplets).to.deep.equal(expected_Triplets)
        done()


  it 'dot_To_Graph (advanced)', (done)->

    # using code sample from https://github.com/almende/vis/blob/1b32004b624dcf13abe819d5a3344bdb9706e804/test/dotparser.test.js

    dot_String = '''digraph test_graph {
                    # this test file tries to test everything from the DOT language
                    rankdir=LR;
                    size="8,5"
                    font = "arial"
                    graph[attr1="another"" attr"]
                    node [shape = doublecircle]; node1 node2 node3;
                    node [shape = circle];
                    edge[length=170 fontSize=12]
                    node4[color=red shape=diamond]
                    node5[color="blue", shape=square, width=3]

                    /*
                          some block comment
                      */
                    "node1" -> node1 [ label = "a" ];
                    "node2" -> node3 [label = "b" ];
                    "node1" -- "node4" [ label = "c" ];
                    node3-> node4 [ label=d] -> node5 -> 6

                    A -> {B C}
                  }'''
    expected_graph =
                      "type"     : "digraph"
                      "id"       : "test_graph"
                      "rankdir"  : "LR"
                      "size"     : "8,5"
                      "font"     : "arial"
                      "nodes"    : [ { "id": "node1", "attr": { "shape": "doublecircle"                         } }
                                     { "id": "node2", "attr": { "shape": "doublecircle"                         } }
                                     { "id": "node3", "attr": { "shape": "doublecircle"                         } }
                                     { "id": "node4", "attr": { "shape": "diamond", "color": "red"              } }
                                     { "id": "node5", "attr": { "shape": "square" , "color": "blue", "width": 3 } }
                                     { "id": 6      , "attr": { "shape": "circle"                               } }
                                     { "id": "A"    , "attr": { "shape": "circle"                               } }
                                     { "id": "B"    , "attr": { "shape": "circle"                               } }
                                     { "id": "C"    , "attr": { "shape": "circle"                               } }
                                   ]
                      "edges"    : [
                                     { "from": "node1", "to": "node1", "type": "->", "attr": { "length": 170, "fontSize": 12, "label": "a" } }
                                     { "from": "node2", "to": "node3", "type": "->", "attr": { "length": 170, "fontSize": 12, "label": "b" } }
                                     { "from": "node1", "to": "node4", "type": "--", "attr": { "length": 170, "fontSize": 12, "label": "c" } }
                                     { "from": "node3", "to": "node4", "type": "->", "attr": { "length": 170, "fontSize": 12, "label": "d" } }
                                     { "from": "node4", "to": "node5", "type": "->", "attr": { "length": 170, "fontSize": 12,              } }
                                     { "from": "node5", "to": 6      , "type": "->", "attr": { "length": 170, "fontSize": 12,              } }
                                     { "from": "A"    , "to": { "nodes": [
                                                                           { "id": "B", "attr": { "shape": "circle" } },
                                                                           { "id": "C", "attr": { "shape": "circle" } }
                                                                         ] }
                                                                     , "type": "->", "attr": { "length": 170,"fontSize": 12                } }
                                   ]
                      "subgraphs": [ { "nodes": [ { "id": "B", "attr": { "shape": "circle" } }
                                                  { "id": "C", "attr": { "shape": "circle" } } ] } ]


    dotService.dot_To_Graph dot_String, (graph)->
      expect(graph).to.be.an('object')
      expect(graph).to.deep.equal(expected_graph)
      done();
