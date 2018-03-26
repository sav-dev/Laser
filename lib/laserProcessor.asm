;****************************************************************
; LaserProcessor                                                ;
; Processes the lasers                                          ;
;****************************************************************

;****************************************************************
; Constants:                                                    ;
;****************************************************************

MAX_BEAMS_COUNT      = $10         ; max number of beams
                                   
BEAM_STATE           = $00         ; offset for the beam state
BEAM_DIRECTION       = $01         ; offset for the beam direction
BEAM_X               = $02         ; beam x position
BEAM_Y               = $03         ; beam y position
BEAM_OFFSET          = $04         ; offset between two beams
                                   
BEAM_INACTIVE        = $00         ; inactive beam
BEAM_ACTIVE          = $01         ; active beam
BEAM_DEACTIVATED     = $02         ; beam has just been deactivated
BEAM_ACTIVATED       = $03         ; beam has just been activated
                                   
BEAM_GOING_UP        = $00         ; beam direction - up
BEAM_GOING_RIGHT     = $01         ; beam direction - right
BEAM_GOING_DOWN      = $02         ; beam direction - down
BEAM_GOING_LEFT      = $03         ; beam direction - left
                                   
TILE_HIT_FROM_UP     = %00000001   ; tile hit from up
TILE_HIT_FROM_RIGHT  = %00000010   ; tile hit from right
TILE_HIT_FROM_DOWN   = %00000100   ; tile hit from down
TILE_HIT_FROM_LEFT   = %00001000   ; tile hit from left
                                   
TILE_LIT             = %00010000   ; tile is lit

;****************************************************************
; Name:                                                         ;
;   SpawnBeam                                                  ;
;                                                               ;
; Description:                                                  ;
;   Spawns a new laser (if possible)                            ;
;                                                               ;
; Input vars:                                                   ;
;   b - x position                                              ;
;   c - y position                                              ;
;   d - direction                                               ;
;                                                               ;
; Used variables:                                               ;
;   b                                                           ;
;   c                                                           ;
;   d                                                           ;
;   e                                                           ;
;****************************************************************

SpawnBeam:
  
  LDX #$00
  LDY #$00  
  
  .findSlotLoop:
    LDA laserBeams, x
    BEQ .spawnBeam        ; only look for inactive beams. #BEAM_INACTIVE == 0
    INY
    CPY #MAX_BEAMS_COUNT
    BEQ SpawnBeamDone     ; no slots
    TXA                   
    CLC                   
    ADC #BEAM_OFFSET      
    TAX                   
    JMP .findSlotLoop     
                          
  .spawnBeam:            ; slot found, Y contains the index
    TYA                  ; move the index to A
    ASL A
    ASL A                ; x4 (4 bytes per beam)
    TAX                  ; X points to the state       
    LDA #BEAM_ACTIVATED
    STA laserBeams, x
    INX                  ; X points to direction
    LDA d
    STA laserBeams, x
    INX                  ; X points to the x position
    LDA b
    STA laserBeams, x
    INX                  ; X points to the y position
    LDA c
    STA laserBeams, x
    
    INC activeLasers     ; INC the active lasers count
  
SpawnBeamDone:
  RTS

;****************************************************************
; Name:                                                         ;
;   DeactivateBeam                                              ;
;                                                               ;
; Description:                                                  ;
;   Deactivates a laser beam                                    ;
;                                                               ;
; Input vars:                                                   ;
;   q - laser pointer (readonly)                                ;
;****************************************************************
  
DeactivateBeam:
  LDX q
  LDA #BEAM_DEACTIVATED
  STA laserBeams, x
  DEC activeLasers
  RTS
  
;****************************************************************
; Name:                                                         ;
;   MoveLasers                                                  ;
;                                                               ;
; Description:                                                  ;
;   Moves all lasers                                            ;
;                                                               ;
; Used vars:                                                    ;
;   q                                                           ;
;****************************************************************
  
