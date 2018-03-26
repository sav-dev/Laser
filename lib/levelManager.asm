;****************************************************************
; LevelManager                                                  ;
; Responsible for loading and updating levels                   ;
;****************************************************************

;****************************************************************
; Constants:                                                    ;
;****************************************************************

TILE_SIDEBAR       = $10
SIDEBAR_ATT        = %01010101

SIDEBAR_1ST_TILE_H = $20
SIDEBAR_1ST_TILE_L = $5D

SIDEBAR_1ST_ATT_H  = $23
SIDEBAR_1ST_ATT_L  = $C7

COUNTER_X_OFF      = $EC
COUNTER_Y_OFF      = $24
COUNTERS_ATT       = $00

SELECTOR_TILE      = $30
SELECTOR_ATT_0     = %00000000
SELECTOR_ATT_1     = %01000000
SELECTOR_ATT_2     = %10000000
SELECTOR_ATT_3     = %11000000

SELECTOR_X_OFF     = $E8
CURSOR_Y_OFF       = $10

;****************************************************************
; Name:                                                         ;
;   LoadLevel                                                   ;
;                                                               ;
; Description:                                                  ;
;   Loads a level. Must be called with PPU disabled.            ;
;                                                               ;
; Input:                                                        ;
;   LevelPointer                                                ;
;                                                               ;
; Used variables:                                               ;
;   b                                                           ;
;   c                                                           ;
;   d                                                           ;
;   e                                                           ;
;   f                                                           ;
;   g                                                           ;
;   i                                                           ;
;   j                                                           ;
;   h                                                           ;
;   n                                                           ;
;   o                                                           ;
;   p                                                           ;
;   q                                                           ;
;****************************************************************

LoadLevel:

  LDA #$00                       
  STA e                            ; in this subroutine we'll write directly to PPU
  
  .clear:
    
    JSR ClearBackground            ; first clear the background                                                                     
    JSR ClearMemory                ; then clear the memory
    
    LDA #$00
    STA targetsCount               ; set targetsCount to 0
  
  .clearDone:                
                                   
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
    
    LDA #METATILES_WIDTH
    SEC
    SBC levelMaxX
    LSR A
    STA levelMinX                  ; levelMinX contains X offset
    
    LDA #METATILES_HEIGHT
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
                           
  .loadBackground:
  
    STY q                          ; cache Y in q
  
    LDA #METATILE_ID_BACKGROUND
    STA d                          ; metatile to set
  
    LDA #$00
    STA b                          ; b will be the x pointer
    STA c                          ; c will be the y pointer    
    
    .loadBackgroundLoop:
    
      .checkX1:
        LDA b 
        CMP levelMinX              ; carry set if b >= levelMinX
        BCC .setBackground         ; if b < levelMinX, set the background
        
      .checkX2:
        LDA levelMaxX
        CMP b
        BCC .setBackground         ; maxX < metatile x, set the background     
      
      .checkY1:
        LDA c
        CMP levelMinY
        BCC .setBackground         ; metatile y < minY, set the background
      
      .checkY2:
        LDA levelMaxY
        CMP c
        BCC .setBackground         ; maxY < metatile y, set the background
      
      JMP .checkNext               ; if we got here it means the tile is inside the bounds
      
      .setBackground:
        JSR SetMetatile
      
      .checkNext:
        INC b
        LDA b
        CMP #METATILES_WIDTH + $01
        BNE .loadBackgroundLoop
        LDA #$00
        STA b
        INC c
        LDA c
        CMP #METATILES_HEIGHT + $01
        BNE .loadBackgroundLoop
  
    LDY q                          ; load Y back from q
  
  .loadBackgroundDone:
                           
  .loadWalls:                      
                                   
    INY                            ; Y points to the number of walls
    LDA [levelPointer], y          ; load the number of walls    
    BEQ .loadWallsDone             ; if no walls - exit                                   
    STA q                          ; store it in q
            
    LDA #METATILE_ID_WALL              
    STA d                          ; metatile to set -> wall 
                                   
    .drawWallLoop:                 
                                   
      INY                          ; Y points to the start x of the wall
      LDA [levelPointer], y        ; load the start x
      CLC
      ADC levelMinX                ; add the offset
      STA b                        ; store it in b (x position of the metatile)
                                   
      INY                          ; Y points to the start y of the wall
      LDA [levelPointer], y        ; load the start y
      CLC
      ADC levelMinY                ; add the offset      
      STA c                        ; store it in c (y position of the metatile)
                                   
      INY                          ; Y points to the direction
      LDA [levelPointer], y        ; load the direction
      STA p                        ; store it in p
                                   
      INY                          ; Y points to the length
      LDA [levelPointer], y        ; load the length
      STA o                        ; store it in o
                 
      STY n                        ; cache the Y pointer in n             
      JSR DrawWall                 ; draw the wall      
      LDY n                        ; load the Y pointer back
  
      DEC q                        ; decrement the number of walls
      BEQ .loadWallsDone           ; all walls loaded
      JMP .drawWallLoop            ; draw the next wall
  
  .loadWallsDone:
  
  .drawBox:

    LDA #METATILE_ID_WALL              
    STA d                          ; metatile to set -> wall 
  
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
    JSR DrawWall                   ; draw the left wall
    
    LDA levelMaxX
    STA b
    LDA levelMinY
    STA c
    LDA #WALL_DIRECTION_DOWN
    STA p
    LDA g
    STA o
    INC o
    JSR DrawWall                   ; draw the right wall

    LDA levelMinX
    STA b
    LDA levelMinY
    STA c
    LDA #WALL_DIRECTION_RIGHT
    STA p
    LDA f
    STA o
    INC o
    JSR DrawWall                   ; draw the top wall
    
    LDA levelMinX
    STA b
    LDA levelMaxY
    STA c
    LDA #WALL_DIRECTION_RIGHT
    STA p
    LDA f
    STA o
    INC o
    JSR DrawWall                   ; draw the bottom wall
    
    LDY n                          ; load the Y pointer back from n
    
  .drawBoxDone:    
  
  .drawElements:     
  
    INY                            ; Y points to the number of elements
    LDA [levelPointer], y          ; load the number of elements
    STA q                          ; store it in q
    
    .drawElementLoop:
    
      .drawElement:
      
        INY                        ; Y points to the element ID
        LDA [levelPointer], y      ; load the element id
        STA d                      ; store it in d
        
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
        JSR SetMetatile            ; set the metatile
        LDY n                      ; load the Y pointer back

      .drawElementDone:
        
      .checkIfTarget:
      
        LDA d
        CMP #METATILE_ID_TARGET
        BEQ .target
        CMP #METATILE_ID_CHECKPOINT
        BEQ .target
        CMP #METATILE_ID_CHECKPOINT_2
        BEQ .target        
        JMP .checkIfTargetDone
        
        .target:
          INC targetsCount
        
      .checkIfTargetDone:
      
      DEC q
      BNE .drawElementLoop         ; draw next element
    
  .drawElementsDone:
  
  .loadAvailableElements:
  
  
    INY                            ; Y points to the number of available elements
    LDA [levelPointer], y          ; load the number of available elements
    STA avElemCount                ; store it in the var
    LDX #$00                       ; load 0 to X (this is the array pointer)
    
    .loadElementLoop:
      INY
      LDA [levelPointer], y      
      STA availableElements, x     ; copy one byte
      INX
      TXA
      LSR A
      CMP avElemCount              ; we're copying avElemCount * 2 bytes
      BNE .loadElementLoop      
  
  .loadAvailableElementsDone:
  
  .drawSidebar:
  
    LDA #TILE_SIDEBAR
    STA h                         
    LDA #$20
    STA i
    LDA #$1C
    STA j                          ; first tile is 201C, next one is 203C, and so on
    
    LDY #$1E
    .drawSidebarLoop:
      JSR SetTileInPPU      
      LDA #$20
      CLC
      ADC j
      STA j
      LDA i
      ADC #$00
      STA i                        ; add $20 = 32 to the address      
      DEY
      BNE .drawSidebarLoop
      
    LDA #SIDEBAR_ATT
    STA h
    LDA #$23
    STA i
    LDA #$C7
    STA j                          ; first att is 23C7, next one is 23CF, and so on

    LDY #$08
    .drawSidebarAttLoop:
      JSR SetTileInPPU      
      LDA #$08
      CLC
      ADC j
      STA j                        ; add 8 to the address
      DEY
      BNE .drawSidebarAttLoop
    
  .drawSidebarDone:
  
  .drawAvailableElements:
  
    LDX #$00
    
    .drawAvailableElementsLoop:
      LDA availableElements, x     ; load the id
      STA c                        ; store in c
      TXA
      LSR A                        ; A = x / 2 (index)
      STA b                        ; store in b
      STX n                        ; cache x in n
      JSR SetSidebarMetatile       ; set the metatile
      LDX n                        ; load x back from n
      INX
      INX                          ; move to the next element
      TXA
      LSR A
      CMP avElemCount
      BNE .drawAvailableElementsLoop
  
  .drawAvailableElementsDone:
  
  .drawCounters:
  
    JSR InitializeCounters
  
    LDX #$00
    
    .drawCountersLoop:
      TXA
      LSR A
      STA b                        ; store the counter ID in b
      
      INX
      LDA availableElements, x     ; load the value
      STA c                        ; store it in c
      
      STX n                        ; cache x in n
      JSR UpdateCounter            ; set the counter
      LDX n                        ; load x back from n
      
      INX                          ; move to the next element
      TXA
      LSR A
      CMP avElemCount
      BNE .drawCountersLoop
  
  .drawCountersDone:
  
  .initSelectors:
  
    LDA levelMinX    
    STA cursorX  
    INC cursorX    
    LDA levelMinY
    STA cursorY
    INC cursorY                    ; init cursor's position
    
    LDA #$00
    STA selectedItem               ; init selectedItem to 0
        
    JSR InitSelectors
    JSR UpdateSelector
    JSR UpdateCursor               ; draw both metasprites
    
  .initSelectorsDone:
  
