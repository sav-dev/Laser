;****************************************************************
; State: end game                                               ;
;****************************************************************

;****************************************************************
; Data & constants                                              ;
;****************************************************************

strConglaturations:
  .byte $12        
  .byte $21, $27
  .byte CHAR_C
  .byte CHAR_O
  .byte CHAR_N
  .byte CHAR_G
  .byte CHAR_L
  .byte CHAR_A
  .byte CHAR_T
  .byte CHAR_U
  .byte CHAR_R
  .byte CHAR_A
  .byte CHAR_T
  .byte CHAR_I
  .byte CHAR_O
  .byte CHAR_N
  .byte CHAR_S  
  .byte CHAR_EXCLAMATION
  .byte CHAR_EXCLAMATION
  .byte CHAR_EXCLAMATION

strYouveBeatenTheGame:
  .byte $16
  .byte $21, $A5
  .byte CHAR_Y
  .byte CHAR_O
  .byte CHAR_U
  .byte CHAR_APOSTROPHE
  .byte CHAR_V
  .byte CHAR_E
  .byte CHAR_SPACE    
  .byte CHAR_B
  .byte CHAR_E
  .byte CHAR_A
  .byte CHAR_T
  .byte CHAR_E
  .byte CHAR_N
  .byte CHAR_SPACE
  .byte CHAR_T
  .byte CHAR_H
  .byte CHAR_E
  .byte CHAR_SPACE  
  .byte CHAR_G
  .byte CHAR_A
  .byte CHAR_M
  .byte CHAR_E
  
;****************************************************************
; Name:                                                         ;
;   EndGameFrame                                                ;
;                                                               ;
; Description:                                                  ;
;   Called every frame when game is in the "end game" state     ;
;****************************************************************

EndGameFrame:

  LDA controllerPressed  
  AND #CONTROLLER_START
  BNE .startPressed
  
  INC blinkTimer 
  LDA blinkTimer 
  CMP #PS_TIMER_FREQ
  BEQ .blink                         ; check if it's timer for a blink
  JMP EndGameFrameDone
    
  .blink:    
    LDA #$00                        ; time for a blink
    STA blinkTimer                   ; reset timer
    LDA blinkState                  
    EOR #$01                         ; invert the showing string value
    STA blinkState                  
    BEQ .hideString                  
                                       
    .showString:                     ; must show the string
      LDA #LOW(strPressStart)          
      STA stringPointer          
      LDA #HIGH(strPressStart)           
      STA stringPointer + $01                  
      JMP .updateString              
                                     
    .hideString:                     ; must hide the string
      LDA #LOW(strPressStartBlank)
      STA stringPointer
      LDA #HIGH(strPressStartBlank)
      STA stringPointer + $01
      
    .updateString:
      JSR PrintString                ; update the string
      INC needDraw                   ; data needs to be drawn
      INC needPpuReg                 ; this will fix the scroll
      JMP EndGameFrameDone
      
  .startPressed:    
    JSR SfxStartPressedEndGame
    JSR FadeOut
    JSR LoadTitle

EndGameFrameDone:
  RTS
  
;****************************************************************
; Name:                                                         ;
;   LoadEndGame                                                 ;
;                                                               ;
; Description:                                                  ;
;   Loads the end game state                                    ;
;****************************************************************
  
LoadEndGame:

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
    LDA #LOW(pal_game_spr)
    STA palettePointer
    LDA #HIGH(pal_game_spr)
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

  .clearBackground:
    JSR ClearBackground
  .clearBackgroundDone:  
  
  .loadStrings:    
    LDA #LOW(strYouveBeatenTheGame)
    STA stringPointer
    LDA #HIGH(strYouveBeatenTheGame)
    STA stringPointer + $01
    JSR PrintString        
    LDA #LOW(strConglaturations)
    STA stringPointer
    LDA #HIGH(strConglaturations)
    STA stringPointer + $01
    JSR PrintString        
    LDA #LOW(strPressStart)
    STA stringPointer
    LDA #HIGH(strPressStart)
    STA stringPointer + $01
    JSR PrintString
    INC needDraw      
  .loadStringsDone:
  
  .enablePPU:                     
    LDA #%10000000                ; sprites from PT 0, bg from PT 0, display NT 0
    STA soft2000                  
    LDA #%00011110                ; enable sprites and background
    STA soft2001                  
    INC needPpuReg                
  .enablePPUDone:  

  .initVars:
    LDA #GAMESTATE_END_GAME
    STA gameState
    LDA #$01                      
    STA blinkState                ; selected item == 1 means the press start string is shown
    LDA #$00
    STA blinkTimer                ; blinkTimer  will be used for updating the string    
  .initVarsDone:
  
  .playSong:
    JSR PlaySongNone
  .playSongDone:  
  
  JSR WaitForFrame                ; wait for everything to get loaded
  RTS

;****************************************************************
; Name:                                                         ;
;   SfxStartPressedEndGame                                      ;
;                                                               ;
; Description:                                                  ;
;   Plays the "start pressed" sound                             ;
;****************************************************************

SfxStartPressedEndGame:
  JSR SfxTarget
  RTS