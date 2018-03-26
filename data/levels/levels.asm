;****************************************************************
; Levels                                                        ;                           
; Holds information about all levels                            ;
;****************************************************************

; Level data format:
;
; - max x (width - 1) (1 byte)
; - max y (height - 1) (1 byte)
; - number of walls (1 byte)
; - information about walls (4 bytes each)
;   - start x (1 byte)
;   - start y (1 byte)
;   - direction (1 byte)
;   - length (1 byte)
; - number of elements on the map (1 byte)
; - information about the elements (3 bytes each)
;   - object id (1 byte)   
;   - x (1 byte)
;   - y (1 byte)
; - number of available elements (1 byte, 7 elements max)
; - information about available elements (2 bytes each)
;   - object id (1 byte) - the list should be sorted by this
;   - count avaialble (1 byte)
;
; Any changes done to this format must be represented in LevelManager->LoadLevel and StatePreLevel->LoadMinimap

;****************************************************************
; Constants                                                     ;                           
;****************************************************************

WALL_DIRECTION_DOWN   = $00
WALL_DIRECTION_RIGHT  = $01

NUMBER_OF_LEVELS      = $0D

;****************************************************************
; Level List                                                    ;                           
;****************************************************************

levels:
  .byte LOW(level00), HIGH(level00)
  .byte LOW(level01), HIGH(level01)
  .byte LOW(level02), HIGH(level02)
  .byte LOW(level03), HIGH(level03)
  .byte LOW(level04), HIGH(level04)
  .byte LOW(level05), HIGH(level05)
  .byte LOW(level06), HIGH(level06)
  .byte LOW(level07), HIGH(level07)
  .byte LOW(level08), HIGH(level08)
  .byte LOW(level09), HIGH(level09)
  .byte LOW(level10), HIGH(level10)
  .byte LOW(level11), HIGH(level11)
  .byte LOW(level12), HIGH(level12)

  
;****************************************************************
; Level Passwords                                               ;                           
;****************************************************************

passwords:
  .byte CHAR_A, CHAR_I, CHAR_E, CHAR_R ; level00: AIER
  .byte CHAR_S, CHAR_A, CHAR_H, CHAR_R ; level01: SAHR
  .byte CHAR_Q, CHAR_W, CHAR_E, CHAR_I ; level02: QWEI
  .byte CHAR_V, CHAR_F, CHAR_S, CHAR_N ; level03: VFSN
  .byte CHAR_A, CHAR_D, CHAR_R, CHAR_U ; level04: ADRU
  .byte CHAR_C, CHAR_D, CHAR_R, CHAR_I ; level05: CDRI
  .byte CHAR_A, CHAR_S, CHAR_F, CHAR_J ; level06: ASFJ
  .byte CHAR_Z, CHAR_X, CHAR_C, CHAR_N ; level07: ZXCN
  .byte CHAR_S, CHAR_O, CHAR_F, CHAR_R ; level08: SOFR
  .byte CHAR_N, CHAR_J, CHAR_I, CHAR_R ; level09: NJIR
  .byte CHAR_J, CHAR_N, CHAR_H, CHAR_J ; level10: JNHJ
  .byte CHAR_M, CHAR_J, CHAR_U, CHAR_H ; level11: MJUH
  .byte CHAR_R, CHAR_F, CHAR_D, CHAR_W ; level12: RFDW

  
;****************************************************************
; Level Data                                                    ;                           
;****************************************************************

level00:
  .include "data\levels\asm\0_tutorial1.asm"

level01:
  .include "data\levels\asm\0_tutorial2.asm"

level02:
  .include "data\levels\asm\0_tutorial3.asm"

level03:
  .include "data\levels\asm\0_tutorial4.asm"

level04:
  .include "data\levels\asm\level0001.asm"

level05:
  .include "data\levels\asm\level0002.asm"

level06:
  .include "data\levels\asm\level0005.asm"

level07:
  .include "data\levels\asm\level0010.asm"

level08:
  .include "data\levels\asm\level0015.asm"

level09:
  .include "data\levels\asm\level0020.asm"

level10:
  .include "data\levels\asm\level0030.asm"

level11:
  .include "data\levels\asm\level0060.asm"

level12:
  .include "data\levels\asm\level0100.asm"

