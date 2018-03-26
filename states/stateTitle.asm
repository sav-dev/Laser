;****************************************************************
; State: title                                                  ;
;****************************************************************

;****************************************************************
; Data & constants                                              ;
;****************************************************************

titleBackground:
  .incbin "graphics\backgrounds\title.nam"
  
BACKGROUND_ATT_ROWS  = $04

strNewGame:
  .byte $08        
  .byte $22, $2C
  .byte CHAR_N
  .byte CHAR_E
  .byte CHAR_W
  .byte CHAR_SPACE
  .byte CHAR_G
  .byte CHAR_A
  .byte CHAR_M
  .byte CHAR_E
  
strPassword:
  .byte $08        
  .byte $22, $6C   
  .byte CHAR_P
  .byte CHAR_A
  .byte CHAR_S
  .byte CHAR_S
  .byte CHAR_W
  .byte CHAR_O
  .byte CHAR_R
  .byte CHAR_D

strCopytight:
  .byte $14        
  .byte $23, $05
  .byte CHAR_C
  .byte CHAR_O
  .byte CHAR_P
  .byte CHAR_Y
  .byte CHAR_R
  .byte CHAR_I
  .byte CHAR_G
  .byte CHAR_H
  .byte CHAR_T
  .byte CHAR_COLON
  .byte CHAR_SPACE
  .byte CHAR_U
  .byte CHAR_I
  .byte CHAR_T
  .byte CHAR_S
  .byte CHAR_DASH
  .byte CHAR_S
  .byte CHAR_O
  .byte CHAR_F
  .byte CHAR_T
  
SEL_SPRITE    = $0200  ; selector sprite related consts
SEL_TILE      = $3B 
SEL_ATT       = $01
SEL_X         = $50
SEL_Y         = $87
  
;****************************************************************
; Name:                                                         ;
;   TitleFrame                                                  ;
;                                                               ;
; Description:                                                  ;
;   Called every frame when game is in the "title" state        ;
;****************************************************************

TitleFrame:
  
  LDA #$00
  STA needDmaLocal
  
  .checkStart:
  
    LDA controllerPressed
    AND #CONTROLLER_START
    BNE .selected  
  
  .checkStartDone:

  .checkA:
  
    LDA controllerPressed
    AND #CONTROLLER_A
    BNE .selected  
  
  .checkADone:
  
  .checkSelect:
  
    LDA controllerActive
    AND #CONTROLLER_SEL
    BEQ .checkSelectDone
    JSR ChangeSelection
    INC needDmaLocal
    
  .checkSelectDone:

  .checkUp:
  
    LDA controllerActive
    AND #CONTROLLER_UP
    BEQ .checkUpDone
    JSR ChangeSelection
    INC needDmaLocal
    
  .checkUpDone:
  
  .checkDown:
  
    LDA controllerActive
    AND #CONTROLLER_DOWN
    BEQ .checkDownDone
    JSR ChangeSelection
    INC needDmaLocal
    
  .checkDownDone:
  
  LDA needDmaLocal
  BEQ TitleFrameDone
  INC needDma  
  JMP TitleFrameDone

  .selected:
    JSR SfxOptionSelected
    JSR FadeOut      
    LDA selectedItem
    BNE .passwordSelected
    
    .newGameSelected:
      LDA #$00
      STA currentLevel
      JSR LoadPreLevel
      JMP TitleFrameDone
    
    .passwordSelected:
      JSR LoadPassword
      JMP TitleFrameDone
  
TitleFrameDone:  
  RTS
  
;****************************************************************
; Name:                                                         ;
;   LoadTitle                                                   ;
;                                                               ;
; Description:                                                  ;
;   Loads the title state                                       ;
;****************************************************************
  
LoadTitle:
  
  .disablePPUAndSleep:  
    JSR DisablePPU
    JSR ClearSprites
    INC needDma
    LDX #$20
    JSR SleepForXFrames
  .disablePPUAndSleepDone:

  .initBufferMode:
    LDA #BUFFER_MODE_TILE         
    STA bufferMode  
  .initBufferModeDone:  
  
  .loadPalettes:
    LDA #LOW(pal_title_bg)
    STA palettePointer
    LDA #HIGH(pal_title_bg)
    STA palettePointer + $01
    JSR LoadBgPalette
    LDA #LOW(pal_game_spr)
    STA palettePointer
    LDA #HIGH(pal_game_spr)
    STA palettePointer + $01
    JSR LoadSpritesPalette  
    INC needDraw  
    JSR WaitForFrame
  .loadPalettesDone:  
  
  .loadBackground:
    JSR ClearBackground
    LDA #LOW(titleBackground)
    STA backgroundPointer
    LDA #HIGH(titleBackground)
    STA backgroundPointer + $01
    LDA #BACKGROUND_ATT_ROWS
    STA d
    JSR LoadBackground
  .loadBackgroundDone:
    
  .loadStrings:
    LDA #LOW(strNewGame)
    STA stringPointer
    LDA #HIGH(strNewGame)
    STA stringPointer + $01
    JSR PrintString
    LDA #LOW(strPassword)
    STA stringPointer
    LDA #HIGH(strPassword)
    STA stringPointer + $01
    JSR PrintString    
    LDA #LOW(strCopytight)
    STA stringPointer
    LDA #HIGH(strCopytight)
    STA stringPointer + $01
    JSR PrintString        
    INC needDraw
  .loadStringsDone:
  
  .drawSelector:
    LDA #SEL_X
    STA SEL_SPRITE + X_OFF
    LDA #SEL_Y
    STA SEL_SPRITE + Y_OFF
    LDA #SEL_TILE
    STA SEL_SPRITE + TILE_OFF
    LDA #SEL_ATT
    STA SEL_SPRITE + ATT_OFF
    INC needDma
  .drawSelectorDone:
  
  .enablePPU:                     
    LDA #%10000000                ; sprites from PT 0, bg from PT 0, display NT 0
    STA soft2000                  
    LDA #%00011110                ; enable sprites and background
    STA soft2001                  
    INC needPpuReg                
  .enablePPUDone:  

  .initVars:
    LDA #GAMESTATE_TITLE
    STA gameState
    LDA #$00
    STA selectedItem
    JSR ResetTimers
  .initVarsDone:
  
  .playSong:
    JSR PlaySongNone
  .playSongDone:  
  
  JSR WaitForFrame                ; wait for everything to get loaded
  RTS
  
;****************************************************************
; Name:                                                         ;
;   ChangeSelection                                             ;
;                                                               ;
; Description:                                                  ;
;   Change the selection to the other option                    ;
;****************************************************************

ChangeSelection:
  
  JSR SfxChangeSelection
  LDA selectedItem
  EOR #$01
  STA selectedItem  ; update selected item
  ASL A
  ASL A
  ASL A
  ASL A             ; A = 0 or 16, which is the offset for the second item
  CLC
  ADC #SEL_Y
  STA SEL_SPRITE + Y_OFF  

  RTS
  
;****************************************************************
; Name:                                                         ;
;   SfxChangeSelection                                          ;
;                                                               ;
; Description:                                                  ;
;   Plays the "change selection" sound                          ;
;****************************************************************

SfxChangeSelection:
  JSR SfxAction
  RTS
  
;****************************************************************
; Name:                                                         ;
;   SfxOptionSelected                                           ;
;                                                               ;
; Description:                                                  ;
;   Plays the "option selected" sound                           ;
;****************************************************************

SfxOptionSelected:
  JSR SfxTarget
  RTS  