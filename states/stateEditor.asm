;****************************************************************
; State: editor                                                 ;                           
;****************************************************************

;****************************************************************
; Name:                                                         ;
;   EditorFrame                                                 ;
;                                                               ;
; Description:                                                  ;
;   Called every frame when game is in the "editor" state       ;
;****************************************************************

EditorFrame:
  
  LDA #$00
  STA b                     ; b > 0 means cursor must be updated
  STA needDmaLocal
  STA needDrawLocal
  
  .checkUp:
  
    LDA controllerActive
    AND #CONTROLLER_UP   
    BEQ .checkUpDone             
    
    INC b
    DEC cursorY
    LDA cursorY
    CMP levelMinY
    BNE .checkUpDone
    
    LDA levelMaxY           ; wrap up
    STA cursorY
    DEC cursorY
     
  .checkUpDone:
  
  .checkRight:
  
    LDA controllerActive
    AND #CONTROLLER_RIGHT   
    BEQ .checkRightDone           
    
    INC b
    INC cursorX
    LDA cursorX
    CMP levelMaxX
    BNE .checkRightDone
    
    LDA levelMinX           ; wrap right
    STA cursorX
    INC cursorX
    
  .checkRightDone:
  
  .checkDown:
  
    LDA controllerActive
    AND #CONTROLLER_DOWN
    BEQ .checkDownDone  
    
    INC b
    INC cursorY
    LDA cursorY
    CMP levelMaxY
    BNE .checkDownDone
    
    LDA levelMinY           ; wrap down
    STA cursorY
    INC cursorY
    
  .checkDownDone:
  
  .checkLeft:
  
    LDA controllerActive
    AND #CONTROLLER_LEFT   
    BEQ .checkLeftDone  

    INC b
    DEC cursorX
    LDA cursorX
    CMP levelMinX
    BNE .checkLeftDone
    
    LDA levelMaxX           ; wrap left
    STA cursorX
    DEC cursorX
    
  .checkLeftDone:
  
  .updateCursor:
  
    LDA b
    BEQ .updateCursorDone
    JSR UpdateCursor
    INC needDmaLocal
  
  .updateCursorDone:  
  
  .checkSelect:
  
    LDA controllerPressed
    AND #CONTROLLER_SEL   
    BEQ .checkSelectDone             

    ; todo: process select pressed
    
  .checkSelectDone:
  
  .checkA:
  
    LDA controllerPressed 
    AND #CONTROLLER_A
    BEQ .checkADone
    
    JSR ProcessSelectedTile
    INC needDrawLocal       ; for metatiles - this may not be needed, but let's do it anyway
    INC needDmaLocal        ; for counters - this may not be needed, but let's do it anyway    
    
  .checkADone:
  
  .checkB:
  
    LDA controllerActive
    AND #CONTROLLER_B
    BEQ .checkBDone
    
    INC selectedItem
    LDA selectedItem
    CMP avElemCount
    BNE .updateSelector
      
    LDA #$00                ; wrap selection
    STA selectedItem    
      
    .updateSelector:
      JSR UpdateSelector
      INC needDmaLocal      
    
  .checkBDone:  
    
  .needDma:
  
    LDA needDmaLocal
    BEQ .needDmaDone
    INC needDma
  
  .needDmaDone:
  
  .needDraw:
  
    LDA needDrawLocal
    BEQ .needDrawDone
    INC needDraw
    INC needPpuReg          ; ppu reg also needed to reset scroll
    
  .needDrawDone:
  
  .checkStart:
  
    LDA controllerPressed
    AND #CONTROLLER_START
    BEQ .checkStartDone
    
    JSR WaitForFrame
    JSR FireLaser           ; fire the laser
    
  .checkStartDone:
  
  RTS
  
;****************************************************************
; Name:                                                         ;
;   LoadEditor                                                  ;
;                                                               ;
; Description:                                                  ;
;   Loads the editor state                                      ;
;****************************************************************
  
