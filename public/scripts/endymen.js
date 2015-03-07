var init;

init = function() {
  var blocks, endymenGame, gameScreen, highScore, startGameBtn, startScreen;
  console.log("INIT363");
  gameScreen = document.getElementById("gameScreen");
  startScreen = document.getElementById("startScreen");
  startGameBtn = document.getElementById("startGameBtn");
  highScore = document.getElementById("highScore");
  blocks = ["happy", "fire", "cog", "pacman", "skeletor", "sun-fill", "bomb", "neutral", "frustrated"];
  endymenGame = {
    els: {
      table: document.getElementById("table"),
      score: document.getElementById("score"),
      level: document.getElementById("level"),
      moves: document.getElementById("moves")
    },
    stats: {
      size: {
        x: 12,
        y: 9
      },
      level: 0,
      score: 0,
      moves: 0,
      items: []
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
          td.addEventListener("click", function() {
            return that.startSearch(x, y);
          });
          td.click = function() {
            return that.startSearch(x, y);
          };
          td.appendChild(iconTd);
          tr.appendChild(td);
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
      iconTd.className = " icon-" + icon;
      return td;
    },
    initRandomFields: function() {
      var arr, val, x, y, _results;
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
            val = Math.round(Math.random() * 2);
            _results1.push(arr[y][x] = val);
          }
          return _results1;
        })());
      }
      return _results;
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
    it: 0,
    found: 0,
    startSearch: function(x, y) {
      if (this.stats.moves > 0) {
        this.stats.moves--;
        return this.findNext(x, y);
      }
    },
    findNext: function(x, y) {
      var a, col, _ref, _ref1;
      this.it++;
      a = this.stats.items;
      col = a[y][x];
      this.found++;
      a[y][x] = "x";
      if (((_ref = a[y - 1]) != null ? _ref[x] : void 0) === col) {
        this.findNext(x, y - 1);
      }
      if (((_ref1 = a[y + 1]) != null ? _ref1[x] : void 0) === col) {
        this.findNext(x, y + 1);
      }
      if ((a[y][x - 1] != null) && a[y][x - 1] === col) {
        this.findNext(x - 1, y);
      }
      if ((a[y][x + 1] != null) && a[y][x + 1] === col) {
        this.findNext(x + 1, y);
      }
      if (this.it === 1) {
        this.updateStats(this.found + 1, col);
        this.dropDown();
        this.found = 0;
      }
      this.stats.items = a;
      return this.it--;
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
      var bonMoves, bonus, moves, score;
      bonus = col < 3 ? 20 : 60 * col;
      score = n * n * bonus;
      bonMoves = col > 2 ? col - 2 : 0;
      moves = score > 1000 ? 1 : score > 10000 ? 5 : score > 50000 ? 10 : score > 100000 ? 15 : 0;
      this.stats.moves += moves + bonMoves;
      if ((this.stats.score / (2000 * (this.stats.level + 1))) > this.stats.level) {
        this.stats.level += 1;
      }
      this.stats.score += score;
      this.els.moves.innerHTML = this.stats.moves;
      this.els.level.innerHTML = this.stats.level;
      return this.els.score.innerHTML = this.stats.score;
    },
    dropDown: function() {
      var a, dropDowns, h, hh, td, trgPos, v, val, w, x, _i, _len, _ref, _results;
      a = this.stats.items;
      h = a.length;
      w = a[h - 1].length;
      _ref = a[h - 1];
      _results = [];
      for (x = _i = 0, _len = _ref.length; _i < _len; x = ++_i) {
        v = _ref[x];
        hh = h;
        dropDowns = 0;
        while (hh--) {
          if (a[hh][x] === "x") {
            dropDowns++;
          } else if (dropDowns > 0) {
            trgPos = hh + dropDowns;
            td = this.els.table.childNodes[trgPos].childNodes[x];
            val = a[hh][x];
            a[trgPos][x] = val;
            c.l("drop: ", x, hh);
            this.setTd(td, val, true);
          }
        }
        hh = 0;
        _results.push((function() {
          var _results1;
          _results1 = [];
          while (dropDowns--) {
            td = this.els.table.childNodes[dropDowns].childNodes[x];
            val = this.getRndColor();
            a[dropDowns][x] = val;
            _results1.push(this.setTd(td, val, true));
          }
          return _results1;
        }).call(this));
      }
      return _results;
    }
  };
  startGameBtn.addEventListener("click", function() {
    return endymenGame.start();
  });
  endymenGame.start();
  return window.gg = endymenGame;
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

//# sourceMappingURL=endymen.js.map
