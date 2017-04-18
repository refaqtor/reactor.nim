# TEST.
discard """@[5, 6]
@[5]
@[6]
1
2
3
Error in ignored future

Asynchronous trace:
test_streams_close.nim(44) test3

Error: reader closed [Exception]"""

import reactor/async, reactor/loop

proc test1() {.async.} =
  let (input, output) = newInputOutputPair[int]()

  await output.send(5)
  await output.send(6)
  output.sendClose(JustClose)

  (await input.receiveAll(2)).echo

proc test2() {.async.} =
  let (input, output) = newInputOutputPair[int]()

  await output.send(5)
  await output.send(6)
  output.sendClose(JustClose)

  (await input.receiveAll(1)).echo
  (await input.receiveSome(10)).echo

proc test3() {.async.} =
  let (stream, output) = newInputOutputPair[int]()

  echo "1"
  await output.send(1)
  echo "2"
  stream.recvClose(newException(ValueError, "reader closed"))
  echo "3"
  await output.send(5)
  echo "4"

test1().ignore()
test2().ignore()
test3().ignore()
runLoop()
