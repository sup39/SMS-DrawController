/**
 * r3: GXPrimitive
 * r5: n (MUST be 4 or 5)
 * rData: {x0: u8, y0: u8, x1: u8, y1: u8}
 *
 * rData += .Rect.size
 */

.set rIdx, rFVar0

drawRect:
  addi rIdx, r5, 0
  mflr rLR

## GXBegin()
  li r4, 0
  bl GXBegin

drawRect.loop:
## x
  rlwinm r0, rIdx, 0, 0x2
  psq_lx f0, rData, r0, 1, gqr.q
  psq_st f0, 0(rGX), 1, gqr.dq
## y
  addic. rIdx, rIdx, -1
  rlwinm r0, rIdx, 0, 0x2
  ori r0, r0, 1
  psq_lx f0, rData, r0, 1, gqr.q
  psq_st f0, 0(rGX), 1, gqr.dq
## z = 0
  sth rZero, 0(rGX)
## color
  stw rColor, 0(rGX)
## next
  bgt+ drawRect.loop

drawRect.done:
  addi rData, rData, .Rect.size
  mtlr rLR
  blr