MoveLasers:
  
  LDX #$00
  
  .moveLaserLoop:  
    STX q                 ; cache X in q
    LDA laserBeams, x
    CMP #BEAM_ACTIVE
    BNE .checkNext        ; only move active beams
    
    INX                   ; X points to the direction
    LDA laserBeams, x    
    CMP #BEAM_GOING_UP
    BEQ .goingUp
    CMP #BEAM_GOING_RIGHT
    BEQ .goingRight
    CMP #BEAM_GOING_DOWN
    BEQ .goingDown
    CMP #BEAM_GOING_LEFT
    BEQ .goingLeft
    
    .goingUp:
      INX
      INX                 ; X points to the y position
      DEC laserBeams, x   ; decrement the y position
      JMP .checkNext

    .goingRight:
      INX                 ; X points to the x position    
      INC laserBeams, x   ; increment the x position
      JMP .checkNext
      
    .goingDown:
      INX
      INX                 ; X points to the y position    
      INC laserBeams, x   ; increment the y position
      JMP .checkNext

    .goingLeft:
      INX                 ; X points to the x position    
      DEC laserBeams, x   ; decrement the x position    
      JMP .checkNext      
      
    .checkNext:
      LDX q               ; load X back from q
      INX
      INX
      INX
      INX  
      CPX #MAX_BEAMS_COUNT * $04
      BEQ MoveLasersDone
      JMP .moveLaserLoop
  
MoveLasersDone:  
  RTS

;****************************************************************
; Name:                                                         ;
;   UpdateLaserTiles                                            ;
;                                                               ;
; Description:                                                  ;
;   Update tiles hit by the laser                               ;
;                                                               ;
; Used vars:                                                    ;
;   e                                                           ;
;   q                                                           ;
;   p                                                           ;
;****************************************************************
  
UpdateLaserTiles
    
  LDA #$01
  STA e                           ; we'll buffer in this subroutine
                                  
  LDX #$00                        
                                  
  .updateLaserTilesLoop:        
    STX q           
    LDA laserBeams, x
    CMP #BEAM_ACTIVE
    BEQ .checkTileUpdates
    CMP #BEAM_DEACTIVATED
    BEQ .checkTileUpdates
    JMP .checkNext
    
    .checkTileUpdates:
      LDA q
      LSR A
      LSR A
      TAX
      LDA tileUpdates, x
      BNE .update
      JMP .checkNext
    
    .update:
      LDX q
      INX                           
      INX                         ; X points to the x position
      LDA laserBeams, x           
      STA b                       ; store it in b
                                  
      INX                         ; X points to the y position
      LDA laserBeams, x           
      STA c                       ; store it in c
                        
      JSR UpdateMetatile
                              
    .checkNext:                   
      LDX q                       ; load X back from q
      INX
      INX
      INX
      INX  
      CPX #MAX_BEAMS_COUNT * $04
      BEQ UpdateLaserTilesDone
      JMP .updateLaserTilesLoop  
  
UpdateLaserTilesDone:
  RTS
  
;****************************************************************
; Name:                                                         ;
;   ProcessHits                                                 ;
;                                                               ;
; Description:                                                  ;
;   Process laser hits                                          ;
;                                                               ;
; Used vars:                                                    ;
;   b                                                           ;
;   c                                                           ;
;   d                                                           ;
;   i                                                           ;
;   j                                                           ;
;   k                                                           ;
;   l                                                           ;
;   q                                                           ;
;   p                                                           ;
;   o                                                           ;
;****************************************************************
 
