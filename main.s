.include "./macros.s"
.include "./config.s"
.include "./drawNgon.s"
.include "./drawRect.s"

.drawAlways:
## orig
  blrl
## setup
  stwu r1, -spAdd(r1)
  stmw spReg, spRegOff(r1)

  lis r0, (0x40-logQ)<<8|4 # (-logQ, u8)
  mtspr 912+gqr.q, r0

  lis rConf, .conf@ha
  la  rConf, .conf@l(rConf)

### setup GX params
  addi r3, r1, spOffG
  mr r4, r22 # r22: JUTRect {0, 0, video.width, video.height}
  bl J2DOrthoGraph.J2DOrthoGraph$0 # return this
### line width
  li r0, lineWidth
  stb r0, 0x38(r3)
### mtx
  lwz r0, .conf.mtx.scale-.conf(rConf)
  stw r0, 0x84+0x10*0+0x4*0(r3) # Sxx [0][0]
  stw r0, 0x84+0x10*1+0x4*1(r3) # Syy [1][1]
  psq_l f0, .conf.mtx.xy-.conf(rConf), 0, gqr.s16
  ps_merge10 f1, f0, f0
  psq_st f0, 0x84+0x10*0+0x4*3(r3), 1, gqr0 # dx [0][3]
  psq_st f1, 0x84+0x10*1+0x4*3(r3), 1, gqr0 # dy [1][3]
### setup2D
  bl J2DOrthoGraph.setPort
### GXSetBlendMode(GX_BM_BLEND, GX_BL_SRCALPHA, GX_BL_INVSRCALPHA, GX_LO_CLEAR)
  li r3, -1
  li r4, 1
  bl GC2D.Hx_GxInit

### sin, cos table
  lwz rSinTable, jmaSinTable$r13(r13)
  mr. rSinTable, rSinTable
  beq- .done
  lwz rCosTable, jmaCosTable$r13(r13)

### var
  li rZero, 0
  lis rGX, 0xCC00
  ori rGX, rGX, 0x8000
  lis rPad, mPadStatus@ha
  lhzu rBtn, mPadStatus@l(rPad)
.set aPad0, 0

.draw.bg:
  .set aData0, .conf.bg
  la rData, aData0-.conf(rConf)
  li r3, GX_TRIANGLEFAN
  li r5, 4
  lwz rColor, .conf.bg.color-aData0(rData)
  bl drawRect

.draw.button:
  .set aData1, .conf.button
  .setDataEnd .conf.button.end
.draw.button.loop:
### fill
  lbz r4, .Ngon.$m(rData) # mask
  rlwnm. r4, rBtn, r4, 0x1
  beq+ .draw.button.loop.stroke
  li r3, GX_TRIANGLEFAN
  li r5, .Ngon.nCircle
  bl drawNgon
  ### go back to the same Ngon
  subi rData, rData, .Ngon.size
.draw.button.loop.stroke:
### stroke
  li r3, GX_LINESTRIP
  li r5, .Ngon.nCircle+1
  bl drawNgon
.draw.button.loop.next:
  cmplw rData, rDataEnd
  blt+ .draw.button.loop

.draw.trigger:
  .setDataEnd .conf.trigger.end
  .set aPadU, 4
  .set aPad1, mPadButton$mPadStatus+0x10-aPadU # [0x10]=L(float)
  la rPad, aPad1-aPad0(rPad)
.draw.trigger.loop:
### fill
  lbz r4, 4(rData) # mask
  rlwnm. r4, rBtn, r4, 0x1
  psq_l f0, .TriggerInfo$stroke.x1(rData), 1, gqr.u8
  lfsu f1, 4(rPad)
  bne- .draw.trigger.loop.fill.draw
#### analog
/**
 * f0 = x0
 * f1 = input
 * f2 = w
 * ans = w*input+x0 = f1*f2+f0
 */
  psq_l f0, .TriggerInfo$fill.x0(rData), 1, gqr.u8
  psq_l f2, .TriggerInfo$width.analog(rData), 1, gqr.s8
  fmadds f0, f1, f2, f0
.draw.trigger.loop.fill.draw:
  psq_st f0, .TriggerInfo$fill.x1(rData), 1, gqr.u8
  li r3, GX_TRIANGLEFAN
  li r5, 4
  lwz rColor, .conf.trigger.fill-.conf(rConf)
  bl drawRect
  addi rData, rData, .TriggerInfo.size
### stroke
  li r3, GX_LINESTRIP
  li r5, 5
  lwz rColor, .conf.trigger.stroke-.conf(rConf)
  bl drawRect
.draw.trigger.loop.next:
  cmplw rData, rDataEnd
  blt+ .draw.trigger.loop
.set aPad0, aPad1+aPadU*2

.draw.stick:
  .setDataEnd .conf.stick.end
  .set aPadU, mPadSStick$mPadStatus-mPadMStick$mPadStatus
  .set aPad1, mPadMStick$mPadStatus-aPadU
  la rPad, aPad1-aPad0(rPad)
.draw.stick.loop:
### fill
#### update (x, y)
  psq_l f0, .Ngon.$x+.Ngon.size(rData), 0, gqr.u8 # (x0, y0) (from next Ngon)
  psq_lu f1, aPadU(rPad), 0, gqr0 # input
  ps_neg f2, f1 # -input
  ps_merge01 f1, f1, f2 # (input.x, -input.y)
  psq_l f2, .Ngon.$m(rData), 1, gqr.u8 # StickMove
  ps_madds0 f0, f1, f2, f0 # input*StickMove+(x0, y0)
  psq_st f0, .Ngon.$x(rData), 0, gqr.u8
#### draw
  li r3, GX_TRIANGLEFAN
  li r5, .Ngon.nCircle
  bl drawNgon
### stroke
  li r3, GX_LINESTRIP
  li r5, 8+1
  bl drawNgon
.draw.stick.loop.next:
  cmplw rData, rDataEnd
  blt .draw.stick.loop

.done:
  lmw spReg, spRegOff(r1)
  addi r1, r1, spAdd
  b 4+$b$.drawAlways
