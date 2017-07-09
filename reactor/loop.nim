include reactor/uv/uvloop

type
  LoopExecutorWithArg*[T] = ref object
    callback*: proc(t: T)
    arg*: T
    executor: LoopExecutor

proc enable*(self: LoopExecutorWithArg) =
  self.executor.enable()

proc newLoopExecutorWithArg*[T](): LoopExecutorWithArg[T] =
  let self = new(LoopExecutorWithArg[T])
  self.executor = newLoopExecutor()
  self.callback = proc(t: T) = return
  proc callback() = self.callback(self.arg)

  self.executor.callback = callback
  return self

proc initThreadLoop*() =
  ## Initializes the event loop for this thread.
  ##
  ## Call ``destroyThreadLoop`` before returning from the thread to avoid memory leak.
  initThreadLoopImpl()

proc destroyThreadLoop*() =
  ## Destroys the event loop for this thread.
  destroyThreadLoopImpl()

var callSoonExecutor {.threadvar.}: LoopExecutor
var callSoonList {.threadvar.}: seq[proc()]

proc callSoon*(p: proc()) =
  if callSoonExecutor == nil:
    callSoonExecutor = newLoopExecutor()
    callSoonList = @[]
    callSoonExecutor.callback = proc() =
      let copied = callSoonList
      callSoonList = @[]
      for item in copied:
        item()

      if callSoonList.len == 0:
        callSoonExecutor.disable

  callSoonList.add(p)
  callSoonExecutor.enable