ProcessHits:

  LDX #$00
  LDA #$00  
  .clearTileUpdatesLoop:
    STA tileUpdates, x
    INX
    CPX #MAX_BEAMS_COUNT
    BNE .clearTileUpdatesLoop
    
  LDX #$00                        
                                  
  .processHitsLoop:          
    STX q                         ; cache X in q
    LDA laserBeams, x             
    CMP #BEAM_ACTIVE
    BEQ .checkMetatile            ; only process tiles hit by active beams
    JMP .checkNext
  
    .checkMetatile:
      INX                         ; X points to the direction
      LDA laserBeams, x
      STA p                       ; store the direction in p
      
      INX                         ; X points to the x position
      LDA laserBeams, x           
      STA b                       ; store it in b
                                  
      INX                         ; X points to the y position
      LDA laserBeams, x           
      STA c                       ; store it in c
                                  
      LDA q
      LSR A
      LSR A
      STA o                       ; o now contains the index of currently processed laser                                  
                                  
      JSR GetMetatileOffset       ; i now contains the index of the metatile that was hit
      LDX i
      LDA levelMetatiles, x       ; load the ID of the metatile that was hit    
      
      CMP #METATILE_ID_EMPTY
      BEQ .empty
      CMP #METATILE_ID_WALL
      BEQ .deactivate
      CMP #METATILE_ID_GUN_RIGHT
      BEQ .deactivate
      CMP #METATILE_ID_GUN_DOWN
      BEQ .deactivate
      CMP #METATILE_ID_GUN_LEFT
      BEQ .deactivate
      CMP #METATILE_ID_GUN_UP
      BEQ .deactivate
      CMP #METATILE_ID_TARGET
      BEQ .target
      CMP #METATILE_ID_CHECKPOINT
      BEQ .checkpoint
      CMP #METATILE_ID_CHECKPOINT_2
      BEQ .checkpoint2
      CMP #METATILE_ID_MIRROR_F
      BEQ .mirrorF
      CMP #METATILE_ID_MIRROR_B
      BEQ .mirrorB
      CMP #METATILE_ID_DISP_F
      BEQ .dispF
      CMP #METATILE_ID_DISP_B
      BEQ .dispB
        
    .empty:                       ; if nothing else was matched, assume it's empty.
      JSR ProcessHitEmpty         ; we don't check for background since it will never be hit
      JMP .checkNext
    
    .deactivate:
      JSR DeactivateBeam
      JMP .checkNext
    
    .target:
      JSR ProcessHitTarget
      JMP .checkNext      
    
    .checkpoint:
      JSR ProcessHitCheckpoint
      JMP .checkNext
    
    .checkpoint2:
      JSR ProcessHitCheckpoint2
      JMP .checkNext
      
    .mirrorF:
      JSR ProcessHitMirrorF
      JMP .checkNext
    
    .mirrorB:
      JSR ProcessHitMirrorB
      JMP .checkNext
    
    .dispF:
      JSR ProcessHitDispF
      JMP .checkNext    
    
    .dispB:
      JSR ProcessHitDispB
      JMP .checkNext    
        
    .checkNext:                   
      LDX q                       ; load X back from q
      INX
      INX
      INX
      INX  
      CPX #MAX_BEAMS_COUNT * $04
      BEQ ProcessHitsDone
      JMP .processHitsLoop  
  
ProcessHitsDone:
  RTS
  
;****************************************************************
; Name:                                                         ;
;   ProcessHitEmpty                                             ;
;                                                               ;
; Description:                                                  ;
;   Process hit for an empty metatile                           ;
;                                                               ;
; Input vars:                                                   ;
;   b - metatile x                                              ;
;   c - metatile y                                              ;
;   i - metatile index                                          ;
;   p - laser's direction                                       ;
;   q - laser pointer (readonly)                                ;
;   o - laser index (readonly)                                  ;
;                                                               ;
; Used vars:                                                    ;
;   j                                                           ;
;   k                                                           ;
;****************************************************************

ProcessHitEmpty:
    
  LDA p
  CMP #BEAM_GOING_UP
  BEQ .goingUp
  CMP #BEAM_GOING_RIGHT
  BEQ .goingRight
  CMP #BEAM_GOING_DOWN
  BEQ .goingDown
  
  .goingLeft:    
    LDA #TILE_HIT_FROM_RIGHT
    STA j                      ; j will contain the state to update
    LDA #TILE_HIT_FROM_LEFT    
    STA k                      ; k will contain the opposite state
    JMP .updateState           
                               
  .goingUp:                    
    LDA #TILE_HIT_FROM_DOWN    
    STA j                      ; j will contain the state to update
    LDA #TILE_HIT_FROM_UP      
    STA k                      ; k will contain the opposite state
    JMP .updateState           
                               
  .goingRight:                 
    LDA #TILE_HIT_FROM_LEFT    
    STA j                      ; j will contain the state to update
    LDA #TILE_HIT_FROM_RIGHT   
    STA k                      ; k will contain the opposite state    
    JMP .updateState           
                               
  .goingDown:                  
    LDA #TILE_HIT_FROM_UP      
    STA j                      ; j will contain the state to update
    LDA #TILE_HIT_FROM_DOWN    
    STA k                      ; k will contain the opposite state    
                               
  .updateState:                
    LDA levelStates, x         
    AND k                      
    BNE ProcessHitEmptyDone    ; don't update if the metatile was already hit from the opposite state
    LDA levelStates, x
    ORA j
    CMP levelStates, x
    BEQ ProcessHitEmptyDone
    STA levelStates, x         ; update the state
    LDX o
    INC tileUpdates, x         ; mark the tile to be updated
  
