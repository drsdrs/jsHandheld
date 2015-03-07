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

