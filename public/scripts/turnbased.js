var init;

init = function() {
  var blocks, gameScreen, highScore, startGameBtn, startScreen, turnbasedGame;
  console.log("INIT.1.2.3");
  gameScreen = document.getElementById("gameScreen");
  startScreen = document.getElementById("startScreen");
  startGameBtn = document.getElementById("startGameBtn");
  highScore = document.getElementById("highScore");
  blocks = ["happy", "fire", "cog", "pacman", "skeletor", "sun-fill", "bomb", "neutral", "frustrated"];
  turnbasedGame = {
    els: {
      table: document.getElementById("table"),
      score: document.getElementById("score"),
      level: document.getElementById("level"),
      moves: document.getElementById("moves")
    },
    stats: {
      size: {
        x: 9,
        y: 9
      },
      level: 0,
      score: 0,
      moves: 0,
      items: [],
      pPos: {
        x: 4,
        y: 4
      }
    },
    start: function() {
      startScreen.classList.add("hidden");
      gameScreen.classList.remove("hidden");
      this.stats.moves = 120;
      this.stats.score = 0;
      this.stats.level = 7;
      this.initRandomFields();
      return this.buildTable();
    },
    buildTable: function() {
      var arr, that;
      that = this;
      arr = this.stats.items;
      return arr.forEach(function(row, y) {
        var tr;
        tr = document.createElement("div");
        row.forEach(function(item, x) {
          var iconTd, td;
          td = document.createElement("span");
          iconTd = document.createElement("span");
          td.appendChild(iconTd);
          tr.appendChild(td);
          if (that.stats.pPos.x === x && that.stats.pPos.y === y) {
            item = 7;
          }
          return that.setTd(td, item);
        });
        return that.els.table.appendChild(tr);
      });
    },
    setTd: function(td, type) {
      var icon, iconTd;
      icon = blocks[type];
      iconTd = td.childNodes[0];
      td.className = "color-" + icon;
      iconTd.className = "icon-" + icon;
      return td;
    },
    movePlayer: function(xMod, yMod) {
      var pos, posNew;
      pos = this.stats.pPos;
      return posNew = {
        x: pos.x + xMod,
        y: pos.y + yMod
      };
    },
    swapTwoFields: function(posA, posB) {},
    initRandomFields: function() {
      var arr, rnd, val, x, y, _results;
      y = this.stats.size.y;
      arr = this.stats.items = [];
      _results = [];
      while (y--) {
        x = this.stats.size.x;
        arr[y] = [];
        _results.push((function() {
          var _results1;
          _results1 = [];
          while (x--) {
            rnd = Math.random() * 2;
            val = rnd < .25 ? 0 : rnd > 1.75 ? 1 : 2;
            _results1.push(arr[y][x] = val);
          }
          return _results1;
        })());
      }
      return _results;
    },
    getRndColor: function() {
      var max, range;
      range = this.stats.level + 2;
      max = 10;
      if (range >= max) {
        range = max;
      }
      return Math.floor(Math.random() * range);
    },
    updateStats: function(n, col) {
      var bonus, score;
      bonus = col < 3 ? 20 : 60 * col;
      score = n * n * bonus;
      this.stats.moves += moves + bonMoves;
      if ((this.stats.score / (2000 * (this.stats.level + 1))) > this.stats.level) {
        this.stats.level += 1;
      }
      this.stats.score += score;
      this.els.moves.innerHTML = this.stats.moves;
      this.els.level.innerHTML = this.stats.level;
      return this.els.score.innerHTML = this.stats.score;
    }
  };
  startGameBtn.addEventListener("click", function() {
    return turnbasedGame.start();
  });
  turnbasedGame.start();
  window.left = function() {
    return turnbasedGame.movePlayer(-1, 0);
  };
  return window.right = function() {
    return turnbasedGame.movePlayer(1, 0);
  };
};

window.onload = function() {
  var eventIO;
  window.ctrl = {};
  eventIO = io.connect('http://localhost:3000/eventRouter');
  eventIO.on("ctrl", function(v) {
    return window.ctrl[v]();
  });
  document.addEventListener("keyup", function(e) {
    var action, evt, key, _base;
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
    return typeof (_base = window.ctrl)[action] === "function" ? _base[action]() : void 0;
  });
  return init();
};

//# sourceMappingURL=turnbased.js.map
