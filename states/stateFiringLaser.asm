;****************************************************************
; State: firing the laser                                       ;                           
;****************************************************************

;****************************************************************
; Constants:                                                    ;
;****************************************************************

UPDATE_FREQUENCY      = $03  ; update the laser every 3 frames.
                             ; we can buffer 6 frames, and there are 16 laser max
                             ; so (unless "A" is pressed) there won't be any slowdowns
                    
END_OF_LEVEL_SLEEP_1  = $40  ; end of level sleep duration (before sound is played)
END_OF_LEVEL_SLEEP_2  = $80  ; end of level sleep duration (after sound is played)
                         
;****************************************************************
; Name:                                                         ;
;   FiringLaserFrame                                            ;
;                                                               ;
; Description:                                                  ;
;   Called every frame when game is in the "firing laser" state ;
;****************************************************************

FiringLaserFrame:

  .checkStart:  
    LDA controllerPressed
    AND #CONTROLLER_START
    BEQ .checkIfActive    
    JSR LoadEditorSaveState
    JMP FiringLaserFrameDone

  .checkIfActive:  
    LDA activeLasers
    BEQ FiringLaserFrameDone     ; no more active lasers, don't process anything
  
  .checkFrameCount:  
    LDA controllerDown
    AND #CONTROLLER_A
    BNE .processFrame            ; pressing "A" speeds the laser up
  
    LDA frameCount
    CMP #UPDATE_FREQUENCY
    BCS .processFrame
    JMP .checkFrameCount
  
  .processFrame:
    LDA #$00
    STA frameCount
  
    JSR MoveLasers
    JSR ProcessHits
    JSR UpdateLaserTiles
    JSR ChangeLaserState
    
    INC needDraw
    INC needPpuReg
    
    LDA targetsLeft
    BNE FiringLaserFrameDone
    
    JSR EndOfLevel
  
FiringLaserFrameDone:
  RTS
  
;****************************************************************
; Name:                                                         ;
;   FireLaser                                                   ;
;                                                               ;
; Description:                                                  ;
;   Loads the "firing laser" state                              ;
;****************************************************************

FireLaser:

  .hideSelectors:
    JSR HideSelectors
    INC needDma    
  .hideSelectorsDone:  

  .deactivateBeams:               ; deactivate all beams
  
    LDX #$00                      
    LDY #$00                      
    .deactivateBeamsLoop:         
      LDA #BEAM_INACTIVE          
      STA laserBeams, x           
      INY                         
      CPY #MAX_BEAMS_COUNT        
      BEQ .deactivateBeamsDone    
      TXA                         
      CLC                         
      ADC #BEAM_OFFSET            
      TAX                         
      JMP .deactivateBeamsLoop    
      
  .deactivateBeamsDone:           
                  
  .initVars:
  
    LDA #GAMESTATE_FIRING_LASER
    STA gameState
    
    LDA targetsCount
    STA targetsLeft 
    
    LDA #$00
    STA activeLasers
    STA frameCount
    
  .initVarsDone:
                  
  .spawnBeams:                    ; spawn beams at guns
  
    LDX #$00                      
    .iterateMetatilesLoop:        
      LDA levelMetatiles, x                  
      CMP #METATILE_ID_GUN_UP     
      BEQ .gunUp                  
      CMP #METATILE_ID_GUN_RIGHT  
      BEQ .gunRight               
      CMP #METATILE_ID_GUN_DOWN   
      BEQ .gunDown                
      CMP #METATILE_ID_GUN_LEFT   
      BEQ .gunLeft                
      JMP .nextMetatile           
                                  
      .gunUp:                     
        LDA #BEAM_GOING_UP        
        STA d                     
        JMP .spawnBeam            
                                  
      .gunRight:                  
        LDA #BEAM_GOING_RIGHT     
        STA d                     
        JMP .spawnBeam            
                                  
      .gunDown:                   
        LDA #BEAM_GOING_DOWN      
        STA d                     
        JMP .spawnBeam            
                                  
      .gunLeft:                   
        LDA #BEAM_GOING_LEFT      
        STA d                     
                                  
      .spawnBeam:                 
        STX i                     ; store the metatile offset in i
        JSR GetMetatilePosition   ; b and c now contain the position
        JSR SpawnBeam             ; d contains the direction, all params set - spawn the laser
        LDX i                     ; load the offset back from x
        
      .nextMetatile:
        INX
        CPX #METATILES_COUNT
        BNE .iterateMetatilesLoop
  
  .spawnBeamsDone: 
  
  .playSong:
    JSR PlaySongLaser
  .playSongDone:   
  
  JSR WaitForFrame
  RTS

;****************************************************************
; Name:                                                         ;
;   EndOfLevel                                                  ;
;                                                               ;
; Description:                                                  ;
;   Go to the next level                                        ;
;****************************************************************
  
EndOfLevel:

  LDX #END_OF_LEVEL_SLEEP_1
  JSR SleepForXFrames
  JSR SfxLevelFinished
  LDX #END_OF_LEVEL_SLEEP_2  
  JSR SleepForXFrames  
  JSR PlaySongNone
  JSR FadeOut  
  INC currentLevel
  LDA currentLevel
  CMP #NUMBER_OF_LEVELS
  BEQ .lastLevel
  
  .goToNextLevel:
    JSR LoadPreLevel
    JMP EndOfLevelDone
    
  .lastLevel:
    JSR LoadEndGame
  
EndOfLevelDone:
  RTS
  
;****************************************************************
; Name:                                                         ;
;   SfxLevelFinished                                            ;
;                                                               ;
; Description:                                                  ;
;   Plays the "level finished" sound                            ;
;****************************************************************

SfxLevelFinished:
  JSR SfxSuccess
  RTS
  
;****************************************************************
; Name:                                                         ;
;   SfxMirrorHit                                                ;
;                                                               ;
; Description:                                                  ;
;   Plays the "mirror hit" sound                                ;
;****************************************************************

SfxMirrorHit:
  JSR SfxMirror
  RTS

;****************************************************************
; Name:                                                         ;
;   SfxTargetLit                                                ;
;                                                               ;
; Description:                                                  ;
;   Plays the "target lit" sound                                ;
;****************************************************************

SfxTargetLit:
  JSR SfxTarget
  RTS  