addData = (dataUtil)->
  # Metadata
  dataUtil.addMappings "metadatas-00002762fc3e", { is: 'Metadatas', title: 'Metadatas'                  , contains: ['query-00102762fc3e'
                                                                                                                     'query-00202762fc3e'
                                                                                                                     'query-00302762fc3e'
                                                                                                                     'query-00402762fc3e'    ]}


  # Technology (Metadata)
  dataUtil.addMappings "query-00102762fc3e"    , { is: 'Query'    , title: 'Technology'                 , contains: ['metadata-00002762fc3e'
                                                                                                                     'metadata-10002762fc3e'
                                                                                                                     'metadata-20002762fc3e'
                                                                                                                     'metadata-30002762fc3e'
                                                                                                                     'metadata-70002762fc3e'
                                                                                                                     'metadata-11002762fc3e'
                                                                                                                     'metadata-13002762fc3e']}

  dataUtil.addMappings "metadata-00002762fc3e" , { is: 'Metadata' , title : 'C++'                       , xref    : ['xref-13002762fc3e']}
  dataUtil.addMappings "metadata-10002762fc3e" , { is: 'Metadata' , title : 'ASP.NET 4.0'               , xref    : ['xref-22002762fc3e']}
  dataUtil.addMappings "metadata-13002762fc3e" , { is: 'Metadata' , title : 'ASP.NET 3.5'               , xref    : ['xref-26002762fc3e']}
  dataUtil.addMappings "metadata-20002762fc3e" , { is: 'Metadata' , title : 'Android'                   , xref    : ['xref-40002762fc3e']}
  dataUtil.addMappings "metadata-30002762fc3e" , { is: 'Metadata' , title : 'HTML5'                     , xref    : ['xref-00002762fc3e']}
  dataUtil.addMappings "metadata-70002762fc3e" , { is: 'Metadata' , title : 'iOS'                       , xref    : ['xref-80002762fc3e']}
  dataUtil.addMappings "metadata-11002762fc3e" , { is: 'Metadata' , title : 'Web Application'           , xref    : ['xref-17002762fc3e']}



  # Phase (Metadata)
  dataUtil.addMappings "query-00302762fc3e"    , { is: 'Query'    , title : 'Phase'                     , contains: ['metadata-40002762fc3e'
                                                                                                                     'metadata-90002762fc3e']}

  dataUtil.addMappings "metadata-40002762fc3e" , { is: 'Metadata' , title : 'Implementation'            , xref    : ['xref-10002762fc3e'
                                                                                                                     'xref-50002762fc3e'
                                                                                                                     'xref-90002762fc3e'
                                                                                                                     'xref-18002762fc3e'
                                                                                                                     'xref-23002762fc3e']}

  dataUtil.addMappings "metadata-90002762fc3e" , { is: 'Metadata' , title : 'Design'                    , xref    : ['xref-14002762fc3e'
                                                                                                                     'xref-27002762fc3e']}

  # Type (Metadata)
  dataUtil.addMappings "query-00202762fc3e"    , { is: 'Query'    , title : 'Type'                      , contains: ['metadata-50002762fc3e'
                                                                                                                     'metadata-12002762fc3e']}
  dataUtil.addMappings "metadata-50002762fc3e" , { is: 'Metadata' , title : 'Checklist Item'            , xref    : ['xref-20002762fc3e'
                                                                                                                     'xref-60002762fc3e'
                                                                                                                     'xref-11002762fc3e'
                                                                                                                     'xref-15002762fc3e'
                                                                                                                     'xref-24002762fc3e'
                                                                                                                     'xref-28002762fc3e']}

  dataUtil.addMappings "metadata-12002762fc3e" , { is: 'Metadata' , title : 'Guideline'                 , xref    : ['xref-19002762fc3e']}

  # Category (Metadata)
  dataUtil.addMappings "query-00402762fc3e"    , { is: 'Query'    , title : 'Category'                  , contains: ['metadata-60002762fc3e']}
  dataUtil.addMappings "metadata-60002762fc3e" , { is: 'Metadata' , title : 'Input and Data Validation' , xref    : ['xref-30002762fc3e'
                                                                                                                     'xref-70002762fc3e'
                                                                                                                     'xref-12002762fc3e'
                                                                                                                     'xref-16002762fc3e'
                                                                                                                     'xref-21002762fc3e'
                                                                                                                     'xref-25002762fc3e'
                                                                                                                     'xref-29002762fc3e']}

module.exports = addData