;****************************************************************
; State: password                                               ;
;****************************************************************

;****************************************************************
; Data & constants                                              ;
;****************************************************************

strEnterThePassword:
  .byte $13
  .byte $20, $C6
  .byte CHAR_E
  .byte CHAR_N
  .byte CHAR_T
  .byte CHAR_E
  .byte CHAR_R
  .byte CHAR_SPACE
  .byte CHAR_T
  .byte CHAR_H
  .byte CHAR_E
  .byte CHAR_SPACE
  .byte CHAR_P
  .byte CHAR_A
  .byte CHAR_S
  .byte CHAR_S
  .byte CHAR_W
  .byte CHAR_O
  .byte CHAR_R
  .byte CHAR_D  
  .byte CHAR_COLON

strFirstLine:
  .byte $13
  .byte $21, $E6
  .byte CHAR_A
  .byte CHAR_SPACE
  .byte CHAR_B
  .byte CHAR_SPACE
  .byte CHAR_C
  .byte CHAR_SPACE
  .byte CHAR_D
  .byte CHAR_SPACE
  .byte CHAR_E
  .byte CHAR_SPACE
  .byte CHAR_F
  .byte CHAR_SPACE
  .byte CHAR_G
  .byte CHAR_SPACE
  .byte CHAR_H
  .byte CHAR_SPACE
  .byte CHAR_I
  .byte CHAR_SPACE
  .byte CHAR_J

strSecondLine:
  .byte $13
  .byte $22, $26
  .byte CHAR_K
  .byte CHAR_SPACE
  .byte CHAR_L
  .byte CHAR_SPACE
  .byte CHAR_M
  .byte CHAR_SPACE
  .byte CHAR_N
  .byte CHAR_SPACE
  .byte CHAR_O
  .byte CHAR_SPACE
  .byte CHAR_P
  .byte CHAR_SPACE
  .byte CHAR_Q
  .byte CHAR_SPACE
  .byte CHAR_R
  .byte CHAR_SPACE
  .byte CHAR_S
  .byte CHAR_SPACE
  .byte CHAR_T
  
strThirdLine:
  .byte $13
  .byte $22, $66
  .byte CHAR_U
  .byte CHAR_SPACE
  .byte CHAR_V
  .byte CHAR_SPACE
  .byte CHAR_W
  .byte CHAR_SPACE
  .byte CHAR_X
  .byte CHAR_SPACE
  .byte CHAR_Y
  .byte CHAR_SPACE
  .byte CHAR_Z
  .byte CHAR_SPACE
  .byte CHAR_LEFT
  .byte CHAR_SPACE
  .byte CHAR_RIGHT
  .byte CHAR_SPACE
  .byte CHAR_E
  .byte CHAR_N
  .byte CHAR_D
  
OFFSET_BOX_H             = $21
OFFSET_BOX_L             = $28  ; this + $40 must be < $FF

OFFSET_CHAR_H            = OFFSET_BOX_H
OFFSET_CHAR_L            = OFFSET_BOX_L + $20 + $01
                         
TILE_BOX_TL              = $33  ; tiles for the box
TILE_BOX_T               = $34
TILE_BOX_TR              = $35
TILE_BOX_L               = $36
TILE_BOX_R               = $37
TILE_BOX_BL              = $38
TILE_BOX_B               = $39
TILE_BOX_BR              = $3A
                         
SPRITE_SELECTED_BOX      = $0200
SELECTED_BOX_X_OFF       = $40
SELECTED_BOX_Y_OFF       = $47
SELECTED_BOX_OFFSET      = $20
SELECTED_BOX_ATT         = $01

SPRITE_LETTER_SELECTOR   = $0200 + ($08 * SPRITE_OFF)
LETTER_SELECTOR_TILE     = $3B
LETTER_SELECTOR_ATT      = $01
  
LETTER_OFFSET            = CHAR_A
  
