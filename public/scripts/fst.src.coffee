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

genInstruments = ()->
  instruments = project.instruments||null
  if project.instruments? then instruments = project.instruments
  else console.log "no instrument data"
  instrumentBoxEl = document.getElementById("instrumentBox")
  instrumentsEl = document.createElement("div")
  instrumentSelectEl = document.createElement("select")

  changeInstrument = (e)->
    targetInstr = instrumentBoxEl.getElementsByClassName(e.target.value)[0]
    instrs = instrumentBoxEl.getElementsByClassName("instrument")
    for instr,i in instrs
      if instr!=targetInstr then instr.style.display = "none"
      else targetInstr.style.display = "block"

  instrumentSelectEl.addEventListener "change", changeInstrument

  instrumentBoxEl.innerHTML = ""
  instrumentBoxEl.appendChild instrumentSelectEl

  for key, val of instruments
    instrumentOptionEl = document.createElement("option")
    instrumentEl = document.createElement("div")
    h2El = document.createElement("h2")
    formulaEl = document.createElement("input")
    loadSampleEl = document.createElement("a")

    formulaEl.addEventListener "change", (e) ->
      name = this.className
      c.l name
      project.instruments[name].formula = e.target.value

    h2El.innerHTML = key
    instrumentEl.classList.add key,"instrument"
    formulaEl.value = val.formula
    formulaEl.classList.add key
    instrumentOptionEl.innerHTML = key

    instrumentSelectEl.appendChild instrumentOptionEl

    instrumentEl.appendChild h2El
    instrumentEl.appendChild formulaEl
    instrumentEl.appendChild loadSampleEl

    instrumentsEl.appendChild instrumentEl

    instrumentBoxEl.appendChild instrumentEl


  #init first instrument
  changeInstrument target: instrumentBoxEl.querySelector("option")

keySets =
  math: [
    [0,1,2,3,4]
    [5,6,7,8,9]
    ["+","-","&","|","t",">>","<<"]
    ["/","*","^","!","%","(",")"]
  ]

  letters: [
    ["q","w","e","r","t","y","u","i","o","p"]
    ["a","s","d","f","g","h","j","k","l"]
    ["z","x","c","v","b","n","m"]
  ]



genKeyField = (content, cbOnClose)->
  if typeof(content)=="string"&&keySets[content]
    content = keySets[content]
  else if !content? then return c.l "genKeyField need some content!"
  if document.getElementById("keyfield")? then return c.l "keyfieldEl exists!!!!!"
  xpos = 0
  ypos = 0
  keyfieldEl = document.createElement("div")
  keyfieldEl.id = "keyField"
  inputEl = document.createElement("input")
  document.body.appendChild keyfieldEl

  setTimeout (->keyfieldEl.classList.add "open", "h100"), 250

  getActiveRow = (y)-> keyfieldEl.childNodes[y||ypos]
  getActiveData = (x)-> getActiveRow().childNodes[x||xpos]


  validateX = (x)->
    max = getActiveRow().childNodes.length-1
    x = xpos+x
    xpos = if x>max then 0 else if x<0 then max else x

  validateXClamp = (yposOld)->
    max = getActiveRow().childNodes.length-1
    maxOld = getActiveRow(yposOld).childNodes.length-1
    xpos = Math.round(max*xpos/maxOld)

  validateY = (y)->
    yposOld = ypos
    max = keyfieldEl.childNodes.length-1
    y = ypos+y
    ypos = if y>max then 0 else if y<0 then max else y
    validateXClamp(yposOld)

  moveActiveData = ->
    if ypos==0 then xpos = 1
    activeEl = keyfieldEl.getElementsByClassName("active")[0]
    if activeEl? then activeEl.classList.remove "active"
    getActiveData().classList.add "active"

  window.ctrl.left = ->
    validateX -1
    moveActiveData()
  window.ctrl.right = ->
    validateX +1
    moveActiveData()
  window.ctrl.up = ->
    validateY -1
    moveActiveData()
  window.ctrl.down = ->
    validateY +1
    moveActiveData()
  window.ctrl.enter = ->
    if ypos==0
      cbOnClose inputEl.value
      closeKeyField()
    else
      data = getActiveData().innerHTML
      inputEl.value+=data
  window.ctrl.back = ->closeKeyField()

  closeKeyField = ->
    initMainCtrl()
    keyfieldEl.classList.remove "open", "h100"
    setTimeout (->document.body.removeChild keyfieldEl), 600

  fillKeyField = ()->
    rowEl = document.createElement("div")
    submitEl = document.createElement("button")
    submitEl.innerHTML = "submit"
    rowEl.appendChild inputEl
    rowEl.appendChild submitEl
    keyfieldEl.appendChild rowEl
    rowEl.style.lineHeight = rowHeight*4.75+"%"
    rowEl.style.fontSize = rowHeight*22+"%"
    rowEl.style.height = rowHeight+"%"
    rowHeight = 100/content.length

    content.forEach (cntArr, i)->

      rowEl = document.createElement("div")
      rowEl.style.height = rowHeight+"%"
      dataWidth = 100/cntArr.length
      fontSizePercent = if rowHeight>dataWidth then dataWidth else rowHeight
      rowEl.style.lineHeight = rowHeight*4.75+"%"
      rowEl.style.fontSize = fontSizePercent*22+"%"
      keyfieldEl.appendChild rowEl

      cntArr.forEach (data, j)->
        dataEl = document.createElement("span")
        rowEl.appendChild dataEl
        dataEl.style.width = dataWidth+"%"
        #dataEl.style.padding = rowHeight/4+"% 0"
        dataEl.innerHTML = data


  fillKeyField()