LoadLevelDone:  
  RTS
  
;****************************************************************
; Name:                                                         ;
;   ClearMemory                                                 ;
;                                                               ;
; Description:                                                  ;
;   Clear the level data memory                                 ;
;****************************************************************

ClearMemory:

  LDX #$00  
  .clearLevelLoop:
    LDA #METATILE_ID_EMPTY  
    STA levelMetatiles, x
    LDA #DEFAULT_STATE
    STA levelStates, x
    INX
    CPX #METATILES_COUNT 
    BNE .clearLevelLoop
   
  RTS
  
;****************************************************************
; Name:                                                         ;
;   DrawWall                                                    ;
;                                                               ;
; Description:                                                  ;
;   Draws a wall directly in PPU                                ;
;                                                               ;
; Input vars:                                                   ;
;   b: starting x                                               ;
;   c: starting y                                               ;
;   p: direction                                                ;
;   o: length                                                   ;
;****************************************************************

DrawWall:

  JSR SetMetatile            ; set the metatile  
  DEC o                      ; decrement the length
  BEQ DrawWallDone           ; length == 0 means wall is drawn
                             
  LDA p                      ; load the direction
                             
  CMP #WALL_DIRECTION_RIGHT  
  BEQ .wallGoingRight        
          
  .wallGoingDown:
    INC c                    ; inc c (y position)
    JMP DrawWall

  .wallGoingRight:
    INC b                    ; inc b (x position)
    JMP DrawWall

DrawWallDone:
  RTS
  
;****************************************************************
; Name:                                                         ;
;   SetSidebarMetatile                                          ;
;                                                               ;
; Description:                                                  ;
;   Sets a sidebar metatile.                                    ;
;                                                               ;
; Input values                                                  ;
;   b - index of the metatile                                   ;
;   c - metatile to set                                         ;
;                                                               ;
; Used variables:                                               ;
;   b                                                           ;
;   c                                                           ;
;   i                                                           ;
;   j                                                           ;
;****************************************************************

SetSidebarMetatile:

  .setTiles:

    .set1StTileOffset:          ; calculate the offset of the first element
    
      LDA #SIDEBAR_1ST_TILE_H
      STA i
      LDA #SIDEBAR_1ST_TILE_L
      STA j
      
      LDX b
      BEQ .set1StTileOffsetDone
      
      .addTileOffLoop:
        LDA j
        CLC
        ADC #$80
        STA j
        LDA i
        ADC #$00
        STA i
        DEX
        BNE .addTileOffLoop
    
    .set1StTileOffsetDone:
    
    .setTile0:
    
      LDA c                     ; load the metatile to set
      ASL A
      ASL A                     ; A *= 4 (because tile lookup table is 4 bytes per metatile)
      TAX                       ; move A to X      
      LDA tiles, x              ; load the first tile
      STA h                     ; set it in h (where draw subroutines expect it)       
      
      JSR SetTileInPPU
        
    .setTile0Done:
    
    .setTile1:
    
      LDA c                     ; load the metatile to set
      ASL A
      ASL A                     ; A *= 4 (because tile lookup table is 4 bytes per metatile)
      TAX                       ; move A to X
      INX
      LDA tiles, x              ; load the second tile
      STA h                     ; set it in h (where draw subroutines expect it)
      
      INC j                     ; move one tile to the right
      
      JSR SetTileInPPU
      
    .setTile1Done:
    
    .setTile2:
    
      LDA c                     ; load the metatile to set
      ASL A
      ASL A                     ; A *= 4 (because tile lookup table is 4 bytes per metatile)
      TAX                       ; move A to X
      INX
      INX
      LDA tiles, x              ; load the third tile
      STA h                     ; set it in h (where draw subroutines expect it)
      
      DEC j                     ; move to the tile to the left again        
      
      LDA j
      CLC
      ADC #$20
      STA j
      LDA i
      ADC #$00
      STA i                     ; move one tile down
      
      JSR SetTileInPPU
      
    .setTile2Done:  
    
    .setTile3:
    
      LDA c                     ; load the metatile to set
      ASL A
      ASL A                     ; A *= 4 (because tile lookup table is 4 bytes per metatile)
      TAX                       ; move A to X
      INX
      INX
      INX
      LDA tiles, x              ; load the fourth tile
      STA h                     ; set it in h (where draw subroutines expect it)
      
      INC j                     ; move one tile the left again
    
      JSR SetTileInPPU
      
    .setTile3Done:      
  
  .setTilesDone:

  .setAttributes:
  
    .setAttOffset:
  
      LDA #SIDEBAR_1ST_ATT_H
      STA i
      LDA #SIDEBAR_1ST_ATT_L
      STA j
  
      LDX b
      BEQ .setAttOffsetDone
      
      .addAttOffLoop:
        LDA j
        CLC
        ADC #$08
        STA j
        DEX
        BNE .addAttOffLoop    
        
    .setAttOffsetDone:
  
    LDA c                       ; load the metatile to set
    TAX                         ; move A to X
    LDA attributes, x           ; load the attribute to spots 4 and 6
    ASL A
    ASL A
    ORA attributes, x
    ASL A
    ASL A
    ASL A
    ASL A
    STA h                       ; store it in h
    
    JSR SetTileInPPU
  
  .setAttributesDone:
  
  RTS
   