SELECTION_LEFT           = $1A
SELECTION_RIGHT          = $1B
SELECTION_END            = $1C
  
movementUp:
  .byte $14, $15, $16, $17, $18, $19, $1A, $1B, $1C, $1C
  .byte $00, $01, $02, $03, $04, $05, $06, $07, $08, $09
  .byte $0A, $0B, $0C, $0D, $0E, $0F, $10, $11, $12

movementDown:
  .byte $0A, $0B, $0C, $0D, $0E, $0F, $10, $11, $12, $13
  .byte $14, $15, $16, $17, $18, $19, $1A, $1B, $1C, $1C
  .byte $00, $01, $02, $03, $04, $05, $06, $07, $08
 
movementLeft:
  .byte $09, $00, $01, $02, $03, $04, $05, $06, $07, $08
  .byte $13, $0A, $0B, $0C, $0D, $0E, $0F, $10, $11, $12
  .byte $1C, $14, $15, $16, $17, $18, $19, $1A, $1B

movementRight:
  .byte $01, $02, $03, $04, $05, $06, $07, $08, $09, $00
  .byte $0B, $0C, $0D, $0E, $0F, $10, $11, $12, $13, $0A
  .byte $15, $16, $17, $18, $19, $1A, $1B, $1C, $14
  
letterSelectorX:
  .byte $27, $37, $47, $57, $67, $77, $87, $97, $A7, $B7
  .byte $27, $37, $47, $57, $67, $77, $87, $97, $A7, $B7
  .byte $27, $37, $47, $57, $67, $77, $87, $97, $A7
  
letterSelectorY:
  .byte $77, $77, $77, $77, $77, $77, $77, $77, $77, $77
  .byte $87, $87, $87, $87, $87, $87, $87, $87, $87, $87
  .byte $97, $97, $97, $97, $97, $97, $97, $97, $97
  
;****************************************************************
; Name:                                                         ;
;   PasswordFrame                                               ;
;                                                               ;
; Description:                                                  ;
;   Called every frame when game is in the "password" state     ;
;****************************************************************