LoadEditor:

  .disablePPUAndSleep:  
    JSR DisablePPU
    JSR ClearSprites
    INC needDma
    LDX #$20
    JSR SleepForXFrames
  .disablePPUAndSleepDone:

  .loadLevelPointer:
    LDA currentLevel
    ASL A                         ; 2 bytes per level
    TAX
    LDA levels, x
    STA levelPointer
    INX
    LDA levels, x
    STA levelPointer + $01  
  .loadLevelPointerDone:

  .initBufferMode:
    LDA #BUFFER_MODE_TILE         
    STA bufferMode                ; for now set the buffering mode to tile, it will be updated to metatile after everything is loaded
  .initBufferModeDone:  
  
  .loadPalettes:
    LDA #LOW(pal_game_bg)
    STA palettePointer
    LDA #HIGH(pal_game_bg)
    STA palettePointer + $01
    JSR LoadBgPalette
    LDA #LOW(pal_game_spr)
    STA palettePointer
    LDA #HIGH(pal_game_spr)
    STA palettePointer + $01
    JSR LoadSpritesPalette  
    INC needDraw  
    JSR WaitForFrame              ; we're buffering before changing the draw mode to make sure right drawing subroutine is used
  .loadPalettesDone:
                
  .loadLevel:                
    JSR LoadLevel
    INC needDma
    JSR WaitForFrame
  .loadLevelDone:            
                    
  .enablePPU:                     
    LDA #%10010000                ; sprites from PT 0, bg from PT 1, display NT 0
    STA soft2000                  
    LDA #%00011110                ; enable sprites and background
    STA soft2001                  
    INC needPpuReg                
  .enablePPUDone:
                                  
  .initVars:
    JSR InitVarsEditor
  .initVarsDone:
  
  .playSong:
    JSR PlaySongEditor
  .playSongDone:  
  
  JSR WaitForFrame                ; wait for everything to get loaded
  RTS
  
;****************************************************************
; Name:                                                         ;
;   LoadEditorSaveState                                         ;
;                                                               ;
; Description:                                                  ;
;   Loads the editor without updating the state of the lvel     ;
;****************************************************************

LoadEditorSaveState:

  .restoreLevel:  
  
    LDA #$01
    STA e                         ; we will buffer
    
    LDX #$00
    .restoreMetatileLoop:    
      STX n                       ; cache X in n
      LDA levelStates, x
      BEQ .checkNext              ; if state is 0 then there's no update needed (#DEFAULT_STATE = 0)
      
      LDA #DEFAULT_STATE
      STA levelStates, x          ; restore the state      
      STX i                       ; move X to i
      JSR GetMetatilePosition     ; b and c now contain the position
      JSR UpdateMetatile          ; update the metatile
      
      .checkNext:
        LDX n                     ; load X back from n    
        INX                       ; inc X
        CPX #METATILES_COUNT      ; check if the loop should continue
        BNE .restoreMetatileLoop  
       
    INC needDraw
    INC needPpuReg
       
  .restoreLevelDone:
  
  .showSelectors:
    JSR UpdateCursor
    JSR UpdateSelector
    INC needDma
  .showSelectorsDone:
  
  .initVars:
    JSR InitVarsEditor
  .initVarsDone:
  
  .playSong:
    JSR PlaySongEditor
  .playSongDone:  
  
  JSR WaitForFrame                ; wait for everything to get loaded
  RTS

;****************************************************************
; Name:                                                         ;
;   InitVarsEditor                                              ;
;                                                               ;
; Description:                                                  ;
;   Inits all vars                                              ;
;****************************************************************
  
InitVarsEditor:
  LDA #GAMESTATE_EDITOR
  STA gameState    
  LDA #BUFFER_MODE_METATILE
  STA bufferMode
  JSR ResetTimers
  RTS
  
;****************************************************************
; Name:                                                         ;
;   SfxElementPlacedEditor                                      ;
;                                                               ;
; Description:                                                  ;
;   Plays the "element placed" sound                            ;
;****************************************************************

SfxElementPlacedEditor:
  JSR SfxAction
  RTS

;****************************************************************
; Name:                                                         ;
;   SfxElementDeletedEditor                                     ;
;                                                               ;
; Description:                                                  ;
;   Plays the "element deleted" sound                           ;
;****************************************************************

SfxElementDeletedEditor:
  JSR SfxAction
  RTS
  
;****************************************************************
; Name:                                                         ;
;   SfxInvalidSelectionEditor                                   ;
;                                                               ;
; Description:                                                  ;
;   Plays the "invalid selection" sound                         ;
;****************************************************************

SfxInvalidSelectionEditor:
  JSR SfxInvalid
  RTS