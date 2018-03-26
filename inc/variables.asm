;****************************************************************
; Variables                                                     ;
; Non-zero page variables                                       ;
;****************************************************************

  .rsset $0400
  
;****************************************************************
; Level data                                                    ;
;****************************************************************

levelMetatiles       .rs 224  ; *** $0400 *** see Constants->METATILES_COUNT (1 byte per metatile) (224 instead of 210 for debug purposes)
levelStates          .rs 224  ; *** $04E0 *** see Constants->METATILES_COUNT (1 byte per metatile) (224 instead of 210 for debug purposes)
availableElements    .rs 16   ; *** $05C0 *** see Constants->MAX_AV_ELEMENTS (2 bytes per element) (16 instead of 12 for debug purposes)
laserBeams           .rs 64   ; *** $05D0 *** see LaserProcessor->MAX_BEAMS_COUNT (4 bytes per beam)
tileUpdates          .rs 16   ; *** $0610 *** see LaserProcessor->MAX_BEAMS_COUNT (1 bytes per beam)

  .include "sound\ggsound_ram.inc"  ; .rs 144