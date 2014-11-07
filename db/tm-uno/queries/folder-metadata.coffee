async             = require 'async'
Import_Service    = require '/src/services/Import-Service'.append_To_Process_Cwd_Path()


get_Graph = (graphService, params, callback)->

  importService     = new Import_Service('tm-uno')
  importService.db.setup()
  importService.graph = graphService

  graph = importService.new_Vis_Graph()
  graph.options.nodes.box()#._mass(2)
  graph.options.edges.arrow().widthSelectionMultiplier = 5

  category_Node   = graph.add_Node('Category'  ).circle().black()._mass(5)
  phase_Node      = graph.add_Node('Phase'     ).circle().black()._mass(5)
  technology_Node = graph.add_Node('Technology').circle().black()._mass(5)
  type_Node       = graph.add_Node('Type'      ).circle().black()._mass(5)

  #console.log "params: #{params}"

  map_Article = (article_Id, parent, next)->
    importService.get_Subject_Data article_Id, (article_Data)->
      importService.teamMentor.article article_Data.guid, (article)->
        if not article or not article.Metadata
          next()
          return
        id         = article.Metadata.Id
        title      = article.Metadata.Title
        category   = article.Metadata.Category
        phase      = article.Metadata.Phase
        technology = article.Metadata.Technology
        type       = article.Metadata.Type

        graph.add_Edge('Category'   , category  )
        graph.add_Edge('Phase'      , phase     )
        graph.add_Edge('Technology' , technology)
        graph.add_Edge('Type'       , type      )

        format_Node = (node)->
          node.circle()._label('A').set('guid', id).set('title', title)._color('lightGray')

        format_Edge_To_Node = (edge)->
          format_Node(edge.to_Node())

        #map to global metadata nodes
        format_Edge_To_Node graph.add_Edge category
        format_Edge_To_Node graph.add_Edge phase
        format_Edge_To_Node graph.add_Edge technology
        format_Edge_To_Node graph.add_Edge type

        #map to view (i.e. parent) metadata nodes
        add_Article_To_Metadata = (nodeKey,edgeKey, labelText)->
          graph.node(nodeKey).add_Edge(edgeKey).to_Node()._label(labelText)
                             .add_Edge().to_Node().call_Function(format_Node)


        add_Article_To_Metadata("#{parent}_Category"  , "#{parent}_#{category}"  , category)
        add_Article_To_Metadata("#{parent}_Phase"     , "#{parent}_#{phase}"     , phase)
        add_Article_To_Metadata("#{parent}_Technology", "#{parent}_#{technology}", technology)
        add_Article_To_Metadata("#{parent}_Type"      , "#{parent}_#{type}"      , type)

        #graph.node("#{parent}_Technology").add_Edge("#{parent}_#{technology}")

        next()


  map_Articles_Using_Title=  (title,next)->
    importService.find_Using_Is_and_Title 'Article', title, (article_Ids)->
      async.each article_Ids, map_Article, next

  map_Articles_In_View =  (view_Id,parent,next)->
    importService.get_Subject_Data view_Id, (view_Data)->
      view_Node = graph.add_Node(view_Id, 'view: ' + view_Data.title)._color('#aabbcc')._mass(5)
      view_Node.add_Edge("#{view_Id}_Category"  ).to_Node()._label('C')._title('Category'  ).circle().black()._mass(5)
      view_Node.add_Edge("#{view_Id}_Phase"     ).to_Node()._label('P')._title('Phase'     ).circle().black()._mass(5)
      view_Node.add_Edge("#{view_Id}_Technology").to_Node()._label('T')._title('Technology').circle().black()._mass(5)
      view_Node.add_Edge("#{view_Id}_Type"      ).to_Node()._label('T')._title('Type'      ).circle().black()._mass(5)

      graph.add_Edge(parent, view_Id)
      if (view_Data.contains)
        async.each view_Data.contains, ((item, next)-> map_Article(item,view_Id,next)), next
      else
        next()

  map_Articles_In_Folder = (folder_Id, next)->
    importService.get_Subject_Data folder_Id, (folder_Data)->
      graph.add_Node(folder_Id, 'folder: ' + folder_Data.title)._color('orange')._fontSize(30)._mass(3)
      if (folder_Data.contains)
        async.each folder_Data.contains, ((item, next)-> map_Articles_In_View(item,folder_Id,next)), next
      else
        next()

  folder_Name = 'Authorization'
  if (params && params.show)
    folder_Name = params.show

  importService.find_Using_Is_and_Title 'Folder', folder_Name, (folder_Ids)->
    folder_Id = folder_Ids.first()
    map_Articles_In_Folder folder_Id , ->
      #"\nMapped #{graph.nodes.size()} nodes and #{graph.edges.size()} edges".log()
      callback(graph)

  #importService.find_Using_Is 'Folder', (folder_Ids)->
  #folder_Id = folder_Ids[2]

module.exports = get_Graph