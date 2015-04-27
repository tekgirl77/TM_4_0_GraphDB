loaded_Raw_Articles_Html      = null

class Article

  folder_Search_Data: ()=>
    __dirname.path_Combine "../../.tmCache/Lib_UNO-json/Search_Data"

  html: (article_id,callback)=>
    console.log "getting html for:" + article_id
    @.raw_Articles_Html (raw_Articles_Html)->
      callback raw_Articles_Html[article_id]?.html

  raw_Articles_Html: (callback)=>
    if loaded_Raw_Articles_Html
      return callback loaded_Raw_Articles_Html

    key = @.folder_Search_Data().path_Combine 'raw_articles_html.json'

    if key.file_Exists()
      articles_Data  = key.load_Json()
      loaded_Raw_Articles_Html = {}
      for article_Data in articles_Data
        loaded_Raw_Articles_Html[article_Data.id] = article_Data
      return callback loaded_Raw_Articles_Html
    callback {}

module.exports = Article