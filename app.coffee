c = console; c.l = c.log

require("coffee-script/register")

path = require("path")
favicon = require("serve-favicon")
cookieParser = require("cookie-parser")
bodyParser = require("body-parser")
exec = require("child_process").exec

express = require('express')
app = express()

http = require('http').Server(app)
io = require('socket.io')(http)

eventRouter = require("./server/eventRouter")(io.of('/eventRouter'))

routes = require("./routes/index")
terminal = require("./routes/terminal")
fst = require("./routes/fst")(io.of('/formulaSampleTracker'))
endymen = require("./routes/endymen")(io.of('/endymen'))

# view engine setup
app.set "env", "development"
app.set "views", path.join(__dirname, "views")
app.set "view engine", "ejs"
app.set 'port', process.env.PORT || 3000
app.use(favicon(__dirname + '/public/favicon.ico'))
app.use bodyParser.json()
app.use bodyParser.urlencoded(extended: false)
app.use cookieParser()

app.use express.static(path.join(__dirname, "public"))
app.use "/", routes
app.use "/jsTerminal", terminal
app.use "/formulaSampleTracker", fst
app.use "/endymen", endymen

# catch 404 and forward to error handler
app.use (req, res, next) ->
  err = new Error("Not Found")
  err.status = 404
  next err

# error handlers

# development error handler
# will print stacktrace
if app.get("env") is "development"
  app.use (err, req, res, next) ->
    res.status err.status or 500
    res.render "error",
      message: err.message
      error: err


# production error handler
# no stacktraces leaked to user
app.use (err, req, res, next) ->
  res.status err.status or 500
  res.render "error",
    message: err.message
    error: {}


http.listen 3000, -> console.log 'listening on *:3000'

module.exports = io
