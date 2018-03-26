;****************************************************************
; Sprites                                                       ;
; Sprites data                                                  ;
;****************************************************************

  .rsset $0200
  
cursor               .rs 16  ; level cursor
selector             .rs 16  ; item selector
elementCounts        .rs 24  ; available elements counter, see Constants->MAX_AV_ELEMENTS