ProcessHitEmptyDone:  
  RTS

;****************************************************************
; Name:                                                         ;
;   ProcessHitTarget                                            ;
;                                                               ;
; Description:                                                  ;
;   Process hit for a target metatile                           ;
;                                                               ;
; Input vars:                                                   ;
;   b - metatile x                                              ;
;   c - metatile y                                              ;
;   i - metatile index                                          ;
;   p - laser's direction                                       ;
;   q - laser pointer (readonly)                                ;
;   o - laser index (readonly)                                  ;
;****************************************************************

ProcessHitTarget
  JSR DeactivateBeam           ; deactivate the beam
  LDX i
  LDA levelStates, x
  AND #TILE_LIT
  BNE ProcessHitTargetDone     ; tile was already lit, don't change anything  
  LDA levelStates, x
  ORA #TILE_LIT
  STA levelStates, x           ; light the target
  JSR TargetLit
  LDX o
  INC tileUpdates, x           ; mark the tile to be updated
  
ProcessHitTargetDone:  
  RTS

;****************************************************************
; Name:                                                         ;
;   ProcessHitCheckpoint                                        ;
;                                                               ;
; Description:                                                  ;
;   Process hit for a checkpoint metatile                       ;
;                                                               ;
; Input vars:                                                   ;
;   b - metatile x                                              ;
;   c - metatile y                                              ;
;   i - metatile index                                          ;
;   p - laser's direction                                       ;
;   q - laser pointer (readonly)                                ;
;   o - laser index (readonly)                                  ;
;                                                               ;
; Used vars:                                                    ;
;   j                                                           ;
;   k                                                           ;
;****************************************************************

ProcessHitCheckpoint:
  JSR ProcessHitEmpty           ; first treat it as an empty space
  LDX i
  LDA levelStates, x
  AND #TILE_LIT
  BNE ProcessHitCheckpointDone  ; tile was already lit, don't change anything  
  LDA levelStates, x
  ORA #TILE_LIT
  STA levelStates, x            ; light the target
  JSR TargetLit
  LDX o
  INC tileUpdates, x           ; mark the tile to be updated
ProcessHitCheckpointDone:  
  RTS
  
;****************************************************************
; Name:                                                         ;
;   ProcessHitCheckpoint2                                       ;
;                                                               ;
; Description:                                                  ;
;   Process hit for a checkpoint 2 metatile                     ;
;                                                               ;
; Input vars:                                                   ;
;   b - metatile x                                              ;
;   c - metatile y                                              ;
;   i - metatile index                                          ;
;   p - laser's direction                                       ;
;   q - laser pointer (readonly)                                ;
;   o - laser index (readonly)                                  ;
;                                                               ;
; Used vars:                                                    ;
;   j                                                           ;
;   k                                                           ;
;****************************************************************

ProcessHitCheckpoint2:

  JSR ProcessHitEmpty            ; first treat it as an empty space
  
  LDX i
  LDA levelStates, x
  AND #TILE_LIT
  BNE ProcessHitCheckpoint2Done  ; tile was already lit, don't change anything
  
  LDA #$00                       ; j will be set to x, where x is number of times tile was hit
  STA j                          ; this checkpoint must be hit twice to be lit
  
  .checkUp:
    LDA levelStates, x
    AND #TILE_HIT_FROM_UP
    BEQ .checkUpDone
    INC j
  .checkUpDone:
  
  .checkRight:
    LDA levelStates, x
    AND #TILE_HIT_FROM_RIGHT
    BEQ .checkRightDone
    INC j
  .checkRightDone:

  .checkDown:
    LDA levelStates, x
    AND #TILE_HIT_FROM_DOWN
    BEQ .checkDownDone
    INC j
  .checkDownDone:

  .checkLeft:
    LDA levelStates, x
    AND #TILE_HIT_FROM_LEFT
    BEQ .checkLeftDone
    INC j
  .checkLeftDone:      
  
  LDA j
  BEQ ProcessHitCheckpoint2Done  ; target not hit at all (should never be the case)
  DEC j
  BEQ ProcessHitCheckpoint2Done  ; target hit only once, don't light yet
  
  LDA levelStates, x
  ORA #TILE_LIT
  STA levelStates, x             ; light the target
  JSR TargetLit
  LDX o
  INC tileUpdates, x           ; mark the tile to be updated  
  
