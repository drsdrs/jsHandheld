c = console; c.l = c.log

snd = require("./sound")
HID = require('node-hid')

module.exports = (io)->
  io.on 'connection', (socket)->
    if initHud(socket)==false
      c.l "FALSE"
      
    socket.on "playFx", (nr)->
      snd.addFx nr
      console.log Date.now()+"PLAYFX"

device = null
initHud = (socket)->
  devices = HID.devices()
  c.l "init Hud at:::"+Date.now()
  if devices.length==0 then c.l "no device"; return #setTimeout initHud(socket), 800
  if !device then device = new HID.HID devices[0]?.path
  c.l "device:", devices[0]

  btns = {}

  device.on "error", (d)->
    device.close()
    device = null
    return setTimeout initHud(socket), 500

  device.on "data", (d)->
    btnStr = d[2]
    ssStr = d[3]
    btns =
      left: d[0]==1
      right: d[0]==255
      up: d[1]==1
      down: d[1]==255
      select: (ssStr&1)==1
      start: (ssStr&2)==2
      btn0: (btnStr&1)==1
      back: (btnStr&2)==2
      enter: (btnStr&4)==4
      btn3: (btnStr&8)==8
      btnLU: (btnStr&16)==16
      btnRU: (btnStr&32)==32
      btnLD: (btnStr&64)==64
      btnRD: (btnStr&128)==128

    timeOuters = {}
    checkHold = (k,v)->
      socket.emit "ctrl", k
      delay = 750
      doTimeout = (delay)->
        id = setTimeout ->
          if btns[k]==true
            timeOuters[k] = true
            delay*=0.5 if delay>140
            socket.emit "ctrl", k
            doTimeout delay
          else
            timeOuters[k] = false
            clearTimeout id
        ,delay
      doTimeout(delay)

    for k,v of btns
      if v==true&&(timeOuters[k]==undefined||timeOuters[k]==false)
        checkHold(k,v)
    #if pushed.length==1 then socket.emit "ctrl", pushed[0]
    #else if pushed.length==1