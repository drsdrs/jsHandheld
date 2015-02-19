snd = require("./sound")

module.exports = (io)->
  io.on 'connection', (socket)->
    socket.on "playFx", (nr)->
      snd.addFx nr
      console.log Date.now()+"HAAAAAAAAAAAAA"