setTimeout (->
  #genKeyField demoArr2, (key)->c.l key
), 300

getActiveProjectLs = ()->
  recentProject = localStorage.getItem "recentProject"
  if recentProject?
    return JSON.parse recentProject

setActiveProjectLs = (cb)->
  c.l "setActiveProjectLs"
  if project?
    localStorage.setItem "recentProject",  JSON.stringify project
    cb?()
genpatterns = ()->
  patterns = project.patterns

  patternBoxEl = document.getElementById("patternBox")
  patternSelectEl = document.createElement("select")
  tableEl = document.createElement("table")
  
  patternBoxEl.innerHTML = ""
  patternBoxEl.appendChild patternSelectEl
  patternBoxEl.appendChild tableEl


  genPattern = (patternName)->
    tableEl.innerHTML = ""

  genCollectionSelect = (collection)->
    appendOption = (key)->
      patternOptionEl = document.createElement("option")
      patternEl = document.createElement("div")
      patternOptionEl.addEventListener "click", (e) ->
        sel = e.target.value
        if sel=="new"
          genKeyField("letters", (e)->appendOption e)
          patternSelectEl.blur()
        else genPattern sel


      patternEl.classList.add key,"pattern"
      patternOptionEl.innerHTML = key

      patternSelectEl.appendChild patternOptionEl

    appendOption "new"
    for key, val of patterns then appendOption key

  genCollectionSelect()


demoArr = [
  "ane"
  "lko"
  "po":[
    "222",2,3,4,5,6,7,6,5
    "2#":[
      "3333"
      "333#":[
        "16","1","1","17","1","1","13","12","214","213","y"
        "14","13","12","214","213","212","13","12","214","213","x"
      ]
      "3"
      "33"
    ]
    "bu"
    "11","1","1","15","1","1","13","a","b","b","c"
    "11","1","1","15","1","1","13","a","b","b","c"
    "11","1","1","15","1","1","13","a","b","b","c"
    "hu"
  ]
  "JO"
  "GO"
]

setTimeout (->
  #genPopup demoArr, "browser", (key)->c.l key
), 100


