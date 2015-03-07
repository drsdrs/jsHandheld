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