;****************************************************************
; Name:                                                         ;
;   SetMetatile                                                 ;
;                                                               ;
; Description:                                                  ;
;   Sets a metatile.                                            ;
;                                                               ;
; Input values                                                  ;
;   b - metatile x position                                     ;
;   c - metatile y position                                     ;
;   d - metatile to set                                         ;
;   e - 0 = set in PPU, 1 = buffer in memory                    ;
;                                                               ;
; Used variables:                                               ;
;   b                                                           ;
;   c                                                           ;
;   d                                                           ;
;   e                                                           ;
;   h                                                           ;
;   i                                                           ;
;   j                                                           ;
;   k                                                           ;
;   l                                                           ;
;   m                                                           ;
;****************************************************************

SetMetatile:

  .setMemory:
    
    JSR GetMetatileOffset        ; get metatile offset (it's set in i)
    LDX i                        ; move i to x
    LDA d                        ; load the metatile id
    STA levelMetatiles, x        ; set in memory
    
  .setMemoryDone:

  .setTiles:
  
    .calculatePPUAddress:        ; calculate the PPU address of the top-right tile
                                 
      LDA #$20                   
      STA i
      LDA #$00                   
      STA j                      ; start by setting the pointer to $2000 (tile at 0,0)
                           
      .addXOffset:
                           
        LDA b                    
        ASL A                    ; A now holds the tile x offset
        CLC                      
        ADC j
        STA j
        LDA i
        ADC #$00     
            
        STA i                    ; offset += x
        
      .addXOffsetDone:
        
      .addYOffset:
      
        LDA c
        BEQ .addYOffsetDone      ; y = 0 means no offset
        ASL A                    ; A now holds the tile y offset
        TAX                      ; transfer it to X
        
        .addYOffsetLoop:
          LDA #$20
          CLC
          ADC j
          STA j
          LDA i
          ADC #$00
          STA i 
          DEX
          BNE .addYOffsetLoop
          
      .addYOffsetDone:
           
    .calculatePPUAddressDone:
  
    .setTile0:
  
      LDA d                      ; load the metatile to set
      ASL A
      ASL A                      ; A *= 4 (because tile lookup table is 4 bytes per metatile)
      TAX                        ; move A to X      
      LDA tiles, x               ; load the first tile
      STA h                      ; set it in h (where draw subroutines expect it)
      
      LDA e
      BNE .buffer0
     
      .set0:
        JSR SetTileInPPU
        JMP .setTile0Done
      
      .buffer0:
        LDA h
        STA bTile0
        LDA i
        STA bTilesRow0High
        LDA j
        STA bTilesRow0Low
  
    .setTile0Done:
    
    .setTile1:
  
      LDA d                      ; load the metatile to set
      ASL A
      ASL A                      ; A *= 4 (because tile lookup table is 4 bytes per metatile)
      TAX                        ; move A to X
      INX
      LDA tiles, x               ; load the second tile
      STA h                      ; set it in h (where draw subroutines expect it)

      INC j                      ; move to the tile to the right      
      
      LDA e
      BNE .buffer1
      
      .set1:
        JSR SetTileInPPU
        JMP .setTile1Done
      
      .buffer1:
        LDA h
        STA bTile1
        
    .setTile1Done:
  
    .setTile2:
  
      LDA d                      ; load the metatile to set
      ASL A
      ASL A                      ; A *= 4 (because tile lookup table is 4 bytes per metatile)
      TAX                        ; move A to X
      INX
      INX
      LDA tiles, x               ; load the third tile
      STA h                      ; set it in h (where draw subroutines expect it)
           
      DEC j                      ; move to the tile to the left again      
      LDA j                      
      CLC                        
      ADC #$20                   
      STA j                      
      LDA i                      
      ADC #$00                   
      STA i                      ; move one tile down           
           
      LDA e
      BNE .buffer2
      
      .set2:
        JSR SetTileInPPU
        JMP .setTile2Done
      
      .buffer2:
        LDA h
        STA bTile2
        LDA i
        STA bTilesRow1High
        LDA j
        STA bTilesRow1Low
  
    .setTile2Done:  

    .setTile3:
  
      LDA d                      ; load the metatile to set
      ASL A
      ASL A                      ; A *= 4 (because tile lookup table is 4 bytes per metatile)
      TAX                        ; move A to X
      INX
      INX
      INX
      LDA tiles, x               ; load the fourth tile
      STA h                      ; set it in h (where draw subroutines expect it)    

      INC j                      ; move one tile the left again
      
      LDA e
      BNE .buffer3
      
      .set3:
        JSR SetTileInPPU
        JMP .setTile3Done
      
      .buffer3:
        LDA h
        STA bTile3
  
    .setTile3Done:
    
  .setTilesDone:
  
  .setAttributes:
      
      JSR CalculateExistingAtts  ; now m contains current atts
      
      LDA #$23                   
      STA i
      LDA #$C0                   
      STA j                      ; start by setting the pointer to $23C0 (att. at 0,0)

      LDA b
      LSR A                      ; A = floor(x / 2) == attribute x offset
      CLC
      ADC j
      STA j                      ; add the offset 
      
      LDA c
      LSR A
      ASL A
      ASL A
      ASL A                      ; A = floor(y / 2) * 8 == attribute y offset
      CLC
      ADC j
      STA j                      ; add the offset
 
      LDX d                      ; load the metatile to set to X
      LDA attributes, x          ; load the attribute
      STA h                      ; set it in h (where draw subroutines expect it)
      
      LDA #%00000011
      STA k                      ; store 00000011 in k             
             
      .shiftAttributes:
 
        .shiftBy2IfNeeded:       ; shift the attributes to the right place
          LDA b
          AND #$01
          BEQ .shiftBy4IfNeeded
          ASL h
          ASL h
          ASL k
          ASL k
        
        .shiftBy4IfNeeded:
          LDA c
          AND #$01
          BEQ .shiftAttributesDone
          ASL h
          ASL h
          ASL h
          ASL h
          ASL k
          ASL k
          ASL k
          ASL k
 
      .shiftAttributesDone:
 
      .calculateNewAttributes:
 
          LDA k                 ; currently h contains the attributes shifted to the right place, and 0s eveywhere else
          EOR #$FF              ; k contains 1s in the right place, and 0s everywhere else. Invert k
          AND m                 ; AND with existing attributes (essentialy 0 out new attribute spot)
          ORA h                 ; OR with new attributes
          STA h                 ; store the calculated value in h
 
      .calculateNewAttributesDone:
 
      LDA e
      BNE .bufferAtt
      
      .setAtt:
        JSR SetTileInPPU
        JMP .setAttributesDone
      
      .bufferAtt:
        LDA h
        STA bAtts
        LDA i
        STA bAttsHigh
        LDA j
        STA bAttsLow
      
  .setAttributesDone:

  LDA e
  BEQ SetMetatileDone
  JSR BufferMetatile
  
SetMetatileDone:
  RTS

;****************************************************************
; Name:                                                         ;
;   CalculateExistingAtts                                       ;
;                                                               ;
; Description:                                                  ;
;   Calculate attributes for given tile.                        ;
;                                                               ;
; Input values                                                  ;
;   b - metatile x position                                     ;
;   c - metatile y position                                     ;
;                                                               ;
; Returns                                                       ;
;   m - calculated atts                                         ;
;                                                               ;
; Used variables:                                               ;
;   b                                                           ;
;   c                                                           ;
;   i                                                           ;
;   j                                                           ;
;   k                                                           ;
;   l                                                           ;
;   m                                                           ;
;****************************************************************
  
CalculateExistingAtts:

  .getTiles:                    ; get tlies offsets - store them in j, k, l, m
                                
    LDA b                       
    AND #$01                    
    BNE .x1                     
                                
    .x0:                        
      LDA c                     
      AND #$01                  
      BEQ .tile0                
      JMP .tile2                
                                
    .x1:                        
      LDA c                     
      AND #$01                  
      BEQ .tile1                
      JMP .tile3                
                                
    .tile0:                     
                                
      JSR GetMetatileOffset     
      LDA i                     
      STA j                     
      INC b                     
      JSR GetMetatileOffset     
      LDA i                     
      STA k                     
      INC c                     
      JSR GetMetatileOffset     
      LDA i                     
      STA m                     
      DEC b                     
      JSR GetMetatileOffset     
      LDA i                     
      STA l                     
      DEC c                     
                                
      JMP .getTilesDone         
                                
    .tile1:                     
                                
      JSR GetMetatileOffset     
      LDA i                     
      STA k                     
      INC c                     
      JSR GetMetatileOffset     
      LDA i                     
      STA m                     
      DEC b                     
      JSR GetMetatileOffset     
      LDA i                     
      STA l                     
      DEC c                     
      JSR GetMetatileOffset     
      LDA i                     
      STA j                     
      INC b                     
                                
      JMP .getTilesDone         
                                
    .tile2:                     
                                
      JSR GetMetatileOffset     
      LDA i                     
      STA l                     
      DEC c                     
      JSR GetMetatileOffset     
      LDA i                     
      STA j                     
      INC b                     
      JSR GetMetatileOffset     
      LDA i                     
      STA k                     
      INC c                     
      JSR GetMetatileOffset     
      LDA i                     
      STA m                     
      DEC b                     
                                
      JMP .getTilesDone         
                                
    .tile3:                     
                                
      JSR GetMetatileOffset     
      LDA i                     
      STA m                     
      DEC b                     
      JSR GetMetatileOffset     
      LDA i                     
      STA l                     
      DEC c                     
      JSR GetMetatileOffset     
      LDA i                     
      STA j                     
      INC b                     
      JSR GetMetatileOffset     
      LDA i                     
      STA k                     
      INC c                     
                                
      JMP .getTilesDone         
                                
  .getTilesDone:                
                                
  .getAttributes:               ; get attributes for the metatiles and store them in j, k, l, m
  
    .getAttributes0:
    
      LDX j
      LDA levelStates, x        ; load the state, check if it's lit
      AND #TILE_LIT
      BEQ .notLit0
      
      .lit0:
        LDA levelMetatiles, x   ; load the metatile id    
        TAX                     ; move it to x
        LDA attributesLit, x    ; load the lit attributes
        STA j                   ; store in j
        JMP .getAttributes0Done
        
      .notLit0:
        LDA levelMetatiles, x   ; load the metatile id    
        TAX                     ; move it to x
        LDA attributes, x       ; load the regular attributes
        STA j                   ; store in j
    
    .getAttributes0Done:
    
    .getAttributes1:
    
      LDX k
      LDA levelStates, x        ; load the state, check if it's lit
      AND #TILE_LIT
      BEQ .notLit1
      
      .lit1:
        LDA levelMetatiles, x   ; load the metatile id    
        TAX                     ; move it to x
        LDA attributesLit, x    ; load the lit attributes
        STA k                   ; store in k
        JMP .getAttributes1Done
        
      .notLit1:
        LDA levelMetatiles, x   ; load the metatile id    
        TAX                     ; move it to x
        LDA attributes, x       ; load the regular attributes
        STA k                   ; store in k
    
    .getAttributes1Done:
    
    .getAttributes2:
    
      LDX l
      LDA levelStates, x        ; load the state, check if it's lit
      AND #TILE_LIT
      BEQ .notLit2
      
      .lit2:
        LDA levelMetatiles, x   ; load the metatile id    
        TAX                     ; move it to x
        LDA attributesLit, x    ; load the lit attributes
        STA l                   ; store in l
        JMP .getAttributes2Done
        
      .notLit2:
        LDA levelMetatiles, x   ; load the metatile id    
        TAX                     ; move it to x
        LDA attributes, x       ; load the regular attributes
        STA l                   ; store in l
    
    .getAttributes2Done:

    .getAttributes3:
    
      LDX m
      LDA levelStates, x        ; load the state, check if it's lit
      AND #TILE_LIT
      BEQ .notLit3
      
      .lit3:
        LDA levelMetatiles, x   ; load the metatile id    
        TAX                     ; move it to x
        LDA attributesLit, x    ; load the lit attributes
        STA m                   ; store in m
        JMP .getAttributes3Done
        
      .notLit3:
        LDA levelMetatiles, x   ; load the metatile id    
        TAX                     ; move it to x
        LDA attributes, x       ; load the regular attributes
        STA m                   ; store in m
    
    .getAttributes3Done:
    
  .getAttributesDone:
         
  .calculateValue:
  
    LDA m
    ASL A
    ASL A
    ORA l
    ASL A
    ASL A
    ORA k
    ASL A
    ASL A
    ORA j
    STA m
  
  .calculateValueDone:
         
  RTS
  
;****************************************************************
; Name:                                                         ;
;   SetTileInPPU                                                ;
;                                                               ;
; Description:                                                  ;
;   Sets a tile in PPU.                                         ;
;                                                               ;
; Input values                                                  ;
;   i - tile address high byte                                  ;
;   j - tile address low byte                                   ;
;   h - tile to set                                             ;
;****************************************************************

SetTileInPPU:

  LDA $2002                 ; read PPU status to reset the high/low latch
  LDA i
  STA $2006                 ; write the high byte of the address
  LDA j
  STA $2006                 ; write the low byte of the address
  LDA h
  STA $2007                 ; write the byte
  
  RTS
  
;****************************************************************
; Name:                                                         ;
;   BufferMetatile                                              ;
;                                                               ;
; Description:                                                  ;
;   Buffers a metatile to be drawn in NMI.                      ;
;                                                               ;
; Input values                                                  ;
;   buffer vars
;****************************************************************

BufferMetatile:
  
  LDA bufferPointer
  CMP #METATILE_MAX_BUFFER
  BCC .buffer

  .wait:
    INC needDraw
    INC needPpuReg
    JSR WaitForFrame           ; too much stuff buffered, must wait for it to be drawn
  
  .buffer:
    LDY #$00
    LDA bTilesRow0High
    STA [bufferPointer], y
    
    INY
    LDA bTilesRow0Low
    STA [bufferPointer], y
    
    INY
    LDA bTile0    
    STA [bufferPointer], y
    
    INY
    LDA bTile1    
    STA [bufferPointer], y
    
    INY
    LDA bTilesRow1High
    STA [bufferPointer], y
    
    INY
    LDA bTilesRow1Low
    STA [bufferPointer], y
    
    INY
    LDA bTile2    
    STA [bufferPointer], y
    
    INY  
    LDA bTile3    
    STA [bufferPointer], y
    
    INY
    LDA bAttsHigh 
    STA [bufferPointer], y
    
    INY
    LDA bAttsLow 
    STA [bufferPointer], y
    
    INY
    LDA bAtts     
    STA [bufferPointer], y     ; all values written
    
    LDA bufferPointer
    CLC
    ADC #METATILE_SIZE_BUFFER  ; advance buffer
    STA bufferPointer
    LDA bufferPointer + $01
    ADC #$00
    STA bufferPointer + $01
  
  RTS
  
;****************************************************************
; Name:                                                         ;
;   GetMetatileOffset                                           ;
;                                                               ;
; Description:                                                  ;
;   Get the offset of the metatile in the arrays                ;
;                                                               ;
; Input values                                                  ;
;   b - metatile x position                                     ;
;   c - metatile y position                                     ;
;                                                               ;
; Return value                                                  ;
;   i - the offset                                              ;
;                                                               ;
; Used variables:                                               ;
;   b                                                           ;
;   c                                                           ;
;   i                                                           ;
;****************************************************************

GetMetatileOffset:

  LDA b                      ; set i to x
  STA i                      ; offset is x + 14 * y

  LDY c
  BEQ GetMetatileOffsetDone  ; y == 0 means we're done
  
  .addOffsetLoop:
    LDA #$0E                 ; $0E = 14
    CLC
    ADC i
    STA i                    ; add the offset
    DEY
    BNE .addOffsetLoop       ; loop if needed
  
GetMetatileOffsetDone:  
  RTS

;****************************************************************
; Name:                                                         ;
;   GetMetatilePosition                                         ;
;                                                               ;
; Description:                                                  ;
;   Gets the position of a metatile based on the offse          ;
;                                                               ;
; Input value                                                   ;
;   i - the offset                                              ;
;                                                               ;
; Return values                                                 ;
;   b - metatile x position                                     ;
;   c - metatile y position                                     ;
;                                                               ;
; Used variables:                                               ;
;   b                                                           ;
;   c                                                           ;
;****************************************************************

GetMetatilePosition:

  LDA i
  PHA                        ; push i to the stack
                             
  LDA #$00                   
  STA b                      
  STA c                      ; set both positions to 0 for now
  
  .setY:  
    .incrementYLoop:
      LDA i
      CMP #METATILES_HEIGHT      
      BCC .setYDone          ; carry clear when i < height - that means Y is set
      INC c                  ; increment Y
      SEC
      SBC #METATILES_HEIGHT
      STA i                  ; subtract the height from i
      JMP .incrementYLoop
  .setYDone:
  
  .setX:
    LDA i
    STA b                    ; whatever's left is the x position
  .setXDone:
  
  PLA
  STA i                      ; restore i to it's value
  
  RTS
  
;****************************************************************
; Name:                                                         ;
;   GetSelectedMetatileOffset                                   ;
;                                                               ;
; Description:                                                  ;
;   Get the offset of the selected metatile in the arrays       ;
;                                                               ;
; Return value                                                  ;
;   i - the offset                                              ;
;                                                               ;
; Used variables:                                               ;
;   b                                                           ;
;   c                                                           ;
;   i                                                           ;
;****************************************************************

GetSelectedMetatileOffset:
  LDA cursorX
  STA b
  LDA cursorY
  STA c
  JSR GetMetatileOffset
  RTS  
  
;****************************************************************
; Name:                                                         ;
;   InitializeCounters                                          ;
;                                                               ;
; Description:                                                  ;
;   Initialize the available element counters                   ;
;                                                               ;
; Used variables:                                               ;
;   b                                                           ;
;****************************************************************

InitializeCounters:

  LDA #$00
  STA b                          ; will be the counter
  LDX #$00  
    
  .setLoop:      
                                 
    LDA #COUNTER_Y_OFF                     
    CLC                          
    ADC b                        ; add b to the initial offset
    STA elementCounts, x         ; set the Y position
                                 
    INX                          
    LDA #CLEAR_SPRITE            
    STA elementCounts, x         ; set the tile (clear sprite for now)
                                 
    INX                          
    LDA #COUNTERS_ATT            
    STA elementCounts, x         ; set the attributes
                                 
    INX                          
    LDA #COUNTER_X_OFF                      
    STA elementCounts, x         ; set the X position
                    
    INX
    LDA b                        
    CLC                          
    ADC #$20                     ; move 4 rows down
    STA b
    CMP #MAX_AV_ELEMENTS * $20
    BNE .setLoop
    
  RTS
  
;****************************************************************
; Name:                                                         ;
;   UpdateCounter                                               ;
;                                                               ;
; Description:                                                  ;
;   Sets a given counter to the correct value                   ;
;                                                               ;
; Input vars:                                                   ;
;   b - counter to update                                       ;
;                                                               ;
; Used variables:                                               ;
;   b                                                           ;
;   c                                                           ;
;****************************************************************

UpdateCounter:

  LDA b
  ASL A
  CLC
  ADC #$01
  TAX                         ; X points to the counter's value
  LDA availableElements, x    ; load the counter's value
  STA c                       ; store it in c
    
  LDA b
  ASL A
  ASL A
  CLC
  ADC #$01
  TAX                         ; X points to the counter's tile
  LDA c                       ; load the value - number tiles match their numerical value
  STA elementCounts, x        ; set the tile
  
  RTS

;****************************************************************
; Name:                                                         ;
;   UpdateSelectedCounter                                       ;
;                                                               ;
; Description:                                                  ;
;   Updates the selected counter                                ;
;                                                               ;
; Used variables:                                               ;
;   b                                                           ;
;   c                                                           ;
;****************************************************************

  
UpdateSelectedCounter:
  
  LDA selectedItem
  STA b
  JSR UpdateCounter
  RTS
  
;****************************************************************
; Name:                                                         ;
;   InitSelectors                                               ;
;                                                               ;
; Description:                                                  ;
;   Initialize selectors memory                                 ;
;****************************************************************

InitSelectors: 
  
  LDX #$01                    ; points to the 1st tile  
  LDA #SELECTOR_TILE
  STA selector, x             ; set 1st selector tile
  STA cursor, x               ; set 1st cursor tile  
  INX                         ; points to the 1st atts.
  LDA #SELECTOR_ATT_0
  STA selector, x             ; set 1st selector atts.
  STA cursor, x               ; set 1st cursor atts.

  INX
  INX
  INX                         ; point to the 2nd tile
  LDA #SELECTOR_TILE
  STA selector, x             ; set 2nd selector tile
  STA cursor, x               ; set 2nd cursor tile  
  INX                         ; points to the 2nd atts.
  LDA #SELECTOR_ATT_1
  STA selector, x             ; set 2nd selector atts.
  STA cursor, x               ; set 2nd cursor atts.

  INX
  INX
  INX                         ; point to the 3rd tile
  LDA #SELECTOR_TILE
  STA selector, x             ; set 3rd selector tile
  STA cursor, x               ; set 3rd cursor tile  
  INX                         ; points to the 3rd atts.
  LDA #SELECTOR_ATT_2
  STA selector, x             ; set 3rd selector atts.
  STA cursor, x               ; set 3rd cursor atts.
  
  INX
  INX
  INX                         ; point to the 4th tile
  LDA #SELECTOR_TILE
  STA selector, x             ; set 4th selector tile
  STA cursor, x               ; set 4th cursor tile  
  INX                         ; points to the 4th atts.
  LDA #SELECTOR_ATT_3
  STA selector, x             ; set 4th selector atts.
  STA cursor, x               ; set 4th cursor atts.

  RTS
  
;****************************************************************
; Name:                                                         ;
;   UpdateCursor                                                ;
;                                                               ;
; Description:                                                  ;
;   Sets the cursor's position                                  ;
;                                                               ;
; Used vars:                                                    ;
;   b                                                           ;
;   c                                                           ;
;   d                                                           ;
;   e                                                           ;
;   metaspritePointer                                           ;
;****************************************************************

UpdateCursor: 
  
  .setXPosition:
  
    LDA cursorX
    ASL A
    ASL A
    ASL A
    ASL A                        ; A = x * 16
    STA cursor + X_OFF           ; set the x position
    
  .setXPositionDone:
    
  .setYPosition:
    
    LDA cursorY                  
    ASL A                        
    ASL A                        
    ASL A                        
    ASL A                        ; A = y * 16
    STA cursor + Y_OFF           ; set the y position  
    DEC cursor + Y_OFF           ; fix the weird offset issue - this will fail if cursorY == 0 (but it will never be that)
  
  .setYPositionDone:
  
  .moveOtherSprites:
  
    LDA #LOW(cursor)
    STA metaspritePointer
    LDA #HIGH(cursor)
    STA metaspritePointer + $01
    JSR MoveMetasprite           ; move rest of the sprites
  
  .moveOtherSpritesDone:
  
  RTS
  
;****************************************************************
; Name:                                                         ;
;   UpdateSelector                                              ;
;                                                               ;
; Description:                                                  ;
;   Sets the selector's position                                ;
;                                                               ;
; Used vars:                                                    ;
;   b                                                           ;
;   c                                                           ;
;   d                                                           ;
;   e                                                           ;
;   metaspritePointer                                           ;
;****************************************************************

UpdateSelector: 
  
  .setXPosition:
 
    LDA #SELECTOR_X_OFF
    STA selector + X_OFF     ; set the x position
  
  .setXPositionDone:
  
  .setYPosition:
  
    LDA #CURSOR_Y_OFF
    STA b
  
    LDA selectedItem
    BEQ .addLoopDone
    TAX
  
    .addLoop:
      LDA b
      CLC
      ADC #$20
      STA b
      DEX
      BNE .addLoop
    .addLoopDone:
    
    DEC b                    ; fix the weird offset issue
    LDA b
    STA selector + Y_OFF     ; set the y position

  .setYPositionDone:
  
  .moveOtherSprites:
  
    LDA #LOW(selector)
    STA metaspritePointer
    LDA #HIGH(selector)
    STA metaspritePointer + $01
    JSR MoveMetasprite           ; move rest of the sprites

  .moveOtherSpritesDone:
  
  RTS
  
;****************************************************************
; Name:                                                         ;
;   HideSelectors                                               ;
;                                                               ;
; Description:                                                  ;
;   Hides the selectors                                         ;
;****************************************************************


HideSelectors:
  LDA #CLEAR_SPRITE
  STA cursor + Y_OFF + SPRITE_OFF * $00
  STA cursor + Y_OFF + SPRITE_OFF * $01
  STA cursor + Y_OFF + SPRITE_OFF * $02
  STA cursor + Y_OFF + SPRITE_OFF * $03
  STA selector + Y_OFF + SPRITE_OFF * $00
  STA selector + Y_OFF + SPRITE_OFF * $01
  STA selector + Y_OFF + SPRITE_OFF * $02
  STA selector + Y_OFF + SPRITE_OFF * $03
  RTS
  
;****************************************************************
; Name:                                                         ;
;   MoveMetasprite                                              ;
;                                                               ;
; Description:                                                  ;
;   Moves a metasprite                                          ;
;                                                               ;
; Input vars:                                                   ;
;   metaspritePointer                                           ;
;                                                               ;
; Used vars:                                                    ;
;   b                                                           ;
;   c                                                           ;
;   d                                                           ;
;   e                                                           ;
;   metaspritePointer                                           ;
;****************************************************************

MoveMetasprite:
  
  .loadPosition:
  
    LDY #X_OFF
    LDA [metaspritePointer], y  ; load the x position
    STA b                       ; store it in b
    CLC
    ADC #$08
    STA c                       ; store x + 8 in c
      
    LDY #Y_OFF
    LDA [metaspritePointer], y  ; load the y position
    STA d                       ; store it in d
    CLC
    ADC #$08
    STA e                       ; store y + 8 in e
  
  .loadPositionDone:
  
  .set2ndSprite:
    LDY #SPRITE_OFF + X_OFF
    LDA c
    STA [metaspritePointer], y
    LDY #SPRITE_OFF + Y_OFF
    LDA d
    STA [metaspritePointer], y
  .set2ndSpriteDone:

  .set3rdSprite:
    LDY #SPRITE_OFF * $02 + X_OFF
    LDA b
    STA [metaspritePointer], y
    LDY #SPRITE_OFF * $02  + Y_OFF
    LDA e
    STA [metaspritePointer], y
  .set3rdSpriteDone:  

  .set4thSprite:
    LDY #SPRITE_OFF * $03 + X_OFF
    LDA c
    STA [metaspritePointer], y
    LDY #SPRITE_OFF * $03 + Y_OFF
    LDA e
    STA [metaspritePointer], y
  .set4thSpriteDone:  
  
  RTS

;****************************************************************
; Name:                                                         ;
;   ProcessSelectedTile                                         ;
;                                                               ;
; Description:                                                  ;
;   If the tile is empty, try to place an element.              ;
;   Otherwise, try to delete the element.                       ;
;                                                               ;
; Used variables:                                               ;
;   b                                                           ;
;   c                                                           ;
;   d                                                           ;
;   e                                                           ;
;   h                                                           ;
;   i                                                           ;
;   j                                                           ;
;   k                                                           ;
;   l                                                           ;
;   m                                                           ;
;   o                                                           ;
;****************************************************************
  
ProcessSelectedTile:
  JSR GetSelectedMetatileOffset
  LDX i                          ; load the selected metateile's offset to X
  LDA levelMetatiles, x          ; load the metatile
  CMP #METATILE_ID_EMPTY
  BEQ .placeElement;  
  .deleteElement:
    JSR DeleteElement
    RTS    
  .placeElement:
    JSR PlaceElement
    RTS
  
;****************************************************************
; Name:                                                         ;
;   PlaceElement                                                ;
;                                                               ;
; Description:                                                  ;
;   Adds an element (if possible)                               ;
;                                                               ;
; Used variables:                                               ;
;   b                                                           ;
;   c                                                           ;
;   i                                                           ;
;****************************************************************

PlaceElement:

  .checkQuantity:

    LDA selectedItem
    ASL A
    TAX
    INX                            ; X points to the selected item's quantity
    LDA availableElements, x       
    BEQ .invalidSelection          ; no available elements
 
  .checkIfEmptySpace:
  
    JSR GetSelectedMetatileOffset
    LDX i                          ; load the selected metateile's offset to X
    LDA levelMetatiles, x          ; load the metatile
    CMP #METATILE_ID_EMPTY
    BNE .invalidSelection          ; can only place an element on empty space
 
  .addTile:
  
    LDA selectedItem
    ASL A
    TAX                            ; X points to the selected item's id
    LDA availableElements, x       ; load the id
    STA d                          ; set it in d (where SetMetatile expects it)
    INX                            ; X points to the selected item's quantity
    DEC availableElements, x       ; decrement the quantity
    
    LDA #$01
    STA e                          ; we're buffering
    
    LDA cursorX
    STA b
    LDA cursorY
    STA c                          ; copy the position to b and c (where SetMetatile expects it)
    
    JSR SetMetatile                ; set the metatile
    JSR UpdateSelectedCounter      ; finally, update the counter
    
    JSR SfxElementPlacedEditor
    RTS
 
  .invalidSelection:  
    
    JSR SfxInvalidSelectionEditor
    RTS
  
;****************************************************************
; Name:                                                         ;
;   DeleteElement                                               ;
;                                                               ;
; Description:                                                  ;
;   Deletes an element (if possible)                            ;
;                                                               ;
; Used variables:                                               ;
;   b                                                           ;
;   c                                                           ;
;   d                                                           ;
;   e                                                           ;
;   h                                                           ;
;   i                                                           ;
;   j                                                           ;
;   k                                                           ;
;   l                                                           ;
;   m                                                           ;
;   o                                                           ;
;****************************************************************

DeleteElement:

  .checkIfCanBeDeleted:
  
    JSR GetSelectedMetatileOffset
    LDX i                          ; load the selected metateile's offset to X
    LDA levelMetatiles, x          ; load the metatile id
    CMP #FIRST_AV_EL_METATILE
    BCC .invalidSelection          ; metatile is static
 
  .deleteTile:
  
    STA d                          ; cache the metatile id (still in A) in d
    LDX #$00
    
    .findElementLoop:
      LDA availableElements, x     ; load the available element's id
      CMP d                        ; compare with the deleted element's id
      BEQ .updateQuantity
      INX
      INX
      JMP .findElementLoop
      
    .updateQuantity:
      INX                          ; x now points to the quantity
      INC availableElements, x     ; increment the quantity
      DEX
      TXA
      LSR A                        ; A now contains available element's index
      STA o                        ; cache it in o
    
    LDA #METATILE_ID_EMPTY
    STA d                          ; set new id to empty in d (where SetMetatile expect it)
  
    LDA #$01
    STA e                          ; we're buffering
    
    LDA cursorX
    STA b
    LDA cursorY
    STA c                          ; copy the position to b and c (where SetMetatile expects it)
    
    JSR SetMetatile                ; set the metatile
    
    LDA o
    STA b
    JSR UpdateCounter              ; finally, update the counter
    
    JSR SfxElementDeletedEditor
    RTS
 
  .invalidSelection:  
    
    JSR SfxInvalidSelectionEditor
    RTS
    
;****************************************************************
; Name:                                                         ;
;   UpdateMetatile                                              ;
;                                                               ;
; Description:                                                  ;
;   Updates a metatile based on it's attributes.                ;
;                                                               ;
; Input values                                                  ;
;   b - metatile x position                                     ;
;   c - metatile y position                                     ;
;   e - 0 = set in PPU, 1 = buffer in memory                    ;
;                                                               ;
; Used variables:                                               ;
;   b                                                           ;
;   c                                                           ;
;   d                                                           ;
;   e                                                           ;
;   f                                                           ;
;   i                                                           ;
;   j                                                           ;
;   k                                                           ;
;   l                                                           ;
;   m                                                           ;
;   tilesPointer                                                ;
;****************************************************************

UpdateMetatile:

  .loadPointer:
  
    JSR GetMetatileOffset        ; get the offset
    LDX i
  
    LDA #$00
    STA i                        ; will be set to 1 if tile is hit from up
    STA j                        ; will be set to 1 if tile is hit from right
    STA k                        ; will be set to 1 if tile is hit from down
    STA l                        ; will be set to 1 if tile is hit from left
    STA m                        ; will be set to x, where x is number of times tile was hit
  
    .checkUp:
      LDA levelStates, x
      AND #TILE_HIT_FROM_UP
      BEQ .checkUpDone
      INC i
      INC m
    .checkUpDone:
    
    .checkRight:
      LDA levelStates, x
      AND #TILE_HIT_FROM_RIGHT
      BEQ .checkRightDone
      INC j
      INC m
    .checkRightDone:

    .checkDown:
      LDA levelStates, x
      AND #TILE_HIT_FROM_DOWN
      BEQ .checkDownDone
      INC k
      INC m
    .checkDownDone:

    .checkLeft:
      LDA levelStates, x
      AND #TILE_HIT_FROM_LEFT
      BEQ .checkLeftDone
      INC l
      INC m
    .checkLeftDone:    
  
    .loadTwice:    
      LDA m
      BEQ .loadTwiceDone         ; tile not hit at all?
      DEC m
      BEQ .loadTwiceDone         ; tile hit only once?
      
      LDA #LOW(tilesHitTwice)
      STA tilesPointer
      LDA #HIGH(tilesHitTwice)
      STA tilesPointer + $01              
      JMP .loadPointerDone
      
    .loadTwiceDone:
    
    .loadUp:    
    
      LDA i
      BEQ .loadUpDone

      LDA #LOW(tilesHitUp)
      STA tilesPointer
      LDA #HIGH(tilesHitUp)
      STA tilesPointer + $01              
      JMP .loadPointerDone
      
    .loadUpDone:

    .loadRight:    
    
      LDA j
      BEQ .loadRightDone
    
      LDA #LOW(tilesHitRight)
      STA tilesPointer
      LDA #HIGH(tilesHitRight)
      STA tilesPointer + $01              
      JMP .loadPointerDone
    
    .loadRightDone:

    .loadDown:    
    
      LDA k
      BEQ .loadDownDone
      
      LDA #LOW(tilesHitDown)
      STA tilesPointer
      LDA #HIGH(tilesHitDown)
      STA tilesPointer + $01              
      JMP .loadPointerDone
    
    .loadDownDone:
    
    .loadLeft:    
    
      LDA l
      BEQ .loadLeftDone
    
      LDA #LOW(tilesHitLeft)
      STA tilesPointer
      LDA #HIGH(tilesHitLeft)
      STA tilesPointer + $01              
      JMP .loadPointerDone
    
    .loadLeftDone:    
    
    .loadRegular:
    
      LDA #LOW(tiles)
      STA tilesPointer
      LDA #HIGH(tiles)
      STA tilesPointer + $01              
      
    .loadRegularDone:
    
  .loadPointerDone:

  .loadMetatile:
  
    JSR GetMetatileOffset
    LDX i
    LDA levelMetatiles, x
    STA d                        ; store the metatile id in d
  
  .loadMetatileDone:
  
  .loadAttributes:
  
    LDA levelStates, x           ; x still points to the current metatile
    AND #TILE_LIT
    BEQ .notLit
    
    .lit:
      LDX d
      LDA attributesLit, x
      STA f                      ; store attributes to set in f
      JMP .loadAttributesDone
      
    .notLit:
      LDX d
      LDA attributes, x
      STA f                      ; store attributes to set in f
  
  .loadAttributesDone:           ; f now contains attributes to set
  
  .setTiles:
  
    .calculatePPUAddress:        ; calculate the PPU address of the top-right tile
                                 
      LDA #$20                   
      STA i
      LDA #$00                   
      STA j                      ; start by setting the pointer to $2000 (tile at 0,0)
                           
      .addXOffset:
                           
        LDA b                    
        ASL A                    ; A now holds the tile x offset
        CLC                      
        ADC j
        STA j
        LDA i
        ADC #$00     
            
        STA i                    ; offset += x
        
      .addXOffsetDone:
        
      .addYOffset:
      
        LDA c
        BEQ .addYOffsetDone      ; y = 0 means no offset
        ASL A                    ; A now holds the tile y offset
        TAX                      ; transfer it to X
        
        .addYOffsetLoop:
          LDA #$20
          CLC
          ADC j
          STA j
          LDA i
          ADC #$00
          STA i 
          DEX
          BNE .addYOffsetLoop
          
      .addYOffsetDone:
           
    .calculatePPUAddressDone:
  
    .setTile0:
  
      LDA d                      ; load the metatile to set
      ASL A
      ASL A                      ; A *= 4 (because tile lookup table is 4 bytes per metatile)
      TAY                        ; move A to Y
      LDA [tilesPointer], y      ; load the first tile
      STA h                      ; set it in h (where draw subroutines expect it)
      
      LDA e
      BNE .buffer0
     
      .set0:
        JSR SetTileInPPU
        JMP .setTile0Done
      
      .buffer0:
        LDA h
        STA bTile0
        LDA i
        STA bTilesRow0High
        LDA j
        STA bTilesRow0Low               
  
    .setTile0Done:
    
    .setTile1:
  
      LDA d                      ; load the metatile to set
      ASL A
      ASL A                      ; A *= 4 (because tile lookup table is 4 bytes per metatile)
      TAY                        ; move A to Y
      INY
      LDA [tilesPointer], y      ; load the second tile
      STA h                      ; set it in h (where draw subroutines expect it)
      
      INC j                      ; move to the tile to the right
      
      LDA e
      BNE .buffer1
      
      .set1:
        JSR SetTileInPPU
        JMP .setTile1Done
      
      .buffer1:
        LDA h
        STA bTile1
        
    .setTile1Done:
  
    .setTile2:
  
      LDA d                      ; load the metatile to set
      ASL A
      ASL A                      ; A *= 4 (because tile lookup table is 4 bytes per metatile)
      TAY                        ; move A to Y
      INY
      INY
      LDA [tilesPointer], y      ; load the third tile
      STA h                      ; set it in h (where draw subroutines expect it)
      
      DEC j                      ; move to the tile to the left again      
      LDA j
      CLC
      ADC #$20
      STA j
      LDA i
      ADC #$00
      STA i                      ; move one tile down
      
      LDA e
      BNE .buffer2
      
      .set2:
        JSR SetTileInPPU
        JMP .setTile2Done
      
      .buffer2:
        LDA h
        STA bTile2
        LDA i
        STA bTilesRow1High
        LDA j
        STA bTilesRow1Low               
        
    .setTile2Done:  
  
    .setTile3:
  
      LDA d                      ; load the metatile to set
      ASL A
      ASL A                      ; A *= 4 (because tile lookup table is 4 bytes per metatile)
      TAY                        ; move A to Y
      INY
      INY
      INY
      LDA [tilesPointer], y      ; load the fourth tile      
      STA h                      ; set it in h (where draw subroutines expect it)
      
      INC j                      ; move one tile the left again
  
      LDA e
      BNE .buffer3
      
      .set3:
        JSR SetTileInPPU
        JMP .setTile3Done
      
      .buffer3:
        LDA h
        STA bTile3
  
    .setTile3Done:
    
  .setTilesDone:
  
  .setAttributes:
      
      JSR CalculateExistingAtts  ; now m contains current atts
      
      LDA #$23                   
      STA i
      LDA #$C0                   
      STA j                      ; start by setting the pointer to $23C0 (att. at 0,0)
  
      LDA b
      LSR A                      ; A = floor(x / 2) == attribute x offset
      CLC
      ADC j
      STA j                      ; add the offset 
      
      LDA c
      LSR A
      ASL A
      ASL A
      ASL A                      ; A = floor(y / 2) * 8 == attribute y offset
      CLC
      ADC j
      STA j                      ; add the offset
  
      LDA f                      ; load the attributes to set
      STA h                      ; set it in h (where draw subroutines expect it)
      
      LDA #%00000011
      STA k                      ; store 00000011 in k             
             
      .shiftAttributes:
  
        .shiftBy2IfNeeded:       ; shift the attributes to the right place
          LDA b
          AND #$01
          BEQ .shiftBy4IfNeeded
          ASL h
          ASL h
          ASL k
          ASL k
        
        .shiftBy4IfNeeded:
          LDA c
          AND #$01
          BEQ .shiftAttributesDone
          ASL h
          ASL h
          ASL h
          ASL h
          ASL k
          ASL k
          ASL k
          ASL k
  
      .shiftAttributesDone:
  
      .calculateNewAttributes:
  
          LDA k                 ; currently h contains the attributes shifted to the right place, and 0s eveywhere else
          EOR #$FF              ; k contains 1s in the right place, and 0s everywhere else. Invert k
          AND m                 ; AND with existing attributes (essentialy 0 out new attribute spot)
          ORA h                 ; OR with new attributes
          STA h                 ; store the calculated value in h
  
      .calculateNewAttributesDone:
  
      LDA e
      BNE .bufferAtt
      
      .setAtt:
        JSR SetTileInPPU
        JMP .setAttributesDone
      
      .bufferAtt:
        LDA h
        STA bAtts
        LDA i
        STA bAttsHigh
        LDA j
        STA bAttsLow
      
  .setAttributesDone:
  
  LDA e
  BEQ UpdateMetatileDone
  JSR BufferMetatile
  
UpdateMetatileDone:
  RTS