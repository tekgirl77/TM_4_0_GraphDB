async             = require 'async'
Import_Service    = require '/src/services/Import-Service'.append_To_Process_Cwd_Path()

get_Graph = (graphService, callback)->
  importService     = new Import_Service('tm-uno')
  importService.db.setup()
  importService.graph = graphService

  graph = importService.new_Vis_Graph()
  graph.options._smoothCurves(false)
  graph.options.nodes.box()._mass(1)
  graph.options.edges.arrow()


  import_Folder = (folder_Id, next)->
      #console.log folder_Id
    #importService.find_Using_Is_and_Title 'Folder','Communication Security',(folder_Id)->
      importService.get_Subject_Data folder_Id, (folder)->
          importService.get_Subjects_Data folder.contains, (view_Data)->
            folder_Node =  graph.add_Node(folder_Id, folder.title)._color('#aabbcc')#._mass(6)

            for view_id in view_Data.keys()
              folder_Node.add_Edge(view_id,'view')
              view_Node = graph.node(view_id)
              view_Node.label = view_Data[view_id].title

              if (view_Data[view_id].contains)
          #    console.log '-------' + typeof(view_Data[view_id].contains)
          #    if typeof(view_Data[view_id].contains)=='string'
          #      article_Id = view_Data[view_id].contains
          #      view_Node.add_Edge(article_Id)
          #      article_Node = graph.node(article_Id)
          #      article_Node.dot().red().label =''
          #    else
                  for article_Id in view_Data[view_id].contains
                    view_Node.add_Edge(article_Id)
                    article_Node = graph.node(article_Id)
                    article_Node.dot().black().label =''

            next()

  importService.find_Using_Is 'Folder', (folder_Ids)->
    #console.log folder_Ids.first()
    #folder_Ids = folder_Ids.slice(5,10)
    async.each folder_Ids, import_Folder, -> callback(graph)



module.exports = get_Graph