ProcessHitCheckpoint2Done:  
  RTS
  
;****************************************************************
; Name:                                                         ;
;   ProcessHitMirrorF                                           ;
;                                                               ;
; Description:                                                  ;
;   Process hit for a mirror f. metatile                        ;
;                                                               ;
; Input vars:                                                   ;
;   b - metatile x                                              ;
;   c - metatile y                                              ;
;   i - metatile index                                          ;
;   p - laser's direction                                       ;
;   q - laser pointer (readonly)                                ;
;   o - laser index (readonly)                                  ;
;                                                               ;
; Used vars:                                                    ;
;   j                                                           ;
;   k                                                           ;
;   l                                                           ;
;****************************************************************

ProcessHitMirrorF

  JSR SfxMirrorHit

  LDA p
  CMP #BEAM_GOING_UP
  BEQ .goingUp
  CMP #BEAM_GOING_RIGHT
  BEQ .goingRight
  CMP #BEAM_GOING_DOWN
  BEQ .goingDown
  
  .goingLeft:    
    LDA #TILE_HIT_FROM_RIGHT
    STA j                      ; j will contain the state to update
    LDA #TILE_HIT_FROM_DOWN
    STA k                      ; k will contain the opposite state
    LDA #BEAM_GOING_DOWN       
    STA l                      ; l will contain new beam direction
    JMP .updateState           
                               
  .goingUp:                    
    LDA #TILE_HIT_FROM_DOWN    
    STA j                      ; j will contain the state to update
    LDA #TILE_HIT_FROM_RIGHT
    STA k                      ; k will contain the opposite state    
    LDA #BEAM_GOING_RIGHT      
    STA l                      ; l will contain new beam direction    
    JMP .updateState            
                               
  .goingRight:                 
    LDA #TILE_HIT_FROM_LEFT    
    STA j                      ; j will contain the state to update
    LDA #TILE_HIT_FROM_UP
    STA k                      ; k will contain the opposite state        
    LDA #BEAM_GOING_UP         
    STA l                      ; l will contain new beam direction    
    JMP .updateState            
                               
  .goingDown:                  
    LDA #TILE_HIT_FROM_UP      
    STA j                      ; j will contain the state to update
    LDA #TILE_HIT_FROM_LEFT
    STA k                      ; k will contain the opposite state        
    LDA #BEAM_GOING_LEFT       
    STA l                      ; l will contain new beam direction    
    
  .updateState:    
    LDA levelStates, x
    AND k
    BNE .updateLaser           ; don't update if the metatile was already hit from the opposite state
    LDA levelStates, x
    ORA j
    CMP levelStates, x
    BEQ .updateLaser
    STA levelStates, x         ; update the state
    LDX o
    INC tileUpdates, x         ; mark the tile to be updated

  .updateLaser:
    LDX q
    INX                        ; X points to the direction
    LDA l
    STA laserBeams, x          ; update the direction       
      
ProcessHitMirrorFDone:    
  RTS

;****************************************************************
; Name:                                                         ;
;   ProcessHitMirrorB                                           ;
;                                                               ;
; Description:                                                  ;
;   Process hit for a mirror b. metatile                        ;
;                                                               ;
; Input vars:                                                   ;
;   b - metatile x                                              ;
;   c - metatile y                                              ;
;   i - metatile index                                          ;
;   p - laser's direction                                       ;
;   q - laser pointer (readonly)                                ;
;   o - laser index (readonly)                                  ;
;                                                               ;
; Used vars:                                                    ;
;   j                                                           ;
;   k                                                           ;
;   l                                                           ;
;****************************************************************

