require 'fluentnode'

child_process = require('child_process')

class Git_API
    constructor: (options)->
      @.options        = options || {}
      @.swaggerService = @options.swaggerService

      @commands =
            status: { name: 'status' , params: []}
            remote: { name: 'remote' , params: ['-v']}
            log   : { name: 'log'    , params: ['--graph', '--pretty=oneline', '-15']}

    git_Exec: (command)=>
      git_Exec_Method

    git_Exec_Method : (command)=>
        (req,res)=>
            command.params.unshift(command.name)

            result = ''

            childProcess = child_process.spawn('git', command.params)

            childProcess.stdout.on 'data', (data)-> result += data.str().trim()
            childProcess.stderr.on 'data', (data)-> result += data.str().trim()

            childProcess.on 'exit', ()->
                res.send { 'data' : result }

    add_Git_Command: (command)=>
      get_Command =
            spec   : { path : "/git/#{command.name}/", nickname : command.name}
            action : @git_Exec_Method(command)


      @.swaggerService.addGet(get_Command)

    add_Methods: ()=>
      @add_Git_Command(@.commands.status)
      @add_Git_Command(@.commands.remote)
      @add_Git_Command(@.commands.log)


module.exports = Git_API