PasswordFrame:

  LDA #$00
  STA b                         ; b > means we need to update the letter selector
  STA c                         ; c > 0 means we need to update the selected box
  STA needDmaLocal              
                                
  .checkUp:                     
                                
    LDA controllerActive
    AND #CONTROLLER_UP          
    BEQ .checkUpDone                 
                                
    LDX selectedItem          
    LDA movementUp, x         
    STA selectedItem          
    INC b                     
                                
  .checkUpDone:                 
                                
  .checkRight:                  
                                
    LDA controllerActive
    AND #CONTROLLER_RIGHT       
    BEQ .checkRightDone          
                                
    LDX selectedItem          
    LDA movementRight, x      
    STA selectedItem          
    INC b                     
                                
  .checkRightDone:              
                                
  .checkDown:                   
                                
    LDA controllerActive
    AND #CONTROLLER_DOWN        
    BEQ .checkDownDone
                                
    LDX selectedItem          
    LDA movementDown, x       
    STA selectedItem          
    INC b                     
                                
  .checkDownDone:               
                                
  .checkLeft:                   
                                
    LDA controllerActive
    AND #CONTROLLER_LEFT        
    BEQ .checkLeftDone         
                                
    LDX selectedItem        
    LDA movementLeft, x     
    STA selectedItem        
    INC b                   
                              
  .checkLeftDone:             
                              
  .checkStart:
  
    LDA controllerPressed
    AND #CONTROLLER_START
    BEQ .checkStartDone
    
    JSR CheckPassword
    LDA gameState
    CMP #GAMESTATE_PASSWORD
    BEQ .checkStartDone         ; if game state haven't changed it means the password was invalid    
    JMP PasswordFrameDone    
  
  .checkStartDone:
                              
  .checkA:                    
                              
    LDA controllerPressed     
    AND #CONTROLLER_A         
    BEQ .checkADone           
                              
    LDA selectedItem          
    CMP #SELECTION_LEFT       
    BEQ .leftSelected         
    CMP #SELECTION_RIGHT      
    BEQ .rightSelected        
    CMP #SELECTION_END        
    BEQ .endSelected
                              
    .charSelected:
      JSR SfxLetterChosen
      JSR UpdateLetter          ; update current letter
      INC needDraw
      INC needPpuReg
      JSR MoveSelectedBoxRight  ; move the box right
      INC c
      LDA selectedBox
      BNE .checkADone
      LDA #SELECTION_END        ; if we've set the 4th letter, move the selection to the end
      STA selectedItem
      INC b
      JMP .checkADone
    
    .leftSelected:
      JSR MoveSelectedBoxLeft
      INC c
      JMP .checkADone
      
    .rightSelected:
      JSR MoveSelectedBoxRight
      INC c
      JMP .checkADone
      
    .endSelected:
      JSR CheckPassword
      LDA gameState
      CMP #GAMESTATE_PASSWORD
      BEQ .checkADone           ; if game state haven't changed it means the password was invalid
      JMP PasswordFrameDone   
    
  .checkADone:
  
  .checkB:
  
    LDA controllerPressed
    AND #CONTROLLER_B
    BEQ .checkBDone
    
    JSR FadeOut
    JSR LoadTitle
    JMP PasswordFrameDone
    
  .checkBDone:
  
  .updateLetterSelector:
  
    LDA b
    BEQ .updateLetterSelectorDone
    JSR DrawLetterSelector
    INC needDmaLocal
  
  .updateLetterSelectorDone:
  
  .updateSelectedBox:
  
    LDA c
    BEQ .updateSelectedBoxDone
    JSR DrawSelectedBox
    INC needDmaLocal
  
  .updateSelectedBoxDone:  
  
  .needDma:
  
    LDA needDmaLocal
    BEQ .needDmaDone
    INC needDma
  
  .needDmaDone:  
  
PasswordFrameDone:
  RTS
  
;****************************************************************
; Name:                                                         ;
;   LoadPassword                                                ;
;                                                               ;
; Description:                                                  ;
;   Loads the password state                                    ;
;****************************************************************
  
