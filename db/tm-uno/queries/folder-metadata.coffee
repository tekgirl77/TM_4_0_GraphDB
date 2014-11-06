async             = require 'async'
Import_Service    = require '/src/services/Import-Service'.append_To_Process_Cwd_Path()


get_Graph = (graphService, callback)->
  importService     = new Import_Service('tm-uno')
  importService.db.setup()
  importService.graph = graphService

  graph = importService.new_Vis_Graph()
  graph.options.nodes.box()#._mass(30)
  graph.options.edges.arrow().widthSelectionMultiplier = 5
  #graph.options.edges

  category_Node   = graph.add_Node('Category'  ).circle().black()._mass(25)
  phase_Node      = graph.add_Node('Phase'     ).circle().black()._mass(25)
  technology_Node = graph.add_Node('Technology').circle().black()._mass(25)
  type_Node       = graph.add_Node('Type'      ).circle().black()._mass(25)

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
        article_Node = graph.add_Node(article_Id, ' ')
        if (not article_Node)
          "already existed: #{article_Id}".log()
          article_Node = graph.node(article_Id)
        article_Node.dot()._color('#aabbcc')
        article_Node.guid = id
        article_Node.title = "#{title} <br><a href='https://tmdev01-sme.teammentor.net/#{id}' target='_blank'>open article</a>"
        graph.add_Edge(category_Node.id   , category  )
        graph.add_Edge(category           , article_Id)
        graph.add_Edge(phase_Node.id      , phase     )
        graph.add_Edge(phase              , article_Id)
        graph.add_Edge(technology_Node.id , technology)
        graph.add_Edge(technology         , article_Id)
        graph.add_Edge(type_Node.id       , type      )
        graph.add_Edge(type               , article_Id)
        next()


  map_Articles_Using_Title=  (title,next)->
    importService.find_Using_Is_and_Title 'Article', title, (article_Ids)->
      async.each article_Ids, map_Article, next

  map_Articles_In_View =  (view_Id,parent,next)->
    importService.get_Subject_Data view_Id, (view_Data)->
      graph.add_Node(view_Id, 'view: ' + view_Data.title)#._color('#aabbcc')
      #     .title = "<a href='https://tmdev01-sme.teammentor.net/#{view_Id}' target='_blank'>view just this view</a>"
      graph.add_Edge(parent, view_Id)
      if (view_Data.contains)
        async.each view_Data.contains, ((item, next)-> map_Article(item,view_Id,next)), next
      else
        next()


    #importService.find_Using_Is_and_Title 'Article', title, (article_Ids)->
    #  async.each article_Ids, map_Article, next

  map_Articles_In_Folder = (folder_Id, next)->
    importService.get_Subject_Data folder_Id, (folder_Data)->
      graph.add_Node(folder_Id, 'folder: ' + folder_Data.title).green()
      if (folder_Data.contains)
        async.each folder_Data.contains, ((item, next)-> map_Articles_In_View(item,folder_Id,next)), next
      else
        next()


  #importService.find_Using_Is 'View', (view_Ids)->
  #  view_Id = view_Ids[4]
  #  map_Articles_In_View view_Id , ->
  importService.find_Using_Is 'Folder', (folder_Ids)->
    folder_Id = folder_Ids[9]
    map_Articles_In_Folder folder_Id , ->
      "\nMapped #{graph.nodes.size()} nodes and #{graph.edges.size()} edges".log()
      callback(graph)

module.exports = get_Graph