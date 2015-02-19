getActiveProjectLs = ()->
  recentProject = localStorage.getItem "recentProject"
  if recentProject?
    return JSON.parse recentProject

setActiveProjectLs = (cb)->
  c.l "setActiveProjectLs"
  if project?
    localStorage.setItem "recentProject",  JSON.stringify project
    cb?()