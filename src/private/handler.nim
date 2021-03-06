import ctx, io, http
import asyncdispatch

proc handler*(servectx: ServeCtx, ctx: MofuwCtx) {.async.} =
  while true:
    let rcv = await ctx.mofuwRead(servectx.timeOut)
    if rcv == 0: ctx.mofuwClose(); return
    # buffer is full, request is progress
    if unlikely(ctx.buf.len == ctx.bufLen): continue

    case ctx.doubleCRLFCheck()
    of badReq:
      await ctx.badRequest()
      ctx.mofuwClose()
      return
    of bodyLarge:
      await ctx.bodyTooLarge()
      ctx.mofuwClose()
      return
    of continueReq:
      continue
    of endReq:
      if unlikely(not(servectx.hookrequest.isNil)):
        await servectx.hookrequest(ctx)

      let isGETorHEAD = (ctx.getMethod == "GET") or (ctx.getMethod == "HEAD")

      if not isGETorHEAD:
        let res = await haveBodyHandler(ctx, servectx, servectx.handler)
        if not res: return
        continue

      await servectx.handler(ctx)
      ctx.currentBufPos += ctx.bodyStart

      while (ctx.bufLen - ctx.currentBufPos) > 0:
        case ctx.doubleCRLFCheck()
        of endReq:
          await servectx.handler(ctx)
          ctx.currentBufPos += ctx.bodyStart
        else:
          break

      if ctx.respLen != 0: asyncCheck ctx.mofuwWrite()
      ctx.bufLen = 0
      ctx.currentBufPos = 0

      if unlikely(not(servectx.hookresponse.isNil)):
        await servectx.hookresponse(ctx)