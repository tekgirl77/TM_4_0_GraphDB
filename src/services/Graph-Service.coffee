
levelgraph      = require('levelgraph'   )
GitHub_Service  = require('./GitHub-Service')

class GraphService
  constructor: (dbName)->
    @dbName     = if  dbName then dbName else '_tmp_db'.add_Random_String(5)
    @dbPath     = "./.tmCache/#{@dbName}"
    @db         = null

  #Setup methods

  openDb : (callback)=>
    @db         = levelgraph(@dbPath)
    callback() if callback
    return @db

  closeDb: (callback)=>
    @db.close =>
      @db    = null
      @level = null
      callback()

  deleteDb: (callback)=>
    @closeDb =>
      @dbPath.folder_Delete_Recursive()
      callback();

  add: (subject, predicate, object, callback)=>
    @db.put([{ subject:subject , predicate:predicate  , object:object }], callback)

  get_Subject: (subject, callback)->
    @db.get {subject:subject}, (err,data)->callback(data)

  get_Predicate: (predicate, callback)->
    @db.get {predicate:predicate}, (err,data)->callback(data)

  get_Object: (object, callback)->
    @db.get {object:object}, (err,data)->callback(data)


#  dataFromGitHub: (callback)->
#    user   = "TMContent"
#    repo   = "TM_Test_GraphData"
#    path   = 'GraphData/article_Data.json'
#    new GitHub_Service().file user, repo, path, (data)-> callback(JSON.parse(data))

  # Load from disk
#  loadTestData: (callback) =>
#    if (@db==null)
#      @openDb()
#    @dataFromGitHub (data)=>
#      @data = data
#      @db.put @data, callback

  # Search methods

  allData: (callback)=>
    @db.search [{
      subject  : @db.v("subject"),
      predicate: @db.v("predicate"),
      object   : @db.v("object"),
    }], (err, data)->callback(data)

  query: (key, value, callback)->
    switch key
      when "subject"      then @db.get { subject: value}  , (err, data) -> callback(data)
      when "predicate"    then @db.get { predicate: value}, (err, data) -> callback(data)
      when "object"       then @db.get { object: value}   , (err, data) -> callback(data)
      else callback(null,[])


  #graphDataFromQAServer: (callback)->
  #  graphDataUrl = 'http://levelgraph-test.herokuapp.com/graphData.json'
  #  require('request').get graphDataUrl, (err,response,body)->
  #    throw err if err
  #    callback JSON.parse(body)

  #  mapNodesFromGraphData: (graphData, callback) ->
  #      nodes_by_Id = {}
  #      nodes_by_Is = {}
  #      for node in graphData.nodes
  #          nodes_by_Id[node.id]= { text: node.label, edges: {}}
  #
  #      for edge in graphData.edges
  #          edges = nodes_by_Id[edge.from].edges
  #          edges[edge.label] = [] if edges[edge.label] is undefined
  #          edges[edge.label].push(edge.to)
  #
  #          if (edge.label =='is')
  #              nodes_by_Is[edge.to] = [] if nodes_by_Is[edge.to] is undefined
  #              nodes_by_Is[edge.to].push(edge.from)
  #
  #      nodes = {nodes_by_Id:nodes_by_Id, nodes_by_Is:nodes_by_Is }
  #      callback(nodes)

#  createSearchDataFromGraphData: (graphData,filter_container, filter_query, callback)->
#
#    searchData              = {}
#
#    setDefaultValues = ->
#      searchData.title        = ''
#      searchData.containers   = []
#      searchData.resultsTitle = ""
#      searchData.results      = []
#      searchData.filters      = []
#      searchData.filter_container = if (filter_container) then filter_container else ''
#      searchData.filter_query     = if (filter_query) then filter_query else ''
#
#    metadata = {}
#    setDefaultValues()
#
#    article_Ids = graphData.nodes_by_Id[graphData.nodes_by_Is["Articles"]].edges.contains
#    maxArticles = article_Ids.length
#    mapArticles = (nodes) =>
#      searchData.title        = nodes.nodes_by_Id[nodes.nodes_by_Is["Search"]].text
#
#      searchData.resultsTitle = "#{article_Ids.length}/#{maxArticles} results showing"
#      for article_Id in article_Ids
#        result = { title: null, link: null , id: null, summary: null, score : null }
#        article_Node = nodes.nodes_by_Id[article_Id]
#        result.title   = article_Node.edges.title
#        result.summary = article_Node.edges.summary
#        result.guid     = article_Node.edges.guid
#        result.id       = article_Id
#        searchData.results.push(result)
#
#      callback(searchData)
#
#    mapMetadata = (nodes) =>
#      query_Ids = nodes.nodes_by_Id[nodes.nodes_by_Is["Metadatas"]].edges.contains
#      for query_Id in query_Ids
#        query_Node = nodes.nodes_by_Id[query_Id]
#        filter = {}
#        filter.title   = query_Node.text
#        filter.results = []
#        for metadata_Id in query_Node.edges.contains
#          metadata_Node = nodes.nodes_by_Id[metadata_Id]
#          result = { title : metadata_Node.text ,id: metadata_Id, size: metadata_Node.edges.xref.length}
#          filter.results.push(result)
#          if (filter_query== metadata_Id)
#            article_Ids = []
#            for xref_Id in metadata_Node.edges.xref
#              xref_Article = nodes.nodes_by_Id[xref_Id]
#              article_Id   = xref_Article.edges.target
#              article_Ids.push(article_Id)
#
#        searchData.filters.push(filter)
#
#      mapArticles(nodes)
#
#    mapContainers = (nodes) =>
#      queries_Ids = nodes.nodes_by_Id[nodes.nodes_by_Is["Queries"]].edges.contains
#      for queries_Id in queries_Ids
#        query_Node = nodes.nodes_by_Id[queries_Id]
#        container = { title: query_Node.text, id: queries_Id, size : query_Node.edges.xref.length }
#        if (filter_container== queries_Id)
#          article_Ids = []
#          for xref_Id in query_Node.edges.xref
#            xref_Article = nodes.nodes_by_Id[xref_Id]
#            article_Id   = xref_Article.edges.target
#            article_Ids.push(article_Id)
#
#
#        searchData.containers.push(container)
#      mapMetadata(nodes)
#
#    mapContainers graphData,

module.exports = GraphService