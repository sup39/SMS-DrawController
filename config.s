.set lineWidth, 20
.set logQ, 6 # power of paired single quantized scale

.conf:
.conf.mtx.scale:
  .long (127-logQ)<<23 # 2**-logQ
.conf.mtx.xy:
  .short 16, 330-16

.conf.bg.color:
  .long 0x7f
.conf.trigger.fill:
  .long 0xdfdfdfbf
.conf.trigger.stroke:
  .long 0xeeeeeebf

/** .Rect and .Ngon should be contiguous from this point */
.conf.bg:
  .Rect 0, 0, 182, 120

.conf.button:
  .Ngon 138, 66, 18, SHIFT_A, 0x2ee5b8bf
  .Ngon 113, 89,  9, SHIFT_B, 0xff1a1abf
  .Ngon 164, 50,  8, SHIFT_X, 0xeeeeeebf
  .Ngon 119, 41,  8, SHIFT_Y, 0xeeeeeebf
  .Ngon 144, 34,  6, SHIFT_Z, 0x9494ffbf
  .Ngon  91, 64,  5, SHIFT_S, 0xeeeeeebf
.conf.button.end:

.set TriggerXL, 12
.set TriggerXR, 170
.set TriggerY0, 10
.set TriggerY1, 18
.set TriggerW, 64
.set TriggerWA, 56
.conf.trigger:
# {Fill, Info, Stroke}
## L
  .Rect TriggerXL, TriggerY0, TriggerXL+TriggerW, TriggerY1
  .TriggerInfo SHIFT_L, TriggerWA
  .Rect TriggerXL, TriggerY0, TriggerXL+TriggerW, TriggerY1
## R
  .Rect TriggerXR, TriggerY0, TriggerXR-TriggerW, TriggerY1
  .TriggerInfo SHIFT_R, -TriggerWA
  .Rect TriggerXR, TriggerY0, TriggerXR-TriggerW, TriggerY1
.conf.trigger.end:

.conf.stick:
# MStick Fill (*, *, r, rMove, color)
  .Ngon -1, -1, 12, 14, 0xeeeeeeef
# MStick Stroke (x, y, r, *, color)
  .Ngon 32, 52, 19, -1, 0xeeeeeeef
# CStick Fill
  .Ngon -1, -1, 12, 14, 0xffd300ef
# CStick Stroke
  .Ngon 64, 92, 19, -1, 0xffd300ef
.conf.stick.end:
