window.ctrl =
  left: -> ctrlApp "up"
  right: -> ctrlApp "right"
  up: ->  ctrlApp "up"
  down: ->  ctrlApp "down"
  enter: -> c.l "ENTER"
  back: -> c.l "BACK"

appsEl = []

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
  ctrl[action]?()

window.onload = ->
  shadow = document.getElementsByClassName("darkness")
  shadow[0].classList.add("light")
  shadow[1].classList.add("light")
  # key events from server
  window.socket = io.connect('http://localhost:3000/eventRouter')
  socket.on 'ctrl', (data) ->
    if data.action then window.ctrl[data.action]()


ctrlApp = (UpDown)->
  socket.emit "playFx", 0
  if appsEl.length==0
    appsEl = document.querySelectorAll("#apps a")
    appsEl.active = 2
  appsEl[appsEl.active].childNodes[0].classList.remove "active"
  appsEl.active += if UpDown=="up" then -1 else 1
  if appsEl.active>appsEl.length-1 then appsEl.active = 0
  else if appsEl.active<0 then appsEl.active = appsEl.length-1
  c.l appsEl, appsEl.active
  appsEl[appsEl.active].childNodes[0].classList.add "active"

