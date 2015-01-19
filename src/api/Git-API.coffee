require 'fluentnode'

class Git_API
    constructor: ->

    git_Exec : (cmd, callback)=>
        'git'.start_Process_Capture_Console_Out cmd, callback


    add_Methods: (swaggerService)=>

        status =
          spec              : { path : "/git/status/", nickname : "status"}
          action            : (req, res)=> @git_Exec 'status', (result)-> res.send {'data': result}

        swaggerService.addGet(status)

module.exports = Git_API