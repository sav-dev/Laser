;****************************************************************
; State: pre-level                                              ;                           
;****************************************************************

;****************************************************************
; Data & constants                                              ;
;****************************************************************
  
strLevel:
  .byte $05        
  .byte $20, $6C   
  .byte CHAR_L
  .byte CHAR_E
  .byte CHAR_V
  .byte CHAR_E
  .byte CHAR_L
  
strPreLevelPassword:
  .byte $09        
  .byte $22, $E9   
  .byte CHAR_P
  .byte CHAR_A
  .byte CHAR_S
  .byte CHAR_S
  .byte CHAR_W
  .byte CHAR_O
  .byte CHAR_R
  .byte CHAR_D
  .byte CHAR_COLON
                                    
LEVEL_DIGITS_OFF_H   = $20        ; offset of the level number digits
LEVEL_DIGITS_OFF_L   = $72        
                                  
PASSWORD_OFF_H       = $22        ; offset of the password
PASSWORD_OFF_L       = $F3
                                  
MINIMAP_ATT_START    = $C8        ; atts for the minimap
MINIMAP_ATT_0        = %10101010
MINIMAP_ATT_0_COUNT  = $20                     
MINIMAP_ATT_1        = %00001010
MINIMAP_ATT_1_COUNT  = $08

MINIMAP_START_OFF_H  = $20        ; starting offset for the minimap
MINIMAP_START_OFF_L  = $80

TILE_WALL            = $31
TILE_ELEMENT         = $32

MINIMAP_WIDTH        = $20
MINIMAP_HEIGHT       = $12

;****************************************************************
; Name:                                                         ;
;   PreLevelFrame                                               ;
;                                                               ;
; Description:                                                  ;
;   Called every frame when game is in the "pre-level" state    ;
;****************************************************************

PreLevelFrame:

  LDA controllerPressed  
  AND #CONTROLLER_START
  BNE .startPressed
  
  INC blinkTimer
  LDA blinkTimer
  CMP #PS_TIMER_FREQ
  BEQ .blink                         ; check if it's timer for a blink
  JMP PreLevelFrameDone
    
  .blink:    
    LDA #$00                         ; time for a blink
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
      JMP PreLevelFrameDone
      
  .startPressed:
    JSR SfxStartPressedPreLevel
    JSR FadeOut
    JSR LoadEditor

PreLevelFrameDone:
  RTS
  
;****************************************************************
; Name:                                                         ;
;   LoadPreLevel                                                ;
;                                                               ;
; Description:                                                  ;
;   Loads the pre-level state                                   ;
;****************************************************************
  
LoadPreLevel:

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
                                  
  .loadLevelNumber:
    LDA #$00
    STA c                         ; c => second digit
    
    LDA currentLevel
    STA b                         ; b => first digit
    INC b
    
    .digitsLoop:
      LDA b
      CMP #$0A
      BCC .digitsLoopDone
      SEC
      SBC #$0A
      STA b
      INC c 
      JMP .digitsLoop
    .digitsLoopDone:
    
    LDA $2002  
    LDA #LEVEL_DIGITS_OFF_H
    STA $2006  
    LDA #LEVEL_DIGITS_OFF_L
    STA $2006
    LDA c
    STA $2007
    LDA b
    STA $2007
    
  .loadLevelNumberDone:

  .loadPassword:
    LDA currentLevel
    ASL A
    ASL A                         ; 4 bytes per password
    TAX    
    LDA $2002  
    LDA #PASSWORD_OFF_H
    STA $2006  
    LDA #PASSWORD_OFF_L
    STA $2006        
    LDA passwords, x
    STA $2007
    INX
    LDA passwords, x
    STA $2007
    INX
    LDA passwords, x
    STA $2007
    INX
    LDA passwords, x
    STA $2007
  .loadPasswordDone:
  
  .loadStrings:                   
    LDA #LOW(strLevel)
    STA stringPointer
    LDA #HIGH(strLevel)
    STA stringPointer + $01
    JSR PrintString
    LDA #LOW(strPreLevelPassword)
    STA stringPointer
    LDA #HIGH(strPreLevelPassword)
    STA stringPointer + $01
    JSR PrintString
    LDA #LOW(strPressStart)
    STA stringPointer
    LDA #HIGH(strPressStart)
    STA stringPointer + $01
    JSR PrintString
    INC needDraw    
  .loadStringsDone:
                                                                    
  .loadMinimap:                   
    JSR LoadMinimap
  .loadMinimapDone:               
                                  
  .enablePPU:                     
    LDA #%10000000                ; sprites from PT 0, bg from PT 0, display NT 0
    STA soft2000                  
    LDA #%00011110                ; enable sprites and background
    STA soft2001                  
    INC needPpuReg                
  .enablePPUDone:  
                                  
  .initVars:                      
    LDA #GAMESTATE_PRELEVEL       
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
;   LoadMinimap                                                 ;
;                                                               ;
; Description:                                                  ;
;   Loads the minimap                                           ;
;                                                               ;
; Used vars:                                                    ;
;   b                                                           ;
;   c                                                           ;
;   d                                                           ;
;   f                                                           ;
;   g                                                           ;
;   i                                                           ;
;   j                                                           ;
;   k                                                           ;
;****************************************************************  

