.set rFVar0, 31
.set rFVar1, 30
.set rSinTable, 29
.set rCosTable, 28
.set rGX, 27
.set rZero, 26
.set rLR, 25
.set rConf, 24
.set rData, 23
.set rDataEnd, 22
.set rPad, 21
.set rBtn, 20
.set rColor, 19
.set gqr.u8, 2 # GQR2 = 0x4004
.set gqr.u16, 3 # GQR3 = 0x5005
.set gqr.s8, 4 # GQR4 = 0x6006
.set gqr.s16, 5 # GQR5 = 0x7007

.set gqr.q, 7
.set gqr.dq, gqr.u16

.set spAdd, 0x150
.set spReg, 19
.set spRegOff, 0x8
.set spOffG, 0x50

.set jmaSinShift, 4
.set GX_LINESTRIP, 0xB0
.set GX_TRIANGLEFAN, 0xA0

.set PRESS_Z, 0x0010
.set PRESS_R, 0x0020
.set PRESS_L, 0x0040
.set PRESS_A, 0x0100
.set PRESS_B, 0x0200
.set PRESS_X, 0x0400
.set PRESS_Y, 0x0800
.set PRESS_S, 0x1000
.set SHIFT_Z, 32-4
.set SHIFT_R, 32-5
.set SHIFT_L, 32-6
.set SHIFT_A, 32-8
.set SHIFT_B, 32-9
.set SHIFT_X, 32-10
.set SHIFT_Y, 32-11
.set SHIFT_S, 32-12

mPadButton$mPadStatus = 0x30;
mPadMStick$mPadStatus = 0xf0;
mPadSStick$mPadStatus = 0x130;

.macro li32 reg val
  lis \reg, \val@h
  ori \reg, \reg, \val@l
.endm

.macro .setDataEnd l
  .set aData0, aData1
  .set aData1, \l
  addi rDataEnd, rData, aData1-aData0
.endm

.macro .Ngon x y r m color
  .byte \x, \y, \r, \m
  .long \color
.endm
.set .Ngon.size, 0x8
.set .Ngon.nCircle, 32
.set .Ngon.$x, 0
.set .Ngon.$r, 2
.set .Ngon.$m, 3
.set .Ngon.$color, 4

.macro .Rect x0 y0 x1 y1
  .byte \x0, \y0, \x1, \y1
.endm
.set .Rect.size, 0x4

.macro .TriggerInfo shift wa
  .byte \shift, \wa
.endm
.set .TriggerInfo.size, 0x2
.set .TriggerInfo$fill.x0, 0
.set .TriggerInfo$fill.x1, 2
.set .TriggerInfo$width.analog, 5
.set .TriggerInfo$stroke.x1, .Rect.size+.TriggerInfo.size+.TriggerInfo$fill.x1
