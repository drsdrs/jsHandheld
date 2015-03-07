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


genPopup = (content, cbOnClose)->
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