LoadMinimap:

  .loadAtts:

    LDA $2002
    LDA #$23
    STA $2006
    LDA #MINIMAP_ATT_START
    STA $2006
    
    LDX #MINIMAP_ATT_0_COUNT  
    LDA #MINIMAP_ATT_0  
    .loadAtts0Loop:
      STA $2007
      DEX
      BNE .loadAtts0Loop
      
    LDX #MINIMAP_ATT_1_COUNT  
    LDA #MINIMAP_ATT_1      
    .loadAtts1Loop:
      STA $2007
      DEX
      BNE .loadAtts1Loop
    
  .loadAttsDone:
  
  .loadDimensions:                 

    LDY #$00                       ; Y points to max x
    LDA [levelPointer], y          ; load max x
    STA levelMaxX
    
    INY                            ; Y points to max y
    LDA [levelPointer], y          ; load max y
    STA levelMaxY
  
    LDA levelMaxX
    STA f                          ; cache max x in f (used for drawing the box)
    
    LDA levelMaxY
    STA g                          ; cache max y in g (used for drawing the box)

    LDA #MINIMAP_WIDTH
    SEC
    SBC levelMaxX
    LSR A
    STA levelMinX                  ; levelMinX contains X offset
    
    LDA #MINIMAP_HEIGHT
    SEC
    SBC levelMaxY
    LSR A
    STA levelMinY                  ; levelMinY contains Y offset    
    
    LDA levelMaxX
    CLC
    ADC levelMinX
    STA levelMaxX                  ; levelMaxX set to the correct value
    
    LDA levelMaxY
    CLC
    ADC levelMinY
    STA levelMaxY                  ; levelMaxY set to the correct value   
  
  .loadDimensionsDone:  

  .drawBox:

    STY n                          ; cache the Y pointer in n             
    
    LDA levelMinX
    STA b
    LDA levelMinY
    STA c
    LDA #WALL_DIRECTION_DOWN
    STA p
    LDA g
    STA o
    INC o
    JSR DrawMinimapWall            ; draw the left wall
    
    LDA levelMaxX
    STA b
    LDA levelMinY
    STA c
    LDA #WALL_DIRECTION_DOWN
    STA p
    LDA g
    STA o
    INC o
    JSR DrawMinimapWall            ; draw the right wall

    LDA levelMinX
    STA b
    LDA levelMinY
    STA c
    LDA #WALL_DIRECTION_RIGHT
    STA p
    LDA f
    STA o
    INC o
    JSR DrawMinimapWall            ; draw the top wall
    
    LDA levelMinX
    STA b
    LDA levelMaxY
    STA c
    LDA #WALL_DIRECTION_RIGHT
    STA p
    LDA f
    STA o
    INC o
    JSR DrawMinimapWall            ; draw the bottom wall
    
    LDY n                          ; load the Y pointer back from n
    
  .drawBoxDone:
  
  .drawWalls:
  
    INY                            ; Y points to the number of walls
    LDA [levelPointer], y          ; load the number of walls    
    BEQ .drawWallsDone             ; if no walls - exit                                   
    STA k                          ; store it in k
            
    LDA #TILE_WALL
    STA d                          ; tile to set -> wall 
                                   
    .drawWallLoop:                 
                                   
      INY                          ; Y points to the start x of the wall
      LDA [levelPointer], y        ; load the start x
      CLC
      ADC levelMinX                ; add the offset
      STA b                        ; store it in b (x position of the tile)
                                   
      INY                          ; Y points to the start y of the wall
      LDA [levelPointer], y        ; load the start y
      CLC
      ADC levelMinY                ; add the offset      
      STA c                        ; store it in c (y position of the tile)
                                   
      INY                          ; Y points to the direction
      LDA [levelPointer], y        ; load the direction
      STA p                        ; store it in p
                                   
      INY                          ; Y points to the length
      LDA [levelPointer], y        ; load the length
      STA o                        ; store it in o
                 
      STY n                        ; cache the Y pointer in n             
      JSR DrawMinimapWall          ; draw the wall      
      LDY n                        ; load the Y pointer back
  
      DEC k                        ; decrement the number of walls
      BEQ .drawWallsDone           ; all walls loaded
      JMP .drawWallLoop            ; draw the next wall
  
  .drawWallsDone:
  
  .drawElements:
  
    INY                            ; Y points to the number of elements
    LDA [levelPointer], y          ; load the number of elements
    STA k                          ; store it in k

    LDA #TILE_ELEMENT
    STA d                          ; tile to set -> element
    
    .drawElementLoop:
    
      INY
      INY                        ; Y points to the x position
      LDA [levelPointer], y      ; load the x position
      CLC
      ADC levelMinX              ; add the offset              
      STA b                      ; store it in b
      
      INY                        ; Y points to the y position
      LDA [levelPointer], y      ; load the y position
      CLC
      ADC levelMinY              ; add the offset              
      STA c                      ; store it in c
      
      STY n                      ; cache the Y pointer in n             
      JSR SetMinimapTile         ; set the tile
      LDY n                      ; load the Y pointer back    
  
      DEC k
      BNE .drawElementLoop       ; draw next element
  
  .drawElementsDone:
  
  RTS

