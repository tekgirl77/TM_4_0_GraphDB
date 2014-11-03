Cache_Service    = require('./../../../src/services/Cache-Service')
Data_Service     = require('./../../../src/services/Db-Service')
Data_Import_Util = require('./../../../src/utils/Data-Import-Util')
Guid             =  require('./../../../src/utils/Guid')

return
describe 'db | tm-data | test-data-import |', ->

  dataService = new Db_Service('tm-uno')

  it 'test ctor',->
    console.log 'here'