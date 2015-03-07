router = require("express").Router()
categories= {
  apps: [
    {name: "camTimelapsMotion", img: "cam"}
    {name: "formulaSampleTracker", img: "fst"}
    {name: "mameVertical", img: "mame"}
    {name: "endymen", img: "*"}
    {name: "SysTools", img: "*"}
  ]
  systools: [
    {name: "shutdown"}
    {name: "update"}
    {name: "jsTerminal"}
  ]
}

router.get "/", (req, res, next) ->
  res.render "index",
    title: "OVERVIEW"
    apps: categories.apps

router.get "/SysTools", (req, res, next) ->
  res.render "index",
    title: "SYSTOOLS"
    apps: categories.systools
    back: true

module.exports = router