;****************************************************************
; Name:                                                         ;
;   DrawMinimapWall                                             ;
;                                                               ;
; Description:                                                  ;
;   Draws a wall on the minimap                                 ;
;                                                               ;
; Input vars:                                                   ;
;   b: starting x                                               ;
;   c: starting y                                               ;
;   p: direction                                                ;
;   o: length                                                   ;
;                                                               ;
; Used vars:                                                    ;
;   b                                                           ;
;   c                                                           ;
;   q                                                           ;
;**************************************************************** 
  
DrawMinimapWall:

  LDA #TILE_WALL
  STA d
  LDX o
  
  .drawTileLoop:
    STX q
    JSR SetMinimapTile
    LDX q
    DEX
    BEQ DrawMinimapWallDone
    LDA p
    CMP #WALL_DIRECTION_DOWN
    BEQ .goingDown
    
    .goingRight:    
      INC b
      JMP .drawTileLoop
    
    .goingDown:
      INC c
      JMP .drawTileLoop    

DrawMinimapWallDone:
  RTS
  
;****************************************************************
; Name:                                                         ;
;   SetMinimapTile                                              ;
;                                                               ;
; Description:                                                  ;
;   Loads the minimap                                           ;
;                                                               ;
; Input vars:                                                   ;
;   b - x position                                              ;
;   c - y position                                              ;
;   d - tile to set                                             ;
;                                                               ;
; Used vars:                                                    ;
;   i                                                           ;
;   j                                                           ;
;****************************************************************  
  
SetMinimapTile:

  .getOffset:
  
    LDA #MINIMAP_START_OFF_H
    STA i
    LDA #MINIMAP_START_OFF_L
    STA j
  
    .addYOffset:
    
      LDX c
      BEQ .addYOffsetDone
      
      .addYOffsetLoop:
        LDA j
        CLC
        ADC #$20
        STA j
        LDA i
        ADC #$00
        STA i
        DEX
        BNE .addYOffsetLoop
      
    .addYOffsetDone:
    
    .addXOffset:
    
      LDA j
      CLC
      ADC b
      STA j
    
    .addXOffsetDone:
  
  .getOffsetDone:
  
  .setTile:
  
    LDA $2002
    LDA i
    STA $2006
    LDA j
    STA $2006
    LDA d
    STA $2007
  
  .setTileDone:
  
SetMinimapTileDone: 
  RTS
  
;****************************************************************
; Name:                                                         ;
;   SfxStartPressedPreLevel                                     ;
;                                                               ;
; Description:                                                  ;
;   Plays the "start pressed" sound                             ;
;****************************************************************

SfxStartPressedPreLevel:
  JSR SfxTarget
  RTS