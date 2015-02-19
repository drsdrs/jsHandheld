window.onload = ->
  bash = document.getElementById("bash")
  output = document.getElementById("output")
  socket = io.connect('http://localhost:3000')
  console.log("pow")
  socket.on 'bashCmd', (data)->
    console.log(data)
    text = output.innerHTML
    output.innerHTML = data+"<br/><br/>"+text

  bash.addEventListener "keyup", (e)->
    if e.keyCode==13
      cmd = e.target.value
      if cmd=="clear" then output.innerHTML = ""
      else socket.emit "processBashCmd", cmd
      e.target.value = ""
