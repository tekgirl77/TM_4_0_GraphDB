addData = (dataUtil)->
  dataUtil.addMappings "keyword_00000762fc3e",  [ { title     : "SQL Injection"                  },
    { is        : "Search"                           },
    { contains  : "queries-00002762fc3e"             },
    { contains  : "articles-00002762fc3e"            },
    { contains  : "metadatas-00002762fc3e"           }]

  dataUtil.addMappings "queries-00002762fc3e",  [ { title     : "Queries"                          },
    { is        : "Queries"                          },
    { contains  : "query-10002762fc3e"               },
    { contains  : "query-20002762fc3e"               },
    { contains  : "query-30002762fc3e"               }]

  dataUtil.addMappings "articles-00002762fc3e",   { is: "Articles" , title: "Articles"  , contains  : ['article-d5bc580df781'
                                                                                                       'article-e7ed2762fc3e'
                                                                                                       'article-9771b8ed3eda'
                                                                                                       'article-1106d793193b'
                                                                                                       'article-3e15eef3a23c'
                                                                                                       'article-9f8b44a5b27d'
                                                                                                       'article-46d6939abe45']}


  # Query
  dataUtil.addMappings "query-10002762fc3e"  ,  { is: "Query",   title: "Perform SQL Validation on the Server", xref: ['xref-31002762fc3e'
                                                                                                                       'xref-32002762fc3e'
                                                                                                                       'xref-33002762fc3e'
                                                                                                                       'xref-34002762fc3e'
                                                                                                                       'xref-35002762fc3e'
                                                                                                                       'xref-36002762fc3e'
                                                                                                                       'xref-37002762fc3e']}
  dataUtil.addMappings "query-20002762fc3e"  ,  { is: "Query",   title: "Validate SQL Input"              , xref: ['xref-38002762fc3e'
                                                                                                                   'xref-39002762fc3e'
                                                                                                                   'xref-41002762fc3e']}

  dataUtil.addMappings "query-30002762fc3e"  ,  { is: "Query",   title: "Use White-list Validation for SQL"       , xref: ['xref-42002762fc3e'
                                                                                                                           'xref-43002762fc3e'
                                                                                                                           'xref-44002762fc3e'
                                                                                                                           'xref-45002762fc3e']}
module.exports = addData