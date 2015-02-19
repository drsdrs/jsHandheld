module.exports = (io)->
  router = require("express").Router()
  cradle = require('cradle')
  db = new(cradle.Connection)().database('fst')

  io.on 'connection', (socket)->
    socket.on 'loadProject', (projectName)->
      console.log projectName
      loadProject(
        projectName,
        (project)->
          socket.emit 'projectLoaded', project
      )
    socket.on 'saveProject', (project)->
      saveProject project._id, project

  db.exists (err, exists) ->
    if err then console.log "db.exists error\n", err
    else if exists then console.log "Database exists"
    else console.log "Database does not exists."; db.create()
  
  loadProject = (projectName, cb)->
    funct = db.get projectName, (err, res)->
      console.log err if err
      cb? res||false

  saveProject = (projectName ,data, cb)->
    console.log "save", projectName
    db.save projectName,
      (data),
      (err, res) ->
        if err then console.log err else console.log res
        cb? res

  getProjectList = (cb)->
    db.all (err, res)->
      p= []
      res.forEach (rev,key)->
        p.push(rev)
      cb? p
  
  demodata =
    instruments:
      "bd":
        sample: "boink.wav"
        formula: "t^(t*t>>10)"
      "lead":
        sample: "lead.wav"
        formula: "t|(t%255.5)"
    patterns:
      "intro":
        steps: [
          {note: ["C","3"], vel: "75", fx0: ["E",0x64]}
          {},{},{}
          {note: ["F#","3"], vel: "75", fx0: ["E",0x64]}
          {}
          {note: ["F#","3"], vel: "75", fx0: ["E",0x64]}
          {}
        ]
    song:
      tracks:[
        ["intro", "", "", ""]
        ["", "intro", "", "intro"]
      ]
    config:
      bpm: 120

  saveProject "lula3000", demodata

  getProjectList (projectList)->
    router.get "/", (req, res, next) ->
      res.render "fst",
        title: "formulaSampleTracker"
        projects: projectList

  module.exports = router



