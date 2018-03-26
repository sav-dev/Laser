  .byte $08, $08
  .byte $08
    .byte $01, $04, WALL_DIRECTION_DOWN, $04
    .byte $02, $07, WALL_DIRECTION_RIGHT, $02
    .byte $03, $05, WALL_DIRECTION_RIGHT, $01
    .byte $04, $01, WALL_DIRECTION_RIGHT, $04
    .byte $05, $03, WALL_DIRECTION_RIGHT, $01
    .byte $06, $07, WALL_DIRECTION_RIGHT, $02
    .byte $07, $02, WALL_DIRECTION_DOWN, $02
    .byte $07, $06, WALL_DIRECTION_RIGHT, $01
  .byte $06
    .byte METATILE_ID_CHECKPOINT_2, $01, $01
    .byte METATILE_ID_GUN_RIGHT, $02, $02
    .byte METATILE_ID_TARGET, $04, $07
    .byte METATILE_ID_CHECKPOINT, $05, $05
    .byte METATILE_ID_GUN_DOWN, $06, $02
    .byte METATILE_ID_TARGET, $07, $04
  .byte $04
    .byte METATILE_ID_MIRROR_F, $02
    .byte METATILE_ID_MIRROR_B, $04
    .byte METATILE_ID_DISP_F, $01
    .byte METATILE_ID_DISP_B, $01
