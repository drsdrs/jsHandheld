genpatterns = ()->
  patterns = project.patterns

  patternBoxEl = document.getElementById("patternBox")
  patternSelectEl = document.createElement("select")
  tableEl = document.createElement("table")
  
  patternBoxEl.innerHTML = ""
  patternBoxEl.appendChild patternSelectEl
  patternBoxEl.appendChild tableEl


  genPattern = (patternName)->
    tableEl.innerHTML = ""

  genCollectionSelect = (collection)->
    appendOption = (key)->
      patternOptionEl = document.createElement("option")
      patternEl = document.createElement("div")
      patternOptionEl.addEventListener "click", (e) ->
        sel = e.target.value
        if sel=="new"
          genKeyField("letters", (e)->appendOption e)
          patternSelectEl.blur()
        else genPattern sel


      patternEl.classList.add key,"pattern"
      patternOptionEl.innerHTML = key

      patternSelectEl.appendChild patternOptionEl

    appendOption "new"
    for key, val of patterns then appendOption key

  genCollectionSelect()

