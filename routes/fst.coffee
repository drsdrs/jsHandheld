module.exports = (io)->
  router = require("express").Router()
  cradle = require('cradle')
  fs = require("fs")
  activeProject = null
  projectDir = __dirname+"/../fst_projects/"

  io.on 'connection', (socket)->
    socket.on 'loadProject', (projectName)->
      console.log "try to load "+projectName
      loadProject projectName, (project)->
        activeProject = project
        socket.emit 'projectLoaded', project
        console.log "project "+activeProject.id+" LOADED"

    socket.on 'saveProject', (project)->
      if project? then activeProject = project
      else if activeProject? then project = activeProject
      else project = demodata
      saveProject project.id, project
      console.log "project "+activeProject._id+" SAVED"

    socket.on 'setPatternValue', (params)-> setPatternValue(params)

    socket.on 'updatePattern', (obj)-> updatePattern obj.name, obj.data

  updatePattern = (name, pattern)->
    console.log "updatePattern"
    activeProject.patterns[name] = pattern

  setPatternValue = (params)->
    if activeProject?
      activeProject.patterns[params.patternName].steps[params.row][params.type]=params.val
      console.log activeProject.patterns[params.patternName].steps
      saveProject activeProject.id, activeProject

  loadProject = (projectName, cb)->
    fs.readFile projectDir+projectName, (err, res)->
      if err then console.log "err",err else cb? JSON.parse res

  saveProject = (projectName ,data, cb)->
    data.id = projectName
    fs.writeFile projectDir+projectName, JSON.stringify(data), (err, res) ->
      if err then console.log "err",err else cb? res
      console.log "file saved "+projectName

  getProjectList = (cb)->
    fs.readdir projectDir, (err, res)->
      p= []
      res.forEach (rev,key)-> p.push(rev)
      cb? p
  
  demoStep = {note: "C", oct: "3", vel: "75", fx0: "E", fx0Val: 0x64}
  demodata =
    config:
      bpm: 120
    instruments:
      "bd":
        type: "default"
        sample: "boink.wav"
        formula: "t^(t*t>>10)"
      "lead":
        type: "default"
        sample: "lead.wav"
        formula: "t|(t%255.5)"
      "roland":
        type: "midi"
        ch: 0
        device: "default"
      "6sineOsc":
        type: "softSynth"
        config:
          osc1offset: 0.12
          cutoff: 0.23
          attack: 0.7
    patterns:
      "intro":
        steps: [
          demoStep
          {},{},{}
          demoStep
          {}
          demoStep
          {}
        ]
    song:
      tracks:[
        ["intro", "", "", ""]
        ["", "intro", "", "intro"]
      ]

  saveProject "dem", demodata

  getProjectList (projectList)->
    router.get "/", (req, res, next) ->
      res.render "fst",
        title: "formulaSampleTracker"
        projects: projectList

  module.exports = router