genPopup = (content, type, cbOnClose)->
  contentPos = []#["po","2#"]
  activeColPos = -1
  activeCol = 0
  popupEl = document.createElement("div")
  colEl = [document.createElement("div"), document.createElement("div")]
  document.body.appendChild popupEl
  popupEl.appendChild colEl[0]
  popupEl.appendChild colEl[1]

  colEl[0].classList.add "col1"
  colEl[1].classList.add "col2"
  popupEl.id = "popup"

  setTimeout (->popupEl.classList.add "open", "h100"), 250

  getActive = -> popupEl.childNodes[ activeCol ].childNodes[ activeColPos ]
  
  setActiveCol = (active)->
    activeCol = active
    colEl[active].classList.add "active"
    colEl[active^1].classList.remove "active"

  window.ctrl.left = (e)->
    return if contentPos.length==0
    targetName = getActive().innerHTML
    trackArr = content
    lastGroup = contentPos.pop targetName
    if activeCol==1 then setActiveCol 0
    else
      #if contentPos.length==0 then activeCol = 1
      #if activeCol>0&&colEl[0].innerHTML.length>0
      contentPos.forEach (pos)-> trackArr = getInArr(trackArr, pos)
      colEl[1].innerHTML = colEl[0].innerHTML
      fillCol trackArr
    for el, i in colEl[0].childNodes # find last selected group
      console.log lastGroup, el.innerHTML
      if lastGroup==el.innerHTML&&el.style.fontWeight=="bold"
        activeColPos = i
        el.classList.add "active"

  window.ctrl.right = (e)->
    if getActive().style.fontWeight=="bold"
      targetName = getActive().innerHTML
      trackArr = content
      contentPos.push targetName
      if activeCol>0&&colEl[1].innerHTML.length>0
        colEl[0].innerHTML = colEl[1].innerHTML
      contentPos.forEach (pos)-> trackArr = getInArr(trackArr, pos)

      setActiveCol 1
      fillCol trackArr
      activeColPos = -1
      window.ctrl.down()

  getInArr = (arr, targetGroup)->
    for data, i in arr
      if Object.keys(arr[i])[0]==targetGroup
        return arr[i][targetGroup]

  fillCol = (arr)->
    colEl[activeCol].innerHTML = ""
    arr = arr||content
    arr.forEach (data)->
      itemEl = document.createElement("span")
      itemEl.innerHTML =
        if typeof(data)=="object"
          itemEl.style.fontWeight= "bold"
          Object.keys(data)
        else data
      colEl[activeCol].appendChild itemEl

  window.ctrl.enter = (e)->
    if getActive().style.fontWeight=="bold" then return window.ctrl.right()
    cbOnClose? getActive().innerHTML
    initMainCtrl()
    popupEl.classList.remove "open", "h100"
    setTimeout (->document.body.removeChild popupEl), 600

  window.ctrl.back = (e)->
    if getActive()?.style.fontWeight=="bold"&&contentPos.length==0
      return window.ctrl.left()
    initMainCtrl()
    popupEl.classList.remove "open", "h100"
    setTimeout (->document.body.removeChild popupEl), 600

  window.ctrl.up = (e)->
    targetOld = getActive()
    if activeColPos<=0 then activeColPos= colEl[activeCol].childNodes.length-1
    else activeColPos--
    target = getActive()
    target.classList.add "active"
    targetOld?.classList.remove "active"
    topSelect = target.clientHeight*activeColPos
    scrollTarget target

  window.ctrl.down = (e)->
    targetOld = getActive()
    if activeColPos>=colEl[activeCol].childNodes.length-1
      activeColPos= 0
    else activeColPos++

    target = getActive()
    target.classList.add "active"
    targetOld?.classList.remove "active"
    scrollTarget target

  scrollTarget = (target)->
    topSelect = target.clientHeight*activeColPos
    if topSelect>window.innerHeight/2 then colEl[activeCol].scrollTop = activeColPos*(colEl[activeCol].clientHeight/colEl[activeCol].childNodes.length)
    else if topSelect<window.innerHeight/2 then colEl[activeCol].scrollTop = activeColPos*(colEl[activeCol].clientHeight/colEl[activeCol].childNodes.length)

  
  fillCol()
  colEl[0].classList.add "active"


genWorker = ()->
  response = 'self.onmessage=function(e){postMessage(2*2+10+e.data);}'
  worker =
    new Worker URL.createObjectURL(
      new Blob([ response ], type: 'application/javascript')
    )


worker = genWorker()
worker.postMessage('Testit')
worker.onmessage = (e) ->
  e.data == 'msg from worker'
  c.l e.data

