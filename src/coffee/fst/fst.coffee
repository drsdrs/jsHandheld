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
  socket = io.connect('http://localhost:3000/formulaSampleTracker')
  #("/fst")

  # EVENTS
  socket.on 'projectLoaded', (project)-> initProject(project)
  projectList.addEventListener "change", (e)->
    saveProject()
    socket.emit "loadProject", e.target.value

  #autosave every nth seconds
  setInterval (setActiveProjectLs), 30*1000
  
  initProject = (project) ->
    window.project = project
    projectList.value = project._id
    genInstruments()
    genpatterns()

  saveProject = ()-> socket.emit "saveProject", project
  loadProject = (projectName)->
    if projectName? then projectName = projectList[1].value
    socket.emit "loadProject", projectName

  #try load previous project from localstorrage
  project = getActiveProjectLs()
  if project? then initProject(project)
  else loadProject()


  initMainCtrl()

  document.addEventListener "keyup", (e)->
    key = e.keyCode
    #c.l key
    evt = e ? e:window.event
    if evt.stopPropagation then evt.stopPropagation()
    if evt.cancelBubble!=null then evt.cancelBubble = true
    c.l key
    action =
      if key==37 then "left"
      else if key==38 then "up"
      else if key==39 then "right"
      else if key==40 then "down"
      else if key==13 then "enter"
      else if key==32 then "back"
    window.ctrl[action]?()


window.onunload = (e)->
  setActiveProjectLs()
  socket.emit "saveProject", project


window.onbeforeunload = (e)->
  alert "HELLO"
  socket.close()