LoadPassword:
 
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
  
  .loadBoxes:
  
    LDX #$00                      ; X will be the box index
    
    .drawBoxLoop:
    
      .drawTopRow:
        LDA $2002            
        LDA #OFFSET_BOX_H
        STA $2006
        TXA
        ASL A
        ASL A                     ; A = X * 4 = boxes offset
        CLC
        ADC #OFFSET_BOX_L
        STA $2006
        LDA #TILE_BOX_TL
        STA $2007
        LDA #TILE_BOX_T
        STA $2007
        LDA #TILE_BOX_TR
        STA $2007
      
      .drawMiddleRow:
        LDA $2002            
        LDA #OFFSET_BOX_H
        STA $2006
        TXA
        ASL A
        ASL A                     ; A = X * 4 = boxes offset
        CLC
        ADC #OFFSET_BOX_L + $20
        STA $2006
        LDA #TILE_BOX_L
        STA $2007
        LDA #CLEAR_TILE
        STA $2007
        LDA #TILE_BOX_R
        STA $2007
      
      .drawBottomRow:
        LDA $2002            
        LDA #OFFSET_BOX_H
        STA $2006
        TXA
        ASL A
        ASL A                     ; A = X * 4 = boxes offset
        CLC
        ADC #OFFSET_BOX_L + $40
        STA $2006
        LDA #TILE_BOX_BL
        STA $2007
        LDA #TILE_BOX_B
        STA $2007
        LDA #TILE_BOX_BR
        STA $2007
      
      .loopCondition:
        INX
        CPX #$04                  ; 4 boxes
        BNE .drawBoxLoop
      
  .loadBoxesDone:
  
  .loadStrings:
    LDA #LOW(strFirstLine)
    STA stringPointer
    LDA #HIGH(strFirstLine)
    STA stringPointer + $01
    JSR PrintString
    LDA #LOW(strSecondLine)
    STA stringPointer
    LDA #HIGH(strSecondLine)
    STA stringPointer + $01
    JSR PrintString
    LDA #LOW(strThirdLine)
    STA stringPointer
    LDA #HIGH(strThirdLine)
    STA stringPointer + $01
    JSR PrintString    
    LDA #LOW(strEnterThePassword)
    STA stringPointer
    LDA #HIGH(strEnterThePassword)
    STA stringPointer + $01
    JSR PrintString        
    INC needDraw
  .loadStringsDone:
  
  .initVars:
    
    LDA #GAMESTATE_PASSWORD
    STA gameState
    
    LDA #$00
    STA selectedBox  
    STA selectedItem 
    
    JSR ResetTimers    
    
    LDA #CLEAR_TILE
    STA levelMetatiles            ; we'll use levelMetatiles as selected chars
    STA levelMetatiles + $01
    STA levelMetatiles + $02
    STA levelMetatiles + $03
    
  .initVarsDone:
  
  .drawSelectors:
    JSR WaitForFrame
    JSR DrawSelectedBox
    JSR DrawLetterSelector
    INC needDma
  .drawSelectorsDone:
  
  .enablePPU:                     
    LDA #%10000000                ; sprites from PT 0, bg from PT 0, display NT 0
    STA soft2000                  
    LDA #%00011110                ; enable sprites and background
    STA soft2001                  
    INC needPpuReg                
  .enablePPUDone:    
  
  .playSong:
    JSR PlaySongNone
  .playSongDone:  
  
  JSR WaitForFrame                ; wait for everything to get loaded
  RTS

;****************************************************************
; Name:                                                         ;
;   DrawSelectedBox                                             ;
;                                                               ;
; Description:                                                  ;
;   Lights up the selected box                                  ;
;****************************************************************
  
