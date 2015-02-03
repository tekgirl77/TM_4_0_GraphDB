Markdown_It = require('markdown-it')

class Wiki_Service
  constructor: (options)->
    @markdownIt = Markdown_It()

  to_Html: (markdown, callback)=>
    html   = @markdownIt.render(markdown);
    tokens = @markdownIt.parse(markdown)

    callback html, tokens
    html

module.exports = Wiki_Service