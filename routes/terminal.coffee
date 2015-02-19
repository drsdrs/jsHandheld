module.exports = (io)->
  router = require("express").Router()

  router.get "/", (req, res, next) ->
    res.render "terminal",
      title: "JS-TERMINAL"


  io.on 'connection', (socket)->
    exec = require("child_process").exec
    child = null
    callChild = (cmd)->
      if child != null
        return socket.emit('bashCmd', "process still running...")
      child = exec cmd, (err, stdout, stderr) ->
        socket.emit 'bashCmd', stdout
        socket.emit 'bashCmd', stderr
        child = null
    socket.on 'processBashCmd', (data)->
      if data=="kill"&&child!=null
        child.kill("SIGKILL")
        child = null

      else callChild(data)

  module.exports = router