DrawSelectedBox:

  .setXPosition:
  
    .drawLeftColumn:
      LDA selectedBox
      ASL A
      ASL A
      ASL A
      ASL A
      ASL A
      CLC
      ADC #SELECTED_BOX_X_OFF
      STA SPRITE_SELECTED_BOX + X_OFF
      STA SPRITE_SELECTED_BOX + X_OFF + (SPRITE_OFF * $03)
      STA SPRITE_SELECTED_BOX + X_OFF + (SPRITE_OFF * $05)
    
    .drawMiddleColumn:
      CLC
      ADC #$08
      STA SPRITE_SELECTED_BOX + X_OFF + (SPRITE_OFF * $01)
      STA SPRITE_SELECTED_BOX + X_OFF + (SPRITE_OFF * $06)
      
    .drawRightColumn:
      CLC
      ADC #$08
      STA SPRITE_SELECTED_BOX + X_OFF + (SPRITE_OFF * $02)
      STA SPRITE_SELECTED_BOX + X_OFF + (SPRITE_OFF * $04)      
      STA SPRITE_SELECTED_BOX + X_OFF + (SPRITE_OFF * $07)
  
  .setEverythingElse:
  
    .drawTopRow:
      LDA #SELECTED_BOX_Y_OFF
      STA SPRITE_SELECTED_BOX + Y_OFF
      STA SPRITE_SELECTED_BOX + Y_OFF + (SPRITE_OFF * $01)
      STA SPRITE_SELECTED_BOX + Y_OFF + (SPRITE_OFF * $02)
          
      LDA #SELECTED_BOX_ATT
      STA SPRITE_SELECTED_BOX + ATT_OFF
      STA SPRITE_SELECTED_BOX + ATT_OFF + (SPRITE_OFF * $01)
      STA SPRITE_SELECTED_BOX + ATT_OFF + (SPRITE_OFF * $02)
      
      LDA #TILE_BOX_TL
      STA SPRITE_SELECTED_BOX + TILE_OFF
      LDA #TILE_BOX_T
      STA SPRITE_SELECTED_BOX + TILE_OFF + (SPRITE_OFF * $01)
      LDA #TILE_BOX_TR
      STA SPRITE_SELECTED_BOX + TILE_OFF + (SPRITE_OFF * $02)
    
    .drawMiddleRow:
      LDA #SELECTED_BOX_Y_OFF + $08
      STA SPRITE_SELECTED_BOX + Y_OFF + (SPRITE_OFF * $03)
      STA SPRITE_SELECTED_BOX + Y_OFF + (SPRITE_OFF * $04)
    
      LDA #SELECTED_BOX_ATT
      STA SPRITE_SELECTED_BOX + ATT_OFF + (SPRITE_OFF * $03)
      STA SPRITE_SELECTED_BOX + ATT_OFF + (SPRITE_OFF * $04)
      
      LDA #TILE_BOX_L
      STA SPRITE_SELECTED_BOX + TILE_OFF + (SPRITE_OFF * $03)
      LDA #TILE_BOX_R
      STA SPRITE_SELECTED_BOX + TILE_OFF + (SPRITE_OFF * $04)
      
    .drawBottomRow:
      LDA #SELECTED_BOX_Y_OFF + $10
      STA SPRITE_SELECTED_BOX + Y_OFF + (SPRITE_OFF * $05)
      STA SPRITE_SELECTED_BOX + Y_OFF + (SPRITE_OFF * $06)
      STA SPRITE_SELECTED_BOX + Y_OFF + (SPRITE_OFF * $07)
    
      LDA #SELECTED_BOX_ATT
      STA SPRITE_SELECTED_BOX + ATT_OFF + (SPRITE_OFF * $05)
      STA SPRITE_SELECTED_BOX + ATT_OFF + (SPRITE_OFF * $06)
      STA SPRITE_SELECTED_BOX + ATT_OFF + (SPRITE_OFF * $07)
          
      LDA #TILE_BOX_BL
      STA SPRITE_SELECTED_BOX + TILE_OFF + (SPRITE_OFF * $05)
      LDA #TILE_BOX_B
      STA SPRITE_SELECTED_BOX + TILE_OFF + (SPRITE_OFF * $06)
      LDA #TILE_BOX_BR
      STA SPRITE_SELECTED_BOX + TILE_OFF + (SPRITE_OFF * $07)
    
  RTS
  
;****************************************************************
; Name:                                                         ;
;   DrawLetterSelector                                          ;
;                                                               ;
; Description:                                                  ;
;   Draws the letter selector                                   ;
;****************************************************************
  
DrawLetterSelector:
  
  LDX selectedItem
  LDA letterSelectorX, x
  STA SPRITE_LETTER_SELECTOR + X_OFF

  LDX selectedItem
  LDA letterSelectorY, x
  STA SPRITE_LETTER_SELECTOR + Y_OFF  
  
  LDA #LETTER_SELECTOR_TILE
  STA SPRITE_LETTER_SELECTOR + TILE_OFF
  
  LDA #LETTER_SELECTOR_ATT
  STA SPRITE_LETTER_SELECTOR + ATT_OFF
  
  RTS
  
;****************************************************************
; Name:                                                         ;
;   MoveSelectedBoxLeft                                         ;
;                                                               ;
; Description:                                                  ;
;   Moves selected box left                                     ;
;****************************************************************

MoveSelectedBoxLeft:
  
  LDA selectedBox
  CMP #$00
  BEQ .wrap
  DEC selectedBox
  RTS

  .wrap:
    LDA #$03
    STA selectedBox
    
  RTS

