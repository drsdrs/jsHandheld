module.exports = (io)->
  router = require("express").Router()
  cradle = require('cradle')
  fs = require("fs")


  io.on 'connection', (socket)->
    socket.on 'saveHighScore', (hightscore)->
      console.log "try to load "


  router.get "/", (req, res, next) ->
    res.render "endymen",
      title: "endymen-game"
      highscore: getHighscore()


  getHighscore = ->
    return {
      name: "meisterBob"
      score: 130420
    }
  module.exports = router



