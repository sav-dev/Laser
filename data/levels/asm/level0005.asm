  .byte $07, $06
  .byte $05
    .byte $06, $01, WALL_DIRECTION_DOWN, $05
    .byte $01, $02, WALL_DIRECTION_DOWN, $04
    .byte $02, $05, WALL_DIRECTION_RIGHT, $02
    .byte $05, $01, WALL_DIRECTION_DOWN, $02
    .byte $05, $05, WALL_DIRECTION_RIGHT, $01
  .byte $08
    .byte METATILE_ID_GUN_RIGHT, $01, $01
    .byte METATILE_ID_CHECKPOINT, $02, $02
    .byte METATILE_ID_CHECKPOINT, $02, $04
    .byte METATILE_ID_CHECKPOINT, $03, $01
    .byte METATILE_ID_CHECKPOINT, $03, $03
    .byte METATILE_ID_CHECKPOINT, $04, $02
    .byte METATILE_ID_CHECKPOINT, $04, $04
    .byte METATILE_ID_TARGET, $04, $05
  .byte $03
    .byte METATILE_ID_MIRROR_F, $01
    .byte METATILE_ID_MIRROR_B, $03
    .byte METATILE_ID_DISP_B, $01