;****************************************************************
; Name:                                                         ;
;   MoveSelectedBoxRight                                        ;
;                                                               ;
; Description:                                                  ;
;   Moves selected box right                                    ;
;****************************************************************

MoveSelectedBoxRight:
  
  LDA selectedBox
  CMP #$03
  BEQ .wrap
  INC selectedBox
  RTS

  .wrap:
    LDA #$00
    STA selectedBox
    
  RTS

;****************************************************************
; Name:                                                         ;
;   UpdateLetter                                                ;
;                                                               ;
; Description:                                                  ;
;   Update the selected letter                                  ;
;****************************************************************

UpdateLetter:
    
  LDY #$00
  LDA #$01
  STA [bufferPointer], y
  
  INY
  LDA #OFFSET_CHAR_H
  STA [bufferPointer], y

  INY
  LDA selectedBox
  ASL A
  ASL A
  ADC #OFFSET_CHAR_L
  STA [bufferPointer], y
  
  INY
  LDA selectedItem
  ADC #LETTER_OFFSET
  STA [bufferPointer], y  
  LDX selectedBox
  STA levelMetatiles, x
  
  LDA bufferPointer
  CLC
  ADC #$04
  STA bufferPointer
  LDA bufferPointer + $01
  ADC #$00
  STA bufferPointer + $01
  
  RTS
  
;****************************************************************
; Name:                                                         ;
;   CheckPassword                                               ;
;                                                               ;
; Description:                                                  ;
;   Checks if the password matches any level passwords          ;
;                                                               ;
; Used variables:                                               ;
;   i                                                           ;
;   j                                                           ;
;   k                                                           ;
;****************************************************************

CheckPassword:

  LDX #$00                     
                               
  .checkPasswordLoop:                  
                               
    STX i                      ; store the index of currently checked level in i
                               
    LDA #$00
    STA j                      ; j will be the entered char pointer - set it to 0
                               
    TXA                        
    ASL A                      
    ASL A 
    TAX                        ; X points to the password pointer in passwords
                            
    .checkCharacterLoop:       
      LDA passwords, x         ; load the password character
      STX k                    ; store the password character pointer in k
      LDX j                    ; load the entered character pointer from j      
      CMP levelMetatiles, x    ; compare both
      BNE .checkNextLevel      ; not equal, check next level    
      INX                      ; increment the entered character pointer
      CPX #$04                 ; check if we've matched everything
      BEQ .validPassword       ; if yes - it's a valid password and i contains the level index
      STX j                    ; store the entered character pointer in j
      LDX k                    ; load the password character pointer
      INX                      ; increment it
      JMP .checkCharacterLoop  ; check next character
                            
    .checkNextLevel:             
      LDX i
      INX                   
      CPX #NUMBER_OF_LEVELS     
      BEQ .invalidPassword     ; checked all levels, nothing matched
      JMP .checkPasswordLoop
  
  .validPassword:
    JSR SfxValidPassword
    LDA i
    STA currentLevel
    JSR FadeOut
    JSR LoadPreLevel
    RTS
    
  .invalidPassword:
    JSR SfxInvalidPassword
    RTS
    
;****************************************************************
; Name:                                                         ;
;   SfxLetterChosen                                             ;
;                                                               ;
; Description:                                                  ;
;   Plays the "letter chosen" sound                             ;
;****************************************************************

SfxLetterChosen:
  JSR SfxAction
  RTS
  
;****************************************************************
; Name:                                                         ;
;   SfxInvalidPassword                                          ;
;                                                               ;
; Description:                                                  ;
;   Plays the "invalid password" sound                          ;
;****************************************************************

SfxInvalidPassword:
  JSR SfxInvalid
  RTS
  
;****************************************************************
; Name:                                                         ;
;   SfxValidPassword                                            ;
;                                                               ;
; Description:                                                  ;
;   Plays the "valid password" sound                            ;
;****************************************************************

SfxValidPassword:
  JSR SfxSuccess
  RTS