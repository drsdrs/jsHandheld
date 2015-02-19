window.onload = function() {
  var bash, output, socket;
  bash = document.getElementById("bash");
  output = document.getElementById("output");
  socket = io.connect('http://localhost:3000');
  console.log("pow");
  socket.on('bashCmd', function(data) {
    var text;
    console.log(data);
    text = output.innerHTML;
    return output.innerHTML = data + "<br/><br/>" + text;
  });
  return bash.addEventListener("keyup", function(e) {
    var cmd;
    if (e.keyCode === 13) {
      cmd = e.target.value;
      if (cmd === "clear") {
        output.innerHTML = "";
      } else {
        socket.emit("processBashCmd", cmd);
      }
      return e.target.value = "";
    }
  });
};

//# sourceMappingURL=terminal.js.map
