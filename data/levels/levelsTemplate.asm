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

NUMBER_OF_LEVELS      = ${0}

;****************************************************************
; Level List                                                    ;                           
;****************************************************************

levels:
{1}
  
;****************************************************************
; Level Passwords                                               ;                           
;****************************************************************

passwords:
{2}
  
;****************************************************************
; Level Data                                                    ;                           
;****************************************************************

{3}