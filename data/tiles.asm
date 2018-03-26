;****************************************************************
; Tiles                                                         ;                           
; Tile mappings                                                 ;
;****************************************************************

;****************************************************************
; Constants                                                     ;                           
;****************************************************************

METATILE_ID_EMPTY         = $00
METATILE_ID_BACKGROUND    = METATILE_ID_EMPTY + $01
METATILE_ID_WALL          = METATILE_ID_BACKGROUND + $01
METATILE_ID_GUN_RIGHT     = METATILE_ID_WALL + $01
METATILE_ID_GUN_DOWN      = METATILE_ID_GUN_RIGHT + $01
METATILE_ID_GUN_LEFT      = METATILE_ID_GUN_DOWN + $01
METATILE_ID_GUN_UP        = METATILE_ID_GUN_LEFT + $01
METATILE_ID_TARGET        = METATILE_ID_GUN_UP + $01
METATILE_ID_CHECKPOINT    = METATILE_ID_TARGET + $01 
METATILE_ID_CHECKPOINT_2  = METATILE_ID_CHECKPOINT + $01 
METATILE_ID_MIRROR_F      = METATILE_ID_CHECKPOINT_2 + $01
METATILE_ID_MIRROR_B      = METATILE_ID_MIRROR_F + $01
METATILE_ID_DISP_F        = METATILE_ID_MIRROR_B + $01
METATILE_ID_DISP_B        = METATILE_ID_DISP_F + $01
                          
FIRST_AV_EL_METATILE      = METATILE_ID_MIRROR_F  ; everything with id >= this can be deleted

C_T = CLEAR_TILE

;****************************************************************
; Tiles                                                         ;                           
;****************************************************************

tiles:
  .byte C_T, C_T, C_T, C_T  ; METATILE_ID_EMPTY
  .byte $14, $14, $14, $14  ; METATILE_ID_BACKGROUND
  .byte $00, $00, $00, $00  ; METATILE_ID_WALL
  .byte $20, $21, $30, $31  ; METATILE_ID_GUN_RIGHT
  .byte $22, $23, $32, $33  ; METATILE_ID_GUN_DOWN 
  .byte $24, $25, $34, $35  ; METATILE_ID_GUN_LEFT 
  .byte $26, $27, $36, $37  ; METATILE_ID_GUN_UP     
  .byte $28, $29, $38, $39  ; METATILE_ID_TARGET
  .byte $40, $41, $50, $51  ; METATILE_ID_CHECKPOINT
  .byte $40, $41, $50, $51  ; METATILE_ID_CHECKPOINT_2
  .byte $01, $02, $11, $12  ; METATIlE_ID_MIRROR_F
  .byte $07, $08, $17, $18  ; METATIlE_ID_MIRROR_B
  .byte $01, $02, $11, $12  ; METATIlE_ID_DISP_F
  .byte $07, $08, $17, $18  ; METATIlE_ID_DISP_B
  
tilesHitUp:
  .byte $0E, $0F, $0E, $0F  ; METATILE_ID_EMPTY
  .byte $14, $14, $14, $14  ; METATILE_ID_BACKGROUND
  .byte $00, $00, $00, $00  ; METATILE_ID_WALL (no change)
  .byte $20, $21, $30, $31  ; METATILE_ID_GUN_RIGHT (no change)
  .byte $22, $23, $32, $33  ; METATILE_ID_GUN_DOWN (no change)
  .byte $24, $25, $34, $35  ; METATILE_ID_GUN_LEFT (no change)
  .byte $26, $27, $36, $37  ; METATILE_ID_GUN_UP (no change)
  .byte $28, $29, $38, $39  ; METATILE_ID_TARGET (no change)
  .byte $42, $43, $52, $53  ; METATILE_ID_CHECKPOINT
  .byte $42, $43, $52, $53  ; METATILE_ID_CHECKPOINT_2
  .byte $03, $04, $13, $12  ; METATIlE_ID_MIRROR_F
  .byte $0B, $0C, $17, $1C  ; METATIlE_ID_MIRROR_B
  .byte $03, $04, $3E, $3F  ; METATIlE_ID_DISP_F
  .byte $0B, $0C, $3C, $3D  ; METATIlE_ID_DISP_B
  
tilesHitRight:
  .byte $0D, $0D, $1D, $1D  ; METATILE_ID_EMPTY
  .byte $14, $14, $14, $14  ; METATILE_ID_BACKGROUND
  .byte $00, $00, $00, $00  ; METATILE_ID_WALL (no change)
  .byte $20, $21, $30, $31  ; METATILE_ID_GUN_RIGHT (no change)
  .byte $22, $23, $32, $33  ; METATILE_ID_GUN_DOWN (no change)
  .byte $24, $25, $34, $35  ; METATILE_ID_GUN_LEFT (no change)
  .byte $26, $27, $36, $37  ; METATILE_ID_GUN_UP (no change)
  .byte $28, $29, $38, $39  ; METATILE_ID_TARGET (no change)
  .byte $44, $45, $54, $55  ; METATILE_ID_CHECKPOINT
  .byte $44, $45, $54, $55  ; METATILE_ID_CHECKPOINT_2
  .byte $01, $06, $15, $16  ; METATIlE_ID_MIRROR_F
  .byte $0B, $0C, $17, $1C  ; METATIlE_ID_MIRROR_B
  .byte $2A, $06, $3A, $16  ; METATIlE_ID_DISP_F
  .byte $2B, $0C, $3B, $1C  ; METATIlE_ID_DISP_B

