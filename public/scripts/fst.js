var activePatternName, demoArr, demoStep, freqTable, fxList, genInstrumentView, genKeyField, genPopup, genWorker, genpatternView, getActiveProjectLs, getFreq, i, initMainCtrl, initTableCtrl, keySets, maxXPos, maxYPos, notation, setActiveProjectLs, socket, tableEl, worker;

initMainCtrl = function() {
  return window.ctrl = {
    left: function() {
      return c.l("up");
    },
    right: function() {
      return c.l("right");
    },
    up: function() {
      return c.l("up");
    },
    down: function() {
      return c.l("down");
    },
    enter: function() {
      return c.l("ENTER");
    },
    back: function() {
      return c.l("BACK");
    }
  };
};

window.onload = function() {
  var eventIO, initProject, loadProject, projectList, saveProject;
  projectList = document.getElementById("projectList");
  eventIO = io.connect('http://localhost:3000/eventRouter');
  socket.on('projectLoaded', function(project) {
    return initProject(project);
  });
  projectList.addEventListener("change", function(e) {
    saveProject();
    return loadProject(e.target.value);
  });
  eventIO.on("ctrl", function(v) {
    return window.ctrl[v]();
  });
  initProject = function(project) {
    window.project = project;
    projectList.value = project.id;
    genInstrumentView();
    return genpatternView();
  };
  saveProject = function() {
    console.log(window.project.patterns.intro.steps[0]);
    return socket.emit("saveProject", window.project);
  };
  loadProject = function(projectName) {
    if (projectName == null) {
      projectName = projectList[1].value;
    }
    return socket.emit("loadProject", projectName);
  };
  loadProject();
  return document.addEventListener("keyup", function(e) {
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
};

window.onunload = function(e) {
  socket.emit("saveProject");
  return socket.close();
};

genInstrumentView = function() {
  var changeInstrument, formulaEl, h2El, instrumentBoxEl, instrumentEl, instrumentOptionEl, instrumentSelectEl, instruments, instrumentsEl, key, loadSampleEl, val;
  instruments = project.instruments || null;
  if (project.instruments != null) {
    instruments = project.instruments;
  } else {
    console.log("no instrument data");
  }
  instrumentBoxEl = document.getElementById("instrumentBox");
  instrumentsEl = document.createElement("div");
  instrumentSelectEl = document.createElement("select");
  changeInstrument = function(e) {
    var i, instr, instrs, targetInstr, _i, _len, _results;
    targetInstr = instrumentBoxEl.getElementsByClassName(e.target.value)[0];
    instrs = instrumentBoxEl.getElementsByClassName("instrument");
    _results = [];
    for (i = _i = 0, _len = instrs.length; _i < _len; i = ++_i) {
      instr = instrs[i];
      if (instr !== targetInstr) {
        _results.push(instr.style.display = "none");
      } else {
        _results.push(targetInstr.style.display = "block");
      }
    }
    return _results;
  };
  instrumentSelectEl.addEventListener("change", changeInstrument);
  instrumentBoxEl.innerHTML = "";
  instrumentBoxEl.appendChild(instrumentSelectEl);
  for (key in instruments) {
    val = instruments[key];
    instrumentOptionEl = document.createElement("option");
    instrumentEl = document.createElement("div");
    h2El = document.createElement("h2");
    formulaEl = document.createElement("input");
    loadSampleEl = document.createElement("a");
    formulaEl.addEventListener("change", function(e) {
      var name;
      name = this.className;
      c.l(name);
      return project.instruments[name].formula = e.target.value;
    });
    h2El.innerHTML = key;
    instrumentEl.classList.add(key, "instrument");
    formulaEl.value = val.formula;
    formulaEl.classList.add(key);
    instrumentOptionEl.innerHTML = key;
    instrumentSelectEl.appendChild(instrumentOptionEl);
    instrumentEl.appendChild(h2El);
    instrumentEl.appendChild(formulaEl);
    instrumentEl.appendChild(loadSampleEl);
    instrumentsEl.appendChild(instrumentEl);
    instrumentBoxEl.appendChild(instrumentEl);
  }
  return changeInstrument({
    target: instrumentBoxEl.querySelector("option")
  });
};

keySets = {
  math: [[0, 1, 2, 3, 4], [5, 6, 7, 8, 9], ["+", "-", "&", "|", "t", ">>", "<<"], ["/", "*", "^", "!", "%", "(", ")"]],
  letters: [["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"], ["a", "s", "d", "f", "g", "h", "j", "k", "l"], ["z", "x", "c", "v", "b", "n", "m"]]
};

genKeyField = function(content, cbOnClose) {
  var closeKeyField, fillKeyField, getActiveData, getActiveRow, inputEl, keyfieldEl, moveActiveData, validateX, validateXClamp, validateY, xpos, ypos;
  if (typeof content === "string" && keySets[content]) {
    content = keySets[content];
  } else if (content == null) {
    return c.l("genKeyField need some content!");
  }
  if (document.getElementById("keyfield") != null) {
    return c.l("keyfieldEl exists!!!!!");
  }
  xpos = 0;
  ypos = 0;
  keyfieldEl = document.createElement("div");
  keyfieldEl.id = "keyField";
  inputEl = document.createElement("input");
  document.body.appendChild(keyfieldEl);
  setTimeout((function() {
    return keyfieldEl.classList.add("open", "h100");
  }), 250);
  getActiveRow = function(y) {
    return keyfieldEl.childNodes[y || ypos];
  };
  getActiveData = function(x) {
    return getActiveRow().childNodes[x || xpos];
  };
  validateX = function(x) {
    var max;
    max = getActiveRow().childNodes.length - 1;
    x = xpos + x;
    return xpos = x > max ? 0 : x < 0 ? max : x;
  };
  validateXClamp = function(yposOld) {
    var max, maxOld;
    max = getActiveRow().childNodes.length - 1;
    maxOld = getActiveRow(yposOld).childNodes.length - 1;
    return xpos = Math.round(max * xpos / maxOld);
  };
  validateY = function(y) {
    var max, yposOld;
    yposOld = ypos;
    max = keyfieldEl.childNodes.length - 1;
    y = ypos + y;
    ypos = y > max ? 0 : y < 0 ? max : y;
    return validateXClamp(yposOld);
  };
  moveActiveData = function() {
    var activeEl;
    if (ypos === 0) {
      xpos = 1;
    }
    activeEl = keyfieldEl.getElementsByClassName("active")[0];
    if (activeEl != null) {
      activeEl.classList.remove("active");
    }
    return getActiveData().classList.add("active");
  };
  window.ctrl.left = function() {
    validateX(-1);
    return moveActiveData();
  };
  window.ctrl.right = function() {
    validateX(+1);
    return moveActiveData();
  };
  window.ctrl.up = function() {
    validateY(-1);
    return moveActiveData();
  };
  window.ctrl.down = function() {
    validateY(+1);
    return moveActiveData();
  };
  window.ctrl.enter = function() {
    var data;
    if (ypos === 0) {
      cbOnClose(inputEl.value);
      return closeKeyField();
    } else {
      data = getActiveData().innerHTML;
      return inputEl.value += data;
    }
  };
  window.ctrl.back = function() {
    return closeKeyField();
  };
  closeKeyField = function() {
    initMainCtrl();
    keyfieldEl.classList.remove("open", "h100");
    return setTimeout((function() {
      return document.body.removeChild(keyfieldEl);
    }), 600);
  };
  fillKeyField = function() {
    var rowEl, rowHeight, submitEl;
    rowEl = document.createElement("div");
    submitEl = document.createElement("button");
    submitEl.innerHTML = "submit";
    rowEl.appendChild(inputEl);
    rowEl.appendChild(submitEl);
    keyfieldEl.appendChild(rowEl);
    rowEl.style.lineHeight = rowHeight * 4.75 + "%";
    rowEl.style.fontSize = rowHeight * 22 + "%";
    rowEl.style.height = rowHeight + "%";
    rowHeight = 100 / content.length;
    return content.forEach(function(cntArr, i) {
      var dataWidth, fontSizePercent;
      rowEl = document.createElement("div");
      rowEl.style.height = rowHeight + "%";
      dataWidth = 100 / cntArr.length;
      fontSizePercent = rowHeight > dataWidth ? dataWidth : rowHeight;
      rowEl.style.lineHeight = rowHeight * 4.75 + "%";
      rowEl.style.fontSize = fontSizePercent * 22 + "%";
      keyfieldEl.appendChild(rowEl);
      return cntArr.forEach(function(data, j) {
        var dataEl;
        dataEl = document.createElement("span");
        rowEl.appendChild(dataEl);
        dataEl.style.width = dataWidth + "%";
        return dataEl.innerHTML = data;
      });
    });
  };
  return fillKeyField();
};

setTimeout((function() {}), 300);

getActiveProjectLs = function() {
  var recentProject;
  recentProject = localStorage.getItem("recentProject");
  if (recentProject != null) {
    return JSON.parse(recentProject);
  }
};

setActiveProjectLs = function(cb) {
  c.l("setActiveProjectLs");
  if (typeof project !== "undefined" && project !== null) {
    localStorage.setItem("recentProject", JSON.stringify(project));
    return typeof cb === "function" ? cb() : void 0;
  }
};

socket = io.connect('http://localhost:3000/formulaSampleTracker');

fxList = ["E", "F", "H"];

notation = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"];

demoStep = {
  note: "C",
  oct: "3",
  vel: "75",
  fx0: "E",
  fx0Val: 0x64
};

getFreq = function(n) {
  return Math.pow(2, (n - 69) / 12) * 440;
};

tableEl = null;

maxXPos = Object.keys(demoStep).length;

maxYPos = 0;

activePatternName = null;

freqTable = [];

i = 128;

while (i--) {
  freqTable[i] = getFreq(i);
}

initTableCtrl = function() {
  var activeEl, checkPos, setActive, setValue, tablePos;
  tablePos = [0, 0];
  activeEl = null;
  checkPos = function() {
    if (tablePos[0] < 1) {
      tablePos[0] = maxXPos;
    } else if (tablePos[0] > maxXPos) {
      tablePos[0] = 1;
    }
    if (tablePos[1] < 0) {
      return tablePos[1] = maxYPos - 1;
    } else if (tablePos[1] >= maxYPos) {
      return tablePos[1] = 0;
    }
  };
  setActive = function() {
    var x, y;
    checkPos();
    x = tablePos[1];
    y = tablePos[0];
    c.l(activeEl);
    if (activeEl != null) {
      activeEl.classList.remove("active");
    }
    activeEl = tableEl.childNodes[x].childNodes[y];
    return activeEl.classList.add("active");
  };
  window.ctrl = {
    left: function() {
      tablePos[0]--;
      return setActive();
    },
    right: function() {
      tablePos[0]++;
      return setActive();
    },
    up: function() {
      tablePos[1]--;
      return setActive();
    },
    down: function() {
      tablePos[1]++;
      return setActive();
    },
    enter: function() {
      return setValue(+1);
    },
    back: function() {
      return setValue(-1);
    }
  };
  return setValue = function(add) {
    var len, pos, set, type, val;
    if (!activeEl) {
      return c.l("noActive");
    }
    val = activeEl.innerHTML;
    type = activeEl.className.split(" ")[0];
    set = function() {
      var row;
      activeEl.innerHTML = val;
      row = tablePos[1];
      project.patterns[activePatternName].steps[row][type] = val;
      return socket.emit("setPatternValue", {
        patternName: activePatternName,
        row: row,
        type: type,
        val: val
      });
    };
    if (type.slice(0, 2) === "fx" && type.slice(3, 6) !== "Val") {
      len = fxList.length;
      pos = val === "=" ? ~~(len / 2) : 0;
      fxList.forEach(function(note, i) {
        if (note === val) {
          return pos = i;
        }
      });
      if (pos == null) {
        pos = ~~(len / 2);
      }
      pos += add;
      if (pos >= len) {
        pos = 0;
      } else if (pos < 0) {
        pos = len - 1;
      }
      val = fxList[pos];
      set();
    } else if (type === "note") {
      len = notation.length;
      pos = val === "=" ? ~~(len / 2) : 0;
      notation.forEach(function(note, i) {
        if (note === val) {
          return pos = i;
        }
      });
      if (pos == null) {
        pos = 0;
      }
      pos += add;
      if (pos >= len) {
        pos = 0;
      } else if (pos < 0) {
        pos = len - 1;
      }
      val = notation[pos];
      set();
    }
    val = parseInt(activeEl.innerHTML);
    if (isNaN(val)) {
      val = 0;
    } else {
      val += add;
    }
    if (type === "oct") {
      if (val >= 12) {
        val = 12;
      } else if (val <= -12) {
        val = -12;
      }
      return set();
    } else if (type === "vel") {
      if (val >= 128) {
        val = 128;
      } else if (val <= 0) {
        val = 0;
      }
      return set();
    } else if (type.slice(3, 6) === "Val") {
      if (val >= 256) {
        val = 256;
      } else if (val <= 0) {
        val = 0;
      }
      return set();
    }
  };
};

genpatternView = function() {
  var appendOption, genCollectionSelect, genPattern, genPatternModOptions, patternBoxEl, patternSelectEl, patterns, ptnConfigEl;
  patterns = project.patterns;
  patternBoxEl = document.getElementById("patternBox");
  ptnConfigEl = document.createElement("div");
  patternSelectEl = document.createElement("select");
  tableEl = document.createElement("table");
  ptnConfigEl.appendChild(patternSelectEl);
  patternBoxEl.innerHTML = "";
  patternBoxEl.appendChild(ptnConfigEl);
  patternBoxEl.appendChild(tableEl);
  patternSelectEl.addEventListener("click", function(e) {
    var sel;
    sel = e.target.value;
    if (sel === "new") {
      genKeyField("letters", function(e) {
        var k, name, v, _ref;
        name = e.innerText;
        _ref = project.patterns;
        for (k in _ref) {
          v = _ref[k];
          if (k === name) {
            name = e.target.value = name + "Dupl";
          }
        }
        patternSelectEl.value = name;
        appendOption(e);
        project.patterns[e] = {
          steps: [{}, {}, {}, {}, {}, {}, {}, {}]
        };
        return socket.emit("updatePattern", {
          name: e,
          data: project.patterns[e]
        });
      });
      return patternSelectEl.blur();
    } else {
      return genPattern(sel);
    }
  });
  genPattern = function(patternName) {
    var TdCnt, genStep, steps;
    activePatternName = patternName || activePatternName;
    tableEl.innerHTML = "";
    TdCnt = 0;
    genStep = function(step) {
      var genTd, k, trEl, v;
      trEl = document.createElement("tr");
      TdCnt++;
      genTd = function(k, data) {
        var tdEl;
        tdEl = document.createElement("td");
        tdEl.classList.add(k);
        tdEl.innerHTML = data || "=";
        return trEl.appendChild(tdEl);
      };
      genTd("pos", TdCnt);
      if (Object.keys(step).length === 0) {
        for (k in demoStep) {
          v = demoStep[k];
          genTd(k, "=");
        }
      } else {
        for (k in demoStep) {
          v = demoStep[k];
          genTd(k, step[k]);
        }
      }
      maxYPos = TdCnt;
      return tableEl.appendChild(trEl);
    };
    steps = project.patterns[activePatternName].steps;
    return steps.forEach(function(step) {
      return genStep(step);
    });
  };
  appendOption = function(key) {
    var patternEl, patternOptionEl;
    patternOptionEl = document.createElement("option");
    patternEl = document.createElement("div");
    patternEl.classList.add(key, "pattern");
    patternOptionEl.innerHTML = key;
    return patternSelectEl.appendChild(patternOptionEl);
  };
  genCollectionSelect = function(collection) {
    var firstVal, key, val;
    appendOption("new");
    for (key in patterns) {
      val = patterns[key];
      appendOption(key);
    }
    firstVal = patternSelectEl[1].innerText;
    patternSelectEl.value = firstVal;
    return genPattern(firstVal);
  };
  genPatternModOptions = function() {
    var genBtn, getSteps, setSteps;
    genBtn = function(content, funct) {
      var btn;
      btn = document.createElement("input");
      btn.type = 'button';
      btn.value = content;
      btn.addEventListener("click", funct);
      ptnConfigEl.appendChild(btn);
      return btn;
    };
    getSteps = function() {
      return project.patterns[activePatternName].steps;
    };
    setSteps = function(steps) {
      return project.patterns[activePatternName].steps = steps;
    };
    genBtn("+1", function(e) {
      getSteps().push({});
      return genPattern();
    });
    genBtn("-1", function(e) {
      getSteps().pop();
      return genPattern();
    });
    genBtn("*2", function(e) {
      var steps, v, _i, _len;
      steps = getSteps();
      for (i = _i = 0, _len = steps.length; _i < _len; i = ++_i) {
        v = steps[i];
        steps.push(v);
      }
      return genPattern();
    });
    genBtn("/2", function(e) {
      var len, steps;
      steps = getSteps();
      len = Math.round(steps.length / 2);
      while (len--) {
        steps.pop();
      }
      return genPattern();
    });
    genBtn("*2C", function(e) {
      var newData, step, steps, _i, _len;
      steps = getSteps();
      newData = [];
      for (i = _i = 0, _len = steps.length; _i < _len; i = ++_i) {
        step = steps[i];
        newData[i * 2] = step;
        newData[(i * 2) + 1] = {};
      }
      setSteps(newData);
      return genPattern();
    });
    genBtn("/2C", function(e) {
      var newData, step, steps, _i, _len;
      steps = getSteps();
      newData = [];
      for (i = _i = 0, _len = steps.length; _i < _len; i = ++_i) {
        step = steps[i];
        if (i % 2 === 0) {
          newData.push(steps[i]);
        }
      }
      setSteps(newData);
      return genPattern();
    });
    return genBtn("RND", function(e) {
      var currentIndex, randomIndex, steps, temporaryValue;
      steps = getSteps();
      currentIndex = steps.length;
      while (0 !== currentIndex) {
        randomIndex = Math.floor(Math.random() * currentIndex);
        currentIndex -= 1;
        temporaryValue = steps[currentIndex];
        steps[currentIndex] = steps[randomIndex];
        steps[randomIndex] = temporaryValue;
      }
      return genPattern();
    });
  };
  genPatternModOptions();
  genCollectionSelect();
  return initTableCtrl();
};

demoArr = [
  "ane", "lko", {
    "po": [
      "222", 2, 3, 4, 5, 6, 7, 6, 5, {
        "2#": [
          "3333", {
            "333#": ["16", "1", "1", "17", "1", "1", "13", "12", "214", "213", "y", "14", "13", "12", "214", "213", "212", "13", "12", "214", "213", "x"]
          }, "3", "33"
        ]
      }, "bu", "11", "1", "1", "15", "1", "1", "13", "a", "b", "b", "c", "11", "1", "1", "15", "1", "1", "13", "a", "b", "b", "c", "11", "1", "1", "15", "1", "1", "13", "a", "b", "b", "c", "hu"
    ]
  }, "JO", "GO"
];

setTimeout((function() {}), 100);

genPopup = function(content, type, cbOnClose) {
  var activeCol, activeColPos, colEl, contentPos, fillCol, getActive, getInArr, popupEl, scrollTarget, setActiveCol;
  contentPos = [];
  activeColPos = -1;
  activeCol = 0;
  popupEl = document.createElement("div");
  colEl = [document.createElement("div"), document.createElement("div")];
  document.body.appendChild(popupEl);
  popupEl.appendChild(colEl[0]);
  popupEl.appendChild(colEl[1]);
  colEl[0].classList.add("col1");
  colEl[1].classList.add("col2");
  popupEl.id = "popup";
  setTimeout((function() {
    return popupEl.classList.add("open", "h100");
  }), 250);
  getActive = function() {
    return popupEl.childNodes[activeCol].childNodes[activeColPos];
  };
  setActiveCol = function(active) {
    activeCol = active;
    colEl[active].classList.add("active");
    return colEl[active ^ 1].classList.remove("active");
  };
  window.ctrl.left = function(e) {
    var el, lastGroup, targetName, trackArr, _i, _len, _ref, _results;
    if (contentPos.length === 0) {
      return;
    }
    targetName = getActive().innerHTML;
    trackArr = content;
    lastGroup = contentPos.pop(targetName);
    if (activeCol === 1) {
      setActiveCol(0);
    } else {
      contentPos.forEach(function(pos) {
        return trackArr = getInArr(trackArr, pos);
      });
      colEl[1].innerHTML = colEl[0].innerHTML;
      fillCol(trackArr);
    }
    _ref = colEl[0].childNodes;
    _results = [];
    for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
      el = _ref[i];
      console.log(lastGroup, el.innerHTML);
      if (lastGroup === el.innerHTML && el.style.fontWeight === "bold") {
        activeColPos = i;
        _results.push(el.classList.add("active"));
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };
  window.ctrl.right = function(e) {
    var targetName, trackArr;
    if (getActive().style.fontWeight === "bold") {
      targetName = getActive().innerHTML;
      trackArr = content;
      contentPos.push(targetName);
      if (activeCol > 0 && colEl[1].innerHTML.length > 0) {
        colEl[0].innerHTML = colEl[1].innerHTML;
      }
      contentPos.forEach(function(pos) {
        return trackArr = getInArr(trackArr, pos);
      });
      setActiveCol(1);
      fillCol(trackArr);
      activeColPos = -1;
      return window.ctrl.down();
    }
  };
  getInArr = function(arr, targetGroup) {
    var data, _i, _len;
    for (i = _i = 0, _len = arr.length; _i < _len; i = ++_i) {
      data = arr[i];
      if (Object.keys(arr[i])[0] === targetGroup) {
        return arr[i][targetGroup];
      }
    }
  };
  fillCol = function(arr) {
    colEl[activeCol].innerHTML = "";
    arr = arr || content;
    return arr.forEach(function(data) {
      var itemEl;
      itemEl = document.createElement("span");
      itemEl.innerHTML = typeof data === "object" ? (itemEl.style.fontWeight = "bold", Object.keys(data)) : data;
      return colEl[activeCol].appendChild(itemEl);
    });
  };
  window.ctrl.enter = function(e) {
    if (getActive().style.fontWeight === "bold") {
      return window.ctrl.right();
    }
    if (typeof cbOnClose === "function") {
      cbOnClose(getActive().innerHTML);
    }
    initMainCtrl();
    popupEl.classList.remove("open", "h100");
    return setTimeout((function() {
      return document.body.removeChild(popupEl);
    }), 600);
  };
  window.ctrl.back = function(e) {
    var _ref;
    if (((_ref = getActive()) != null ? _ref.style.fontWeight : void 0) === "bold" && contentPos.length === 0) {
      return window.ctrl.left();
    }
    initMainCtrl();
    popupEl.classList.remove("open", "h100");
    return setTimeout((function() {
      return document.body.removeChild(popupEl);
    }), 600);
  };
  window.ctrl.up = function(e) {
    var target, targetOld, topSelect;
    targetOld = getActive();
    if (activeColPos <= 0) {
      activeColPos = colEl[activeCol].childNodes.length - 1;
    } else {
      activeColPos--;
    }
    target = getActive();
    target.classList.add("active");
    if (targetOld != null) {
      targetOld.classList.remove("active");
    }
    topSelect = target.clientHeight * activeColPos;
    return scrollTarget(target);
  };
  window.ctrl.down = function(e) {
    var target, targetOld;
    targetOld = getActive();
    if (activeColPos >= colEl[activeCol].childNodes.length - 1) {
      activeColPos = 0;
    } else {
      activeColPos++;
    }
    target = getActive();
    target.classList.add("active");
    if (targetOld != null) {
      targetOld.classList.remove("active");
    }
    return scrollTarget(target);
  };
  scrollTarget = function(target) {
    var topSelect;
    topSelect = target.clientHeight * activeColPos;
    if (topSelect > window.innerHeight / 2) {
      return colEl[activeCol].scrollTop = activeColPos * (colEl[activeCol].clientHeight / colEl[activeCol].childNodes.length);
    } else if (topSelect < window.innerHeight / 2) {
      return colEl[activeCol].scrollTop = activeColPos * (colEl[activeCol].clientHeight / colEl[activeCol].childNodes.length);
    }
  };
  fillCol();
  return colEl[0].classList.add("active");
};

genWorker = function() {
  var response, worker;
  response = 'self.onmessage=function(e){postMessage(2*2+10+e.data);}';
  return worker = new Worker(URL.createObjectURL(new Blob([response], {
    type: 'application/javascript'
  })));
};

worker = genWorker();

worker.postMessage('Testit');

worker.onmessage = function(e) {
  e.data === 'msg from worker';
  return c.l(e.data);
};

//# sourceMappingURL=fst.js.map
