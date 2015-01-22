async             = require 'async'
cheerio           = require 'cheerio'


get_Graph = (options, callback)->

  importService = options.importService
  params        = options.params

  graph         = importService.new_Vis_Graph()

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
        html       = article.Content.Data_Json
        summary    = ""
        if (article.Content.DataType.lower() is 'html')
          $          = cheerio.load(html.substring(0,400))
          summary    = $('p').text().substring(0,200).trim()
        else
          summary = html.substring(0,200).replace(/\*/g,'').replace(/\=/g,'')
        graph.add_Edge('Category'   , category  )
        graph.add_Edge('Phase'      , phase     )
        graph.add_Edge('Technology' , technology)
        graph.add_Edge('Type'       , type      )

        format_Node = (node)->
          node.circle()._label('A')
                       .set('guid', id)
                       .set('title', title)
                       .set('summary', summary)
                       ._color('lightGray')

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
    #"mapping view: #{view_Id}".log()
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
    #"mapping folder: #{folder_Id}".log()
    importService.get_Subject_Data folder_Id, (folder_Data)->
      graph.add_Node(folder_Id, 'folder: ' + folder_Data.title)._color('orange')._fontSize(30)._mass(3)
      if (folder_Data.contains)
        view_Ids =  if typeof(folder_Data.contains) != 'string' then folder_Data.contains else [folder_Data.contains]
        async.each view_Ids, ((item, next)-> map_Articles_In_View(item,folder_Id,next)), next
      else
        next()

  map_Folder = (folder_Id)=>
    map_Articles_In_Folder folder_Id , ->
      #"\nMapped #{graph.nodes.size()} nodes and #{graph.edges.size()} edges".log()
      callback(graph)

  if (params && params.show)
    folder_Name = params.show
    importService.find_Using_Is_and_Title 'Folder', folder_Name, (folder_Ids)->
      #console.log folder_Ids
      map_Folder folder_Ids.first()
  else
    importService.find_Using_Is  'Folder', (folder_Ids)->
      map_Folder folder_Ids.first()

  #importService.find_Using_Is 'Folder', (folder_Ids)->
  #folder_Id = folder_Ids[2]

module.exports = get_Graph