tilesHitDown:
  .byte $0E, $0F, $0E, $0F  ; METATILE_ID_EMPTY
  .byte $14, $14, $14, $14  ; METATILE_ID_BACKGROUND
  .byte $00, $00, $00, $00  ; METATILE_ID_WALL (no change)
  .byte $20, $21, $30, $31  ; METATILE_ID_GUN_RIGHT (no change)
  .byte $22, $23, $32, $33  ; METATILE_ID_GUN_DOWN (no change)
  .byte $24, $25, $34, $35  ; METATILE_ID_GUN_LEFT (no change)
  .byte $26, $27, $36, $37  ; METATILE_ID_GUN_UP (no change)
  .byte $28, $29, $38, $39  ; METATILE_ID_TARGET (no change)
  .byte $42, $43, $52, $53  ; METATILE_ID_CHECKPOINT  
  .byte $42, $43, $52, $53  ; METATILE_ID_CHECKPOINT_2
  .byte $01, $06, $15, $16  ; METATIlE_ID_MIRROR_F
  .byte $09, $08, $19, $1A  ; METATIlE_ID_MIRROR_B
  .byte $2C, $2D, $15, $16  ; METATIlE_ID_DISP_F
  .byte $2B, $1B, $19, $1A  ; METATIlE_ID_DISP_B

tilesHitLeft:
  .byte $0D, $0D, $1D, $1D  ; METATILE_ID_EMPTY
  .byte $14, $14, $14, $14  ; METATILE_ID_BACKGROUND
  .byte $00, $00, $00, $00  ; METATILE_ID_WALL (no change)
  .byte $20, $21, $30, $31  ; METATILE_ID_GUN_RIGHT (no change)
  .byte $22, $23, $32, $33  ; METATILE_ID_GUN_DOWN (no change)
  .byte $24, $25, $34, $35  ; METATILE_ID_GUN_LEFT (no change)
  .byte $26, $27, $36, $37  ; METATILE_ID_GUN_UP (no change)
  .byte $28, $29, $38, $39  ; METATILE_ID_TARGET (no change)
  .byte $44, $45, $54, $55  ; METATILE_ID_CHECKPOINT  
  .byte $44, $45, $54, $55  ; METATILE_ID_CHECKPOINT_2
  .byte $03, $04, $13, $12  ; METATIlE_ID_MIRROR_F
  .byte $09, $08, $19, $1A  ; METATIlE_ID_MIRROR_B
  .byte $03, $2D, $13, $05  ; METATIlE_ID_DISP_F
  .byte $09, $0A, $19, $3D  ; METATIlE_ID_DISP_B
  
tilesHitTwice:
  .byte $1E, $1F, $2E, $2F  ; METATILE_ID_EMPTY
  .byte $14, $14, $14, $14  ; METATILE_ID_BACKGROUND
  .byte $00, $00, $00, $00  ; METATILE_ID_WALL (no change)
  .byte $20, $21, $30, $31  ; METATILE_ID_GUN_RIGHT (no change)
  .byte $22, $23, $32, $33  ; METATILE_ID_GUN_DOWN (no change)
  .byte $24, $25, $34, $35  ; METATILE_ID_GUN_LEFT (no change)
  .byte $26, $27, $36, $37  ; METATILE_ID_GUN_UP (no change)
  .byte $28, $29, $38, $39  ; METATILE_ID_TARGET (no change)
  .byte $46, $47, $56, $57  ; METATILE_ID_CHECKPOINT
  .byte $46, $47, $56, $57  ; METATILE_ID_CHECKPOINT_2
  .byte $03, $2D, $3A, $16  ; METATIlE_ID_MIRROR_F
  .byte $2B, $0C, $19, $3D  ; METATIlE_ID_MIRROR_B
  .byte $03, $2D, $3A, $16  ; METATIlE_ID_DISP_F
  .byte $2B, $0C, $19, $3D  ; METATIlE_ID_DISP_B

;****************************************************************
; Attributes                                                    ;                           
;****************************************************************
  
attributes:
  .byte $00  ; METATILE_ID_EMPTY
  .byte $01  ; METATILE_ID_BACKGROUND
  .byte $00  ; METATILE_ID_WALL
  .byte $01  ; METATILE_ID_GUN_RIGHT
  .byte $01  ; METATILE_ID_GUN_DOWN 
  .byte $01  ; METATILE_ID_GUN_LEFT 
  .byte $01  ; METATILE_ID_GUN_UP   
  .byte $01  ; METATILE_ID_TARGET
  .byte $02  ; METATILE_ID_CHECKPOINT
  .byte $03  ; METATILE_ID_CHECKPOINT_2
  .byte $01  ; METATILE_ID_MIRROR_F
  .byte $01  ; METATILE_ID_MIRROR_B
  .byte $02  ; METATILE_ID_DISP_F
  .byte $02  ; METATILE_ID_DISP_B
  
attributesLit:
  .byte $00  ; METATILE_ID_EMPTY (no change)
  .byte $01  ; METATILE_ID_BACKGROUND
  .byte $00  ; METATILE_ID_WALL (no change)
  .byte $01  ; METATILE_ID_GUN_RIGHT (no change)
  .byte $01  ; METATILE_ID_GUN_DOWN (no change)
  .byte $01  ; METATILE_ID_GUN_LEFT (no change)
  .byte $01  ; METATILE_ID_GUN_UP (no change)
  .byte $02  ; METATILE_ID_TARGET
  .byte $00  ; METATILE_ID_CHECKPOINT
  .byte $00  ; METATILE_ID_CHECKPOINT_2
  .byte $01  ; METATILE_ID_MIRROR_F (no change)
  .byte $01  ; METATILE_ID_MIRROR_B (no change)
  .byte $02  ; METATILE_ID_DISP_F (no change)
  .byte $02  ; METATILE_ID_DISP_B (no change)