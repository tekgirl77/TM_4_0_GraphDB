async             = require 'async'

size_Views = -1
size_Articles = -1

format_Article_Node = (node, id, title, summary)->
  node.circle()._label('A')
               .set('guid', id)
               .set('title', title)
               .set('summary', summary)
               ._color('lightGray')

get_Graph = (options, callback)->

  importService = options.importService
  params        = options.params
  graph         = importService.new_Vis_Graph()
  db            = importService.graph.db
  folder_Ids    = null
  contains      = null
  subjects_Data = null

  graph.options.nodes.box()#._mass(2)
  graph.options.edges.arrow().widthSelectionMultiplier = 5

  metadata_Nodes =
                    category   : graph.add_Node('Category'  ).circle().black()._mass(5)
                    phase      : graph.add_Node('Phase'     ).circle().black()._mass(5)
                    technology : graph.add_Node('Technology').circle().black()._mass(5)
                    type       : graph.add_Node('Type'      ).circle().black()._mass(5)

  #articles_Node   = graph.add_Node('Articles'      ).circle().black()._mass(5)

  loadData =  (queryTitle, next)=>
    db.get {predicate:'title'}, (error, titles)->
      db.get {predicate:'contains'}, (error, data)->
        contains = data
        folder_Ids    = (title.subject for title in titles when title.object == queryTitle)
        view_Ids     = (contain.object for contain in contains when folder_Ids.contains(contain.subject))
        article_Ids  = (contain.object for contain in contains when view_Ids.contains(contain.subject))
        subjects_Ids = article_Ids.concat(folder_Ids).concat(view_Ids)
        importService.get_Subjects_Data subjects_Ids, (data)->
          subjects_Data = data
          next()

  map_Data = (next) =>
    for folder_Id in folder_Ids
      view_Ids     = (contain.object for contain in contains when contain.subject == folder_Id).take(size_Views)
      folder_Data = subjects_Data[folder_Id]
      folder_Node = graph.add_Node(folder_Id, folder_Data.title)._color('orange')._fontSize(30)._mass(3)
      for view_Id in view_Ids
        view_Data = subjects_Data[view_Id]
        view_Node = graph.add_Node(view_Id, view_Data.title)._color('#aabbcc')._mass(5)
        graph.add_Edge(folder_Id, view_Id)
        graph.add_Edge(view_Id, "#{view_Id}_Category"  ).to_Node()._label('C')._title('Category'  ).circle().black()._mass(5)
        graph.add_Edge(view_Id, "#{view_Id}_Phase"     ).to_Node()._label('C')._title('Phase'     ).circle().black()._mass(5)
        graph.add_Edge(view_Id, "#{view_Id}_Technology").to_Node()._label('C')._title('Technology').circle().black()._mass(5)
        graph.add_Edge(view_Id, "#{view_Id}_Type"      ).to_Node()._label('C')._title('Type'      ).circle().black()._mass(5)

        article_Ids  = (contain.object for contain in contains when contain.subject == view_Id).take(size_Articles)
        for article_Id in article_Ids
          article_Data = subjects_Data[article_Id]
        # graph.add_Edge(folder_Id, view_Id,'folder')
        # graph.add_Edge(view_Id, article_Id,'view')
        # graph.add_Edge(article_Id,article_Data.category  , 'category')
        # graph.add_Edge(article_Id,article_Data.phase     , 'phase')
        # graph.add_Edge(article_Id,article_Data.technology, 'technology')
        # graph.add_Edge(article_Id,article_Data.type      , 'type')

          add_Metatada = (names)=>
            for name in names
              metadata_Nodes[name].add_Edge(name + '_'+article_Data[name]).to_Node()._label(article_Data[name])
                                  .add_Edge().to_Node().call_Function(format_Article_Node, article_Id,article_Data.title, 'subject for : ' + article_Data.title)

          add_Metatada(['category','phase','technology','type'])


          add_Article_To_Metadata = (nodeKey,edgeKey, labelText)->
            graph.node(nodeKey).add_Edge(edgeKey).to_Node()._label(labelText)
                               .add_Edge().to_Node().call_Function(format_Article_Node, article_Id,article_Data.title, 'subject for : ' + article_Data.title)

          #view_Node.add_Edge().to_Node().call_Function(format_Article_Node, article_Id,article_Data.title, 'subject for : ' + article_Data.title)

          add_Article_To_Metadata("#{view_Id}_Category"  , "#{view_Id}_#{article_Data.category}"  , article_Data.category)
          add_Article_To_Metadata("#{view_Id}_Phase"     , "#{view_Id}_#{article_Data.phase}"     , article_Data.phase)
          add_Article_To_Metadata("#{view_Id}_Technology", "#{view_Id}_#{article_Data.technology}", subjects_Data[article_Data.technology])
          add_Article_To_Metadata("#{view_Id}_Type"      , "#{view_Id}_#{article_Data.type}"      , article_Data.type)

          #console.log article_Data
          #console.log(@[name+'_Node'])
    next()



  loadData 'Data Validation', ->
    map_Data ->
      callback(graph)

      # for folder_Id in folder_Ids
      #   "here".log()
      #   view_Ids     = (contain.object for contain in contains when contain.subject == folder_Id)
      #   for view_Id in view_Ids
      #     article_Ids  = (contain.object for contain in contains when contain.subject == view_Id)
      #     for article_Id in article_Ids
      #       importService.get_Subject_Data article_Id, (data)->
      #         console.log data
      #         phase     = (phase.object for phase in phases when phase.subject == article_Id).first()
      #         graph.add_Edge(folder_Id, view_Id)
      #         graph.add_Edge(view_Id, article_Id)
      #         graph.add_Edge(article_Id, phase,"phase")




module.exports = get_Graph