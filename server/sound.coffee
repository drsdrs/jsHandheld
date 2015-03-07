Readable = require('stream').Readable || require('readable-stream/readable')
Speaker = require('speaker')
soundGens = []
nextBuffer = new Buffer(1)
c = console; c.l = c.log

fxs = [
  {f:"(999999999/t)&(t&t<<2)>>8", l:40000}
  {f:"(((999999999/(t%9999))*Math.sin(t>>9))>>3)&127", l:40000}
  {f:"t^t>>4*Math.sin(t>>11)", l:40000}
  {f:"((t>>t>>2)&t>>8)*(t>>(255&t>>7))", l:29000}
]

Array::clean = (deleteValue) ->
  i = 0
  while i < @length
    if @[i] == deleteValue
      @splice i, 1
      i--
    i++
  @


fillNextBuffer = (n, g, cb)->
  i = 0
  buf = new Buffer(n)
  gLgt = g.length 
  while i < n
    gens = gLgt
    addCnt = 0
    t = 0
    while gens--
      gen = g[gens]
      if gen?
        x = gen.next()
        if !isNaN(x)
          addCnt++
          t += x
    buf.writeUInt8 ((t/addCnt)&255), i
    #c.l t if i%222==0
    i++
  nextBuffer = buf
  cb?()

read = (n) ->
  if n==0&&!n?
    c.l "###->?? n=0 or !n? ---error in read function"
    @push null
  else
    setTimeout (->fillNextBuffer(n, soundGens)), 1
    @push nextBuffer


class SoundGen
  id: (~~Math.random()*999999)+"|"+Date.now()
  length: 44100*2
  formula: "(999999999/t)&(t&t<<2)>>8"
  t: 0
  sampleFunct: null
  constructor: (opts)->
    for k,v of opts then @set k, v
    @makeSampleFunct()
  makeSampleFunct: ()-> @sampleFunct = new Function("t", "return "+@formula)
  next: ->
    if @t<@length
      @t++
      @sampleFunct(@t)
    else
      @destroy()
      return 128
  destroy: ->
    delete @
    soundGens.clean @

  get: (k)-> @[k]
  set: (k,v)->
    @[k]=v
    if k=="formula" then @makeSampleFunct()


addSoundGen = (opts)->
  soundGens.push new SoundGen(opts||null)

addFx = (fxnr)->
  fx = fxs[fxnr]||null
  if fx then addSoundGen formula: fx.f, length: fx.l
  else c.l "cant find fx with nr."+fxnr


readableCfg = 
  bitDepth: 8
  channels: 1
  sampleRate: 44100
  samplesGenerated: 0
  signed: false
  _read: read

readable = new Readable
for k,v of readableCfg then readable[k] = v

speaker = new Speaker
#readable.pipe speaker 

module.exports =
  addSndGen: addSoundGen
  addFx: addFx