genInstrumentView = ()->
  instruments = project.instruments||null
  if project.instruments? then instruments = project.instruments
  else console.log "no instrument data"
  instrumentBoxEl = document.getElementById("instrumentBox")
  instrumentsEl = document.createElement("div")
  instrumentSelectEl = document.createElement("select")

  changeInstrument = (e)->
    targetInstr = instrumentBoxEl.getElementsByClassName(e.target.value)[0]
    instrs = instrumentBoxEl.getElementsByClassName("instrument")
    for instr,i in instrs
      if instr!=targetInstr then instr.style.display = "none"
      else targetInstr.style.display = "block"

  instrumentSelectEl.addEventListener "change", changeInstrument

  instrumentBoxEl.innerHTML = ""
  instrumentBoxEl.appendChild instrumentSelectEl

  for key, val of instruments
    instrumentOptionEl = document.createElement("option")
    instrumentEl = document.createElement("div")
    h2El = document.createElement("h2")
    formulaEl = document.createElement("input")
    loadSampleEl = document.createElement("a")

    formulaEl.addEventListener "change", (e) ->
      name = this.className
      c.l name
      project.instruments[name].formula = e.target.value

    h2El.innerHTML = key
    instrumentEl.classList.add key,"instrument"
    formulaEl.value = val.formula
    formulaEl.classList.add key
    instrumentOptionEl.innerHTML = key

    instrumentSelectEl.appendChild instrumentOptionEl

    instrumentEl.appendChild h2El
    instrumentEl.appendChild formulaEl
    instrumentEl.appendChild loadSampleEl

    instrumentsEl.appendChild instrumentEl

    instrumentBoxEl.appendChild instrumentEl


  #init first instrument
  changeInstrument target: instrumentBoxEl.querySelector("option")
