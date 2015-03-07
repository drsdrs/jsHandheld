initMainCtrl = ()->
  window.ctrl =
    left: -> c.l "up"
    right: -> c.l "right"
    up: ->  c.l "up"
    down: ->  c.l "down"
    enter: -> c.l "ENTER"
    back: -> c.l "BACK"


window.onload = ->
  projectList = document.getElementById("projectList")
  eventIO = io.connect('http://localhost:3000/eventRouter')
  #("/fst")

  # EVENTS
  socket.on 'projectLoaded', (project)-> initProject(project)
  projectList.addEventListener "change", (e)->
    saveProject()
    loadProject e.target.value

  #autosave every nth seconds
  #setInterval (setActiveProjectLs), 30*1000

  #gamepad events
  eventIO.on "ctrl", (v)-> window.ctrl[v]()


  initProject = (project) ->
    window.project = project
    projectList.value = project.id
    genInstrumentView()
    genpatternView()

  saveProject = ()->
    console.log window.project.patterns.intro.steps[0]
    socket.emit "saveProject", window.project
  loadProject = (projectName)->
    if !projectName? then projectName = projectList[1].value
    socket.emit "loadProject", projectName

  #try load previous project from localstorrage
  loadProject()


  #initMainCtrl()

  document.addEventListener "keyup", (e)->
    key = e.keyCode
    #c.l key
    evt = e ? e:window.event
    if evt.stopPropagation then evt.stopPropagation()
    if evt.cancelBubble!=null then evt.cancelBubble = true
    action =
      if key==37 then "left"
      else if key==38 then "up"
      else if key==39 then "right"
      else if key==40 then "down"
      else if key==13 then "enter"
      else if key==32 then "back"
    window.ctrl[action]?()


window.onunload = (e)->
  socket.emit "saveProject"
  socket.close()
  #setActiveProjectLs()


#window.onbeforeunload = (e)->