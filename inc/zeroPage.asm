;****************************************************************
; List of zero page variables                                   ;
;****************************************************************

  .rsset $0000
  
;****************************************************************
; Pseudo-registers                                              ;
;****************************************************************

b                   .rs 1
c                   .rs 1
d                   .rs 1
e                   .rs 1
f                   .rs 1
g                   .rs 1
h                   .rs 1
i                   .rs 1
j                   .rs 1
k                   .rs 1
l                   .rs 1
m                   .rs 1
n                   .rs 1
o                   .rs 1
p                   .rs 1
q                   .rs 1

;****************************************************************
; Metatile buffering                                            ;
;****************************************************************

bTilesRow0High      .rs 1  ; used in the metatile buffering mode
bTilesRow0Low       .rs 1
bTile0              .rs 1
bTile1              .rs 1
bTilesRow1High      .rs 1
bTilesRow1Low       .rs 1
bTile2              .rs 1
bTile3              .rs 1
bAttsHigh           .rs 1
bAttsLow            .rs 1
bAtts               .rs 1

;****************************************************************
; Pointers                                                      ;
;****************************************************************

drawPointer         .rs 2  ; draw pointer used by NMI
bufferPointer       .rs 2  ; draw buffer pointer
palettePointer      .rs 2  ; used for loading palettes
levelPointer        .rs 2  ; used for loading levels
metaspritePointer   .rs 2  ; used for moving metasprites
tilesPointer        .rs 2  ; used for loading tiles in different states
stringPointer       .rs 2  ; used for loading strings
backgroundPointer   .rs 2  ; used for drawing backgrounds

;****************************************************************
; Game state                                                    ;
;****************************************************************

gameState           .rs 1  ; current gamestate

currentLevel        .rs 1  ; current level

selectedItem        .rs 1  ; generic "selection" var - used for selected tool in the editor and selected letter on the passowrd screen
selectedBox         .rs 1  ; selected box on the password screen

cursorX             .rs 1  ; cursor position
cursorY             .rs 1

blinkTimer          .rs 1  ; generic blink timer
blinkState          .rs 1  ; blink state variable

;****************************************************************
; NMI/main thread synchronization                               ;
;****************************************************************

soft2000            .rs 1  ; buffering $2000 writes
soft2001            .rs 1  ; buffering $2001 writes
needDma             .rs 1  ; nonzero if NMI should perform sprite DMA
needDraw            .rs 1  ; nonzero if NMI needs to do drawing from the buffer
needPpuReg          .rs 1  ; nonzero if NMI should update $2000/$2001/$2005
sleeping            .rs 1  ; nonzero if main thread is waiting for VBlank
needDmaLocal        .rs 1  ; local copy of need DMA
needDrawLocal       .rs 1  ; local copy of need draw
bufferMode          .rs 1  ; buffer mode
frameCount          .rs 1  ; frame count for controllingt the laser speed

;****************************************************************
; Controllers                                                   ;
;****************************************************************

controllerDown      .rs 1  ; buttons that are pressed down
controllerPrevious  .rs 1  ; buttons that were pressed down frame before that
controllerPressed   .rs 1  ; buttons that have been pressed since the last frame
controllerActive    .rs 1  ; buttons that should be acted upon

upTimer             .rs 1  ; button timers
rightTimer          .rs 1 
downTimer           .rs 1 
leftTimer           .rs 1 
selectTimer         .rs 1 
bTimer              .rs 1

;****************************************************************
; Level information                                             ;
;****************************************************************

levelMinX           .rs 1  ; min X on currently loaded level
levelMinY           .rs 1  ; min X on currently loaded level
levelMaxX           .rs 1  ; max X on currently loaded level (width - 1)
levelMaxY           .rs 1  ; max Y on currently loaded level (height - 1)
avElemCount         .rs 1  ; number of available elements
targetsCount        .rs 1  ; number of targets (set when level is loaded)

;****************************************************************
; Laser processing                                              ;
;****************************************************************

targetsLeft         .rs 1  ; targets left to hit (updated when firing)
activeLasers        .rs 1  ; number of active lasers

;****************************************************************
; Sound related                                                 ;
;****************************************************************

currentSong         .rs 1  ; currently played song

  .include "sound\ggsound_zp.inc"  ; .rs 56