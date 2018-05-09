import mofuw

proc h(req: mofuwReq, res: mofuwRes) {.async.} =
  if req.getPath == "/plaintext":
    mofuwResp(HTTP200, "text/plain", "Hello, World!")
  else:
    mofuwResp(HTTP404, "text/plain", "NOT FOUND")

h.mofuwRun(port = 8080)