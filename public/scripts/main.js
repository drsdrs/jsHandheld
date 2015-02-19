var appsEl, ctrlApp;

window.ctrl = {
  left: function() {
    return ctrlApp("up");
  },
  right: function() {
    return ctrlApp("right");
  },
  up: function() {
    return ctrlApp("up");
  },
  down: function() {
    return ctrlApp("down");
  },
  enter: function() {
    return c.l("ENTER");
  },
  back: function() {
    return c.l("BACK");
  }
};

appsEl = [];

document.addEventListener("keyup", function(e) {
  var action, evt, key;
  key = e.keyCode;
  evt = e != null ? e : {
    e: window.event
  };
  if (evt.stopPropagation) {
    evt.stopPropagation();
  }
  if (evt.cancelBubble !== null) {
    evt.cancelBubble = true;
  }
  action = key === 37 ? "left" : key === 38 ? "up" : key === 39 ? "right" : key === 40 ? "down" : key === 13 ? "enter" : key === 32 ? "back" : void 0;
  return typeof ctrl[action] === "function" ? ctrl[action]() : void 0;
});

window.onload = function() {
  var shadow;
  shadow = document.getElementsByClassName("darkness");
  shadow[0].classList.add("light");
  shadow[1].classList.add("light");
  window.socket = io.connect('http://localhost:3000/eventRouter');
  return socket.on('ctrl', function(data) {
    if (data.action) {
      return window.ctrl[data.action]();
    }
  });
};

ctrlApp = function(UpDown) {
  socket.emit("playFx", 0);
  if (appsEl.length === 0) {
    appsEl = document.querySelectorAll("#apps a");
    appsEl.active = 2;
  }
  appsEl[appsEl.active].childNodes[0].classList.remove("active");
  appsEl.active += UpDown === "up" ? -1 : 1;
  if (appsEl.active > appsEl.length - 1) {
    appsEl.active = 0;
  } else if (appsEl.active < 0) {
    appsEl.active = appsEl.length - 1;
  }
  c.l(appsEl, appsEl.active);
  return appsEl[appsEl.active].childNodes[0].classList.add("active");
};

//# sourceMappingURL=main.js.map
