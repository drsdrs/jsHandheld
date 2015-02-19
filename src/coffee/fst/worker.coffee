genWorker = ()->
  response = 'self.onmessage=function(e){postMessage(2*2+10+e.data);}'
  worker =
    new Worker URL.createObjectURL(
      new Blob([ response ], type: 'application/javascript')
    )


worker = genWorker()
worker.postMessage('Testit')
worker.onmessage = (e) ->
  e.data == 'msg from worker'
  c.l e.data

