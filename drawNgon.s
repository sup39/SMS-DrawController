/**
 * r3: GXPrimitive
 * r5: n (MUST be 2**n or 2**n+1)
 * rData: {x: u16, y: u16, r: u16, mask: u16, color: u32}
 *
 * rData += .Ngon.size
 */

.set rIdx, rFVar0
.set rShift, rFVar1
.set fXY, 2
.set fR, 3

drawNgon:
  addi rIdx, r5, -1
  mflr rLR

  /**
   * cntlzw(n) = 31-log(n)
   * shift = 16-log(n)-jmaSinShift+2
   *       = cntlzw(n)-(31-18+jmaSinShift)
   */
  cntlzw rShift, r5
  subi rShift, rShift, 31-18+jmaSinShift

## GXBegin()
  li r4, 0
  bl GXBegin

## load (x, y), (r), (color)
  psq_l fXY, .Ngon.$x(rData), 0, gqr.q
  psq_l fR, .Ngon.$r(rData), 1, gqr.q
  lwz rColor, .Ngon.$color(rData)

drawNgon.loop:
  rlwnm r0, rIdx, rShift, 32-18+jmaSinShift, 31-2
  lfsx f0, rCosTable, r0
  lfsx f1, rSinTable, r0
  ps_merge00 f0, f0, f1
## (x, y) = (cos, sin) * r.ps0 + (x0, y0)
  ps_madds0 f0, f0, fR, fXY
  psq_st f0, 0(rGX), 0, gqr.dq
## z = 0
  sth rZero, 0(rGX)
## color
  stw rColor, 0(rGX)
## next
  addic. rIdx, rIdx, -1
  bge+ drawNgon.loop

drawNgon.done:
  addi rData, rData, .Ngon.size
  mtlr rLR
  blr
