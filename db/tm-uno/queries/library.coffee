async             = require 'async'
Import_Service    = require '/src/services/Import-Service'.append_To_Process_Cwd_Path()


get_Graph = (graphService, params, callback)->

  importService = new Import_Service('tm-uno')
  importService.db.setup()
  importService.graph = graphService
  graph = importService.new_Vis_Graph()
  graph.options = { physics: {
                                barnesHut: {
                                  enabled: true,
                                  gravitationalConstant: -2000,
                                  centralGravity: 0.1,
                                  springLength: 195,
                                  springConstant: 0.04,
                                  damping: 0.09
                                }
                              }}

  create_Library_and_Folder_Graph = (library_Id, library_Name, folders_Data)->
    library_Node = graph.add_Node(library_Id, library_Name).box()._color('#aabbcc')
    for folder_Id in folders_Data.keys()
      folder_Data = folders_Data[folder_Id]
      folder_Title = folder_Data.title
      node_ToolTip = "#{folder_Title}<br><a href='/data/tm-uno/folder-metadata/graph-with-viewer?show=#{folder_Title}' target='_blank'>open folder view</a>"
      library_Node.add_Edge(folder_Id).to_Node()._label(folder_Title).box()._mass(2)
                  ._title(node_ToolTip)


    callback(graph)

  getLibraryData = (target_Library)->

    importService.find_Using_Is_and_Title 'Library', target_Library, (library_Ids)->
      library_Id = library_Ids.first()
      importService.find_Subject_Contains library_Id, (folders_Ids)->
        importService.get_Subjects_Data folders_Ids, (folders_Data)->
          create_Library_and_Folder_Graph(library_Id, target_Library, folders_Data)

  getLibraryData('UNO')

module.exports = get_Graph