ProcessHitMirrorB

  JSR SfxMirrorHit

  LDA p
  CMP #BEAM_GOING_UP
  BEQ .goingUp
  CMP #BEAM_GOING_RIGHT
  BEQ .goingRight
  CMP #BEAM_GOING_DOWN
  BEQ .goingDown
  
  .goingLeft:    
    LDA #TILE_HIT_FROM_RIGHT
    STA j                      ; j will contain the state to update
    LDA #TILE_HIT_FROM_UP
    STA k                      ; k will contain the opposite state
    LDA #BEAM_GOING_UP         
    STA l                      ; l will contain new beam direction
    JMP .updateState           
                               
  .goingUp:                    
    LDA #TILE_HIT_FROM_DOWN    
    STA j                      ; j will contain the state to update
    LDA #TILE_HIT_FROM_LEFT
    STA k                      ; k will contain the opposite state
    LDA #BEAM_GOING_LEFT       
    STA l                      ; l will contain new beam direction    
    JMP .updateState           
                               
  .goingRight:                 
    LDA #TILE_HIT_FROM_LEFT    
    STA j                      ; j will contain the state to update
    LDA #TILE_HIT_FROM_DOWN
    STA k                      ; k will contain the opposite state
    LDA #BEAM_GOING_DOWN       
    STA l                      ; l will contain new beam direction    
    JMP .updateState           
                               
  .goingDown:                  
    LDA #TILE_HIT_FROM_UP      
    STA j                      ; j will contain the state to update
    LDA #TILE_HIT_FROM_RIGHT
    STA k                      ; k will contain the opposite state
    LDA #BEAM_GOING_RIGHT      
    STA l                      ; l will contain new beam direction    
    
  .updateState:    
    LDA levelStates, x
    AND k
    BNE .updateLaser           ; don't update if the metatile was already hit from the opposite state
    LDA levelStates, x
    ORA j
    CMP levelStates, x
    BEQ .updateLaser
    STA levelStates, x         ; update the state
    LDX o
    INC tileUpdates, x         ; mark the tile to be updated
    
  .updateLaser:
    LDX q
    INX                        ; X points to the direction
    LDA l
    STA laserBeams, x          ; update the direction       

ProcessHitMirrorBDone:
  RTS

;****************************************************************
; Name:                                                         ;
;   ProcessHitDispF                                             ;
;                                                               ;
; Description:                                                  ;
;   Process hit for a disp. f. metatile                         ;
;                                                               ;
; Input vars:                                                   ;
;   b - metatile x                                              ;
;   c - metatile y                                              ;
;   i - metatile index                                          ;
;   p - laser's direction                                       ;
;   q - laser pointer (readonly)                                ;
;   o - laser index (readonly)                                  ;
;                                                               ;
; Used vars:                                                    ;
;   d                                                           ;
;   j                                                           ;
;****************************************************************

ProcessHitDispF

  JSR SfxMirrorHit

  LDA p
  CMP #BEAM_GOING_UP
  BEQ .goingUp
  CMP #BEAM_GOING_RIGHT
  BEQ .goingRight
  CMP #BEAM_GOING_DOWN
  BEQ .goingDown
  
  .goingLeft:    
    LDA #TILE_HIT_FROM_RIGHT
    STA j                      ; j will contain the state to update
    LDA #BEAM_GOING_DOWN
    STA d                      ; d will contain the direction of the beam to spawn
    JMP .updateState           
                               
  .goingUp:                    
    LDA #TILE_HIT_FROM_DOWN    ; j will contain the state to update    
    STA j                   
    LDA #BEAM_GOING_RIGHT      ; d will contain the direction of the beam to spawn
    STA d
    JMP .updateState        
                            
  .goingRight:              
    LDA #TILE_HIT_FROM_LEFT    ; j will contain the state to update
    STA j                   
    LDA #BEAM_GOING_UP         ; d will contain the direction of the beam to spawn
    STA d                   
    JMP .updateState        
                            
  .goingDown:               
    LDA #TILE_HIT_FROM_UP      ; j will contain the state to update   
    STA j                    
    LDA #BEAM_GOING_LEFT       ; d will contain the direction of the beam to spawn 
    STA d                   
    
  .updateState:    
    LDA levelStates, x 
    ORA j
    CMP levelStates, x
    BEQ .spawnBeam    
    STA levelStates, x         ; update the state
    LDX o
    INC tileUpdates, x         ; mark the tile to be updated    
    
  .spawnBeam:
    JSR SpawnBeam              ; spawn the new beam (all input vars already set)
    
  RTS

