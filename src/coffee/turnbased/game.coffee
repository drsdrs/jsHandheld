init = ->
  console.log "INIT-1.2.3"
  gameScreen = document.getElementById("gameScreen")
  startScreen = document.getElementById("startScreen")
  startGameBtn = document.getElementById("startGameBtn")
  highScore = document.getElementById("highScore")

  class BaseModel
    constructor:(args)->
      for k,v of args then @k=v
    set: (k,v)-> @k=v
    get: (k)-> v

  class Entity extends BaseModel
    type: "player" ##item/bonus/player/solid
    icon: "E"
    stats:
      live: 1
    animation:
      go:
        speed: 500
        steps: "G","O"
      fight:
        speed: 250
        steps: "K","I","L","L"


  class PlayField
    constructor:(args)->
      for k,v of args then @k=v;if k=="exit" then break
    playFieldEl: null
    backgroundEl: null

  class Game
    constructor:(args)->
      for k,v of args then @k=v

    rules:
      nextRound:
        value:"allPlayersMoved"#"playerAfterPlayer"#"time_enemy-2500_player-100"
        options:
          moved:

    setRule: (rule)->
      @rules[rule]




  c.l playField 

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
  

    getTd: (pos)-> @els.table.childNodes[pos.y].childNodes[pos.x]

    moveTd:(xMod,yMod)->
      td.classList.add "trans"
      pos = @stats.pPos
      posNew = x: pos.x+xMod, y: pos.y+yMod

    movePlayer: (xMod,yMod)->
      pos = @stats.pPos
      posNew = x: pos.x+xMod, y: pos.y+yMod

    moveFields: (xMod,yMod)->
      pos = @stats.pPos
      posNew = x: pos.x+xMod, y: pos.y+yMod
      posStyle = {}

      if posNew.x>=@stats.size.x then posNew.x = @stats.size.x
      else if posNew.x<0 then posNew.x = 0
      else if posNew.y>=@stats.size.y then posNew.y = @stats.size.y
      else if posNew.y<0 then posNew.y = 0

      if pos.x<posNew.x # right
        posStyle.left = "60px"
      else if pos.x>posNew.x # left
        posStyle.left = "-60px"
      if pos.y<posNew.y # up
        posStyle.top = "60px"
      else if pos.y>posNew.y # down
        posStyle.top = "-60px"

      @stats.pPos = newPos

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
