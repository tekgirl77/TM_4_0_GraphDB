return

async            = require 'async'
Cache_Service    = require('./../../src/services/Cache-Service')
Graph_Service    = require('./../../src/services/Graph-Service')
Import_Service   = require('./../../src/services/Import-Service')
Data_Import_Util = require('./../../src/utils/Data-Import-Util')
Guid             = require('./../../src/utils/Guid')

describe.only 'Stats research - finding an article phase',->
  graphService = null
  db           = null

  before (done)->
    graphService     = new Graph_Service('tm-uno')
    graphService.openDb ->
      db = graphService.db
      done()

  after (done)->
    graphService.closeDb done

  it 'mode 1:(~500ms) Using .nav', (done)->
    db.nav('Data Validation') .archIn('title'       ).as('folder_Id')
                              .archOut('contains'   ).as('view_Id')
                              .archOut('contains'   ).as('article_Id')
                              .archOut('phase'      ).as('phase')
                              .solutions (error,data)->
                                throw error if error
                                data.assert_Size_Is(103).first()
                                                        .phase.assert_Is('Design')
                                done()

  it 'mode 2:(~500ms) Using .search ', (done)->
    searchQuery = [{ subject: db.v('folder_Id' ), predicate: 'title'   , object: 'Data Validation' }
                   { subject: db.v('folder_Id' ), predicate: 'contains', object: db.v('view_Id'   )}
                   { subject: db.v('view_Id'   ), predicate: 'contains', object: db.v('article_Id')}
                   { subject: db.v('article_Id'), predicate: 'phase'   , object: db.v('phase'     )}]
    db.search searchQuery, (error, data)->
      data.assert_Size_Is(103).first()
      .phase.assert_Is('Design')
      done()

  it 'mode 3:(~70ms) using partial .nav and partial .search', (done)->
    db.nav('Data Validation') .archIn('title'       ).as('folder_Id')
                              .archOut('contains'   ).as('view_Id')
                              .archOut('contains'   ).as('article_Id')
                              .solutions (error,data)->
                                #"Time to here: 36ms".log()
                                phases = []
                                mapItem = (item, next)->
                                  db.search {subject: item.article_Id, predicate:'phase', object: db.v('phase')}, (error, result)->
                                    phases.push(result.first().phase)
                                    next()
                                async.each data, mapItem, ->
                                  #"Time to here: 66ms".log()
                                  phases.assert_Size_Is(103)
                                  .assert_Contains('Design')
                                  done()

  it.only 'mode 4: (~45ms) Using multiple .gets and javascript object parsing', (done)->

    db.get {predicate:'title'}, (error, titles)->
      db.get {predicate:'contains'}, (error, contains)->
        db.get {predicate:'phase'}, (error, phases)->
          folder_Ids    = (title.subject for title in titles when title.object =='Data Validation')
          view_Ids     = (contain.object for contain in contains when folder_Ids.contains(contain.subject))
          article_Ids  = (contain.object for contain in contains when view_Ids.contains(contain.subject))
          #"# titles: #{titles.size()}   # contains: #{contains.size()}   # phases: #{phases.size()}".log()

          phases_Mapped = {}
          phases_Mapped[phase.subject]= phase for phase in phases

          phases = (phases_Mapped[article_Id].object for article_Id in article_Ids)
          phases.assert_Size_Is(103)
          .assert_Contains('Design')

          ## for reference the filter below actually gives the best and most accurate results (since there are 91 articles)
          #phases       = (phase for phase in phases when article_Ids.contains(phase.subject))
          #phases.assert_Size_Is(91)
          #      .assert_Contains('Design')
          done()


  it '(~30ms) Confirming that the prob is with the last archOut', (done)->
    db.nav('Data Validation') .archIn('title'       ).as('folder_Id')
    .archOut('contains'   ).as('view_Id')
    .archOut('contains'   ).as('article_Id')
    .solutions (error,data)->
      throw error if error
      data.assert_Size_Is(103).first()
      .article_Id.assert_Is('article-48f8925fa47b')
      done()