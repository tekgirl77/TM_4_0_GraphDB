QA_NWR_API              = require './TM-QA-NWR-API'
Server                  = require '../../src/Server'
Swagger_Service         = require '../../src/swagger/Swagger-Service'

describe 'swagger | Swagger-Service.QA.test', ->
  page   = QA_NWR_API.create(before, after)
  url    = null
  help   = null
  server = null

  before (done)->
    server  = new Server()
    options = { app: server.app }
    swaggerService = new Swagger_Service options
    swaggerService.set_Defaults()
    server.start()
    url  = server.url()
    help = url + '/docs/?url='+url + '/api-docs'
    url.append('/api-docs').GET (html)->
      html.assert_Is_String()
      done()

  after (done)->
    server.stop ->
      url.GET (html)->
        assert_Is_Null(html)
        done()

  it 'open docs', (done)->
    page.chrome.open help, ()->
      400.wait ->
        page.html (html,$)->
          $('.info_title').html().assert_Is('Swagger Hello World App')
          $('h2').text().trim().assert_Is('say')
          #page.click 'pet',->
          #page.chrome.eval_Script "$('.endpoint .options a')[0].click()", ->
          #page.chrome.eval_Script "$('.endpoint .options a')[1].click()", ->
          done()

  #it 'Issue - Swagger UI Description allows HTML Injection (XSS by Design)', (done)->
  #  dynamicText = 'jQuery Injection - '.add_5_Random_Letters()
  #  javascript = "$(function() { $('#target').html('#{dynamicText}')})"
  #  app.swagger.apiInfo.description = "Description element allows: <h1 id='target'>...</h1> <script>#{javascript}</script>"
  #  page.chrome.open url + 'docs', ()->
  #    page.html (html,$)->
  #      $('#target').html().assert_Is(dynamicText)
  #      done()