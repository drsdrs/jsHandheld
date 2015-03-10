init = ->
  console.log "INIT.1.2.3"
  gameScreen = document.getElementById("gameScreen")
  startScreen = document.getElementById("startScreen")
  startGameBtn = document.getElementById("startGameBtn")
  highScore = document.getElementById("highScore")

  blocks = [
    "happy"
    "fire"
    "cog"
    "pacman"
    "skeletor"
    "sun-fill"
    "bomb"
    "neutral"
    "frustrated"
  ]



  turnbasedGame =
    els:
      table: document.getElementById("table")
      score: document.getElementById("score")
      level: document.getElementById("level")
      moves: document.getElementById("moves")

    stats:
      size:
        x: 9
        y: 9
      level: 0
      score: 0
      moves: 0
      items: []
      pPos: x:4,y:4

    start: ->
      startScreen.classList.add "hidden"
      gameScreen.classList.remove "hidden"
      @stats.moves = 120
      @stats.score = 0
      @stats.level = 7
      @initRandomFields()
      @buildTable()

    buildTable: ->
      that = @
      arr = @stats.items
      arr.forEach (row, y)->
        tr = document.createElement("div")
        row.forEach (item, x)->
          td = document.createElement("span")
          iconTd = document.createElement("span")
          td.appendChild iconTd
          tr.appendChild td
          if that.stats.pPos.x==x&&that.stats.pPos.y==y
            item = 7
          that.setTd td, item #if item != 0

        that.els.table.appendChild tr


    setTd: (td, type)->
      icon = blocks[type]
      iconTd = td.childNodes[0]
      td.className = "color-"+icon
      iconTd.className = "icon-"+icon
      td


    movePlayer: (xMod,yMod)->
      pos = @stats.pPos
      posNew = x: pos.x+xMod, y: pos.y+yMod

    swapTwoFields: (posA, posB)->



    initRandomFields: ->
      y = @stats.size.y
      arr = @stats.items = []
      while y--
        x = @stats.size.x
        arr[y] = []
        while x--
          rnd = Math.random()*2
          val = if rnd < .25 then 0 else if rnd > 1.75 then 1 else 2
          arr[y][x] = val

    getRndColor:->
      range = @stats.level+2
      max = 10#bgStyle.length
      if range>=max then range = max
      Math.floor Math.random()*range

    updateStats: (n, col)->
      bonus = if col<3 then 20 else 60*col
      score = (n*n*bonus)
   
      @stats.moves+= moves+bonMoves
      @stats.level += 1 if (@stats.score/(2000*(@stats.level+1)))>@stats.level
      @stats.score += score
      @els.moves.innerHTML = @stats.moves
      @els.level.innerHTML = @stats.level
      @els.score.innerHTML = @stats.score




  ## Start game
  startGameBtn.addEventListener "click", ->turnbasedGame.start()
  turnbasedGame.start()

  window.left = -> turnbasedGame.movePlayer -1, 0
  window.right = -> turnbasedGame.movePlayer 1, 0

window.onload = ->
  #gamepad events
  window.ctrl = {}
  eventIO = io.connect('http://localhost:3000/eventRouter')
  eventIO.on "ctrl", (v)-> window.ctrl[v]()

  #keyboard events
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

  init()