;****************************************************************
; Name:                                                         ;
;   ProcessHitDispB                                             ;
;                                                               ;
; Description:                                                  ;
;   Process hit for a disp. b. metatile                         ;
;                                                               ;
; Input vars:                                                   ;
;   b - metatile x                                              ;
;   c - metatile y                                              ;
;   i - metatile index                                          ;
;   p - laser's direction                                       ;
;   q - laser pointer (readonly)                                ;
;   o - laser index (readonly)                                  ;
;****************************************************************

ProcessHitDispB

  JSR SfxMirrorHit

  LDA p
  CMP #BEAM_GOING_UP
  BEQ .goingUp
  CMP #BEAM_GOING_RIGHT
  BEQ .goingRight
  CMP #BEAM_GOING_DOWN
  BEQ .goingDown
  
  .goingLeft:    
    LDA #TILE_HIT_FROM_RIGHT
    STA j                      ; j will contain the state to update
    LDA #BEAM_GOING_UP
    STA d                      ; d will contain the direction of the beam to spawn
    JMP .updateState           
                               
  .goingUp:                    
    LDA #TILE_HIT_FROM_DOWN    ; j will contain the state to update    
    STA j                   
    LDA #BEAM_GOING_LEFT       ; d will contain the direction of the beam to spawn
    STA d
    JMP .updateState        
                            
  .goingRight:              
    LDA #TILE_HIT_FROM_LEFT    ; j will contain the state to update
    STA j                   
    LDA #BEAM_GOING_DOWN       ; d will contain the direction of the beam to spawn
    STA d                   
    JMP .updateState        
                            
  .goingDown:               
    LDA #TILE_HIT_FROM_UP      ; j will contain the state to update   
    STA j                    
    LDA #BEAM_GOING_RIGHT      ; d will contain the direction of the beam to spawn 
    STA d                   
    
  .updateState:    
    LDA levelStates, x 
    ORA j
    CMP levelStates, x
    BEQ .spawnBeam    
    STA levelStates, x         ; update the state
    LDX o
    INC tileUpdates, x         ; mark the tile to be updated
    
  .spawnBeam:
    JSR SpawnBeam              ; spawn the new beam (all input vars already set)

  RTS

;****************************************************************
; Name:                                                         ;
;   ChangeLaserStates                                           ;
;                                                               ;
; Description:                                                  ;
;   Updates laser states                                        ;
;****************************************************************
  
ChangeLaserState:

  .activateLasers:

    LDX #$00
    
    .activateLaserLoop:  
      LDA laserBeams, x
      CMP #BEAM_ACTIVATED
      BNE .activateNext        ; only update spawned beams
      LDA #BEAM_ACTIVE
      STA laserBeams, x
        
      .activateNext:
        INX
        INX
        INX
        INX  
        CPX #MAX_BEAMS_COUNT * $04
        BEQ ActivateLasersDone
        JMP .activateLaserLoop

  .activateLasersDone:
  
  .deactivateLasers:

    .deactivateLaserLoop:  
      LDA laserBeams, x
      CMP #BEAM_DEACTIVATED
      BNE .deactivateNext      ; only update spawned beams
      LDA #BEAM_INACTIVE
      STA laserBeams, x
        
      .deactivateNext:
        INX
        INX
        INX
        INX  
        CPX #MAX_BEAMS_COUNT * $04
        BEQ .deactivateLasersDone
        JMP .deactivateLaserLoop
  
  .deactivateLasersDone:
        
ActivateLasersDone:    
  RTS
  
;****************************************************************
; Name:                                                         ;
;   TargetLit                                                   ;
;                                                               ;
; Description:                                                  ;
;   Should be called whenever a target is lit                   ;
;****************************************************************
  
TargetLit:
  DEC targetsLeft              ; dec. the remaining targets count  
  JSR SfxTargetLit             ; play the sound
  RTS