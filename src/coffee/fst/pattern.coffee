socket = io.connect('http://localhost:3000/formulaSampleTracker')

fxList = [ "E", "F", "H" ]
notation = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
demoStep = {note: "C", oct: "3", vel: "75", fx0: "E", fx0Val: 0x64}

getFreq = (n)-> Math.pow(2, (n-69)/12)*440

tableEl = null
maxXPos = Object.keys(demoStep).length
maxYPos = 0

activePatternName = null

freqTable = []
i = 128
while i-- then freqTable[i] = getFreq i

initTableCtrl = ->
  tablePos = [0,0]
  activeEl = null

  checkPos = ->
    if tablePos[0]<1 then tablePos[0] = maxXPos
    else if tablePos[0]>maxXPos then tablePos[0] = 1
    if tablePos[1]<0 then tablePos[1] = maxYPos-1
    else if tablePos[1]>=maxYPos then tablePos[1] = 0

  setActive= ->
    checkPos()
    x = tablePos[1]
    y = tablePos[0]
    c.l activeEl
    activeEl?.classList.remove "active"
    activeEl = tableEl.childNodes[x].childNodes[y]
    activeEl.classList.add "active"

  window.ctrl =
    left: ->
      tablePos[0]--
      setActive()
    right: ->
      tablePos[0]++
      setActive()
    up: ->
      tablePos[1]--
      setActive()
    down: ->
      tablePos[1]++
      setActive()
    enter: -> setValue +1
    back: -> setValue -1

  setValue = (add)->
    unless activeEl then return c.l "noActive"
    val = activeEl.innerHTML
    type = activeEl.className.split(" ")[0]

    set = ->
      activeEl.innerHTML = val
      row = tablePos[1]
      project.patterns[activePatternName].steps[row][type] = val
      return socket.emit "setPatternValue",
        patternName: activePatternName
        row: row
        type: type
        val: val

    if type.slice(0,2)=="fx"&&type.slice(3,6)!="Val"
      len = fxList.length
      pos = if val=="=" then ~~(len/2) else 0
      fxList.forEach (note, i)-> if note==val then pos = i
      if !pos? then pos = ~~(len/2)
      pos += add
      if pos>=len then pos = 0
      else if pos<0 then pos = len-1
      val = fxList[pos]
      set()
    else if type=="note"
      len = notation.length
      pos = if val=="=" then ~~(len/2) else 0
      notation.forEach (note, i)-> if note==val then pos = i
      if !pos? then pos = 0
      pos += add
      if pos>=len then pos = 0
      else if pos<0 then pos = len-1
      val = notation[pos]
      set()

    val = parseInt(activeEl.innerHTML)
    if isNaN val then val = 0 else val += add
      
    if type=="oct"
      if val>=12 then val = 12 else if val<=-12 then val = -12
      set()
    else if type=="vel"
      if val>=128 then val = 128 else if val<=0 then val = 0
      set()
    else if type.slice(3,6)=="Val"
      if val>=256 then val = 256 else if val<=0 then val = 0
      set()


genpatternView = ()->
  patterns = project.patterns

  patternBoxEl = document.getElementById("patternBox")
  ptnConfigEl = document.createElement("div")
  patternSelectEl = document.createElement("select")
  tableEl = document.createElement("table")
  
  ptnConfigEl.appendChild patternSelectEl
  patternBoxEl.innerHTML = ""
  patternBoxEl.appendChild ptnConfigEl
  patternBoxEl.appendChild tableEl

  patternSelectEl.addEventListener "click", (e) ->
    sel = e.target.value
    if sel=="new"
      genKeyField "letters", (e)->
        name = e.innerText
        for k,v of project.patterns
          if k==name then name = e.target.value = name+"Dupl"
        patternSelectEl.value = name
        appendOption e
        project.patterns[e] =  steps: [ {},{},{},{},{},{},{},{} ]
        socket.emit "updatePattern", {name:e, data:project.patterns[e]}

      patternSelectEl.blur()
    else genPattern sel

  genPattern = (patternName)->
    activePatternName = patternName||activePatternName
    tableEl.innerHTML = ""
    TdCnt = 0
    genStep = (step)->
      trEl = document.createElement "tr"
      TdCnt++
      genTd = (k, data)->
        tdEl = document.createElement "td"
        tdEl.classList.add k
        tdEl.innerHTML = data||"="
        trEl.appendChild tdEl
      genTd "pos", TdCnt
      if Object.keys(step).length == 0
        for k,v of demoStep then genTd k, "="
      else
        for k,v of demoStep then genTd k,step[k]
      maxYPos = TdCnt
      tableEl.appendChild trEl
    steps = project.patterns[activePatternName].steps
    steps.forEach (step)-> genStep(step)

  appendOption = (key)->
    patternOptionEl = document.createElement("option")
    patternEl = document.createElement("div")
    patternEl.classList.add key,"pattern"
    patternOptionEl.innerHTML = key
    patternSelectEl.appendChild patternOptionEl

  genCollectionSelect = (collection)->
    appendOption "new"
    for key, val of patterns then appendOption key
    firstVal = patternSelectEl[1].innerText
    patternSelectEl.value = firstVal
    genPattern firstVal

  genPatternModOptions = ->
    genBtn = (content, funct)->
      btn = document.createElement("input")
      btn.type = 'button'
      btn.value = content
      btn.addEventListener "click", funct
      ptnConfigEl.appendChild btn
      btn
    getSteps = -> project.patterns[activePatternName].steps
    setSteps = (steps)-> project.patterns[activePatternName].steps = steps

    genBtn "+1", (e)->
      getSteps().push {}
      genPattern()
    genBtn "-1", (e)->
      getSteps().pop()
      genPattern()
    genBtn "*2", (e)->
      steps = getSteps()
      for v,i in steps then steps.push v
      genPattern()
    genBtn "/2", (e)->
      steps = getSteps()
      len = Math.round steps.length/2
      while len-- then steps.pop()
      genPattern()
    genBtn "*2C", (e)->
      steps = getSteps()
      newData = []
      for step, i in steps
        newData[i*2]= step
        newData[(i*2)+1]= {}
      setSteps newData
      genPattern()
    genBtn "/2C", (e)->
      steps = getSteps()
      newData = []
      for step, i in steps
        if i%2==0 then newData.push steps[i]
      setSteps newData
      genPattern()
    genBtn "RND", (e)->
      steps = getSteps()
      currentIndex = steps.length
      while 0 != currentIndex
        randomIndex = Math.floor(Math.random() * currentIndex)
        currentIndex -= 1
        temporaryValue = steps[currentIndex]
        steps[currentIndex] = steps[randomIndex]
        steps[randomIndex] = temporaryValue
      genPattern()

  genPatternModOptions()
  genCollectionSelect()
  initTableCtrl()

