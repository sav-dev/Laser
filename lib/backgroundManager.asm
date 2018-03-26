;****************************************************************
; BackgroundManager                                             ;                           
; Responsible for loading backgrounds                           ;
;****************************************************************

;****************************************************************
; Name:                                                         ;
;   LoadBackground                                              ;
;                                                               ;
; Description:                                                  ;
;   Loads a background. Must be called with PPU disabled        ;
;                                                               ;
; Input variables:                                              ;
;   backgroundPointer                                           ;
;   d - number of att. rows to load                             ;
;                                                               ;
; Used variables:                                               ;
;   b                                                           ;
;   c                                                           ;
;   d                                                           ;
;****************************************************************

LoadBackground:

  .loadTiles:
    
    LDA $2002                      ; read PPU status to reset the high/low latch
    LDA #$20                       
    STA $2006                      ; write the high byte of the address ($20)
    LDA #$00                                 
    STA $2006                      ; write the low byte of the address ($00)
                                   
    LDA d                          ; d = number of att. rows to load
    ASL A                          
    ASL A                          ; d * 4 = number of tile rows to load
    TAX                            ; move to X
                                   
    LDA #$00                       
    STA b                          ; b and c will serve as a counter
    STA c                          
                                   
    .setTileCounterLoop:           ; set the counters
      LDA b                        
      CLC                          
      ADC #$20                     
      STA b                        
      LDA c                        
      ADC #$00                     
      STA c                        
      DEX                          
      BNE .setTileCounterLoop      
                                   
    LDY #$00               
    
    .loadTilesLoop:                
      LDA [backgroundPointer], y   ; load a tile byte
      STA $2007                    ; write to the nametable
                                   
      LDA backgroundPointer        
      CLC                          
      ADC #$01                     
      STA backgroundPointer        
      LDA backgroundPointer + $01  
      ADC #$00                     
      STA backgroundPointer + $01  ; move the pointer
      
      LDA b
      SEC
      SBC #$01
      STA b
      LDA c
      SBC #$00
      STA c                        ; decrement the loop counter
      
      LDA b                        ; check exit condition
      BNE .loadTilesLoop
      LDA c
      BNE .loadTilesLoop

  .loadTilesDone:
  
  .loadAtts:
    
    LDA $2002                      ; read PPU status to reset the high/low latch
    LDA #$23                       
    STA $2006                      ; write the high byte of the address ($23)
    LDA #$C0                                 
    STA $2006                      ; write the low byte of the address ($C0)    
      
    LDA d                          ; d = number of att. rows to load
    ASL A
    ASL A
    ASL A                          ; A = d * 8
    TAX                            ; X will serve as the counter
                                   
    .loadAttsLoop:
      LDA [backgroundPointer], y   ; load an atts. byte
      STA $2007                    ; write to the nametable      
      
      LDA backgroundPointer        
      CLC                          
      ADC #$01                     
      STA backgroundPointer        
      LDA backgroundPointer + $01  
      ADC #$00                     
      STA backgroundPointer + $01  ; move the pointer      
      
      DEX                          ; decrement the loop counter
      BNE .loadAttsLoop            ; check exit condition
      
  .loadAttsDone:
    
  RTS
    
;****************************************************************
; Name:                                                         ;
;   ClearBackground                                             ;
;                                                               ;
; Description:                                                  ;
;   Clears nametable 0. Must be called with PPU disabled        ;
;   Sets all tiles to the "clear tile"                          ;
;                                                               ;
; Used variables:                                               ;
;   b                                                           ;
;   c                                                           ;
;****************************************************************

ClearBackground:
  
  LDA $2002                 ; read PPU status to reset the high/low latch
  LDA #$20                  ; we want to clear nametable 0
  STA $2006                 ; write the high byte of the address (#$20)
  LDA #$00                            
  STA $2006                 ; write the low byte of the address (always #$00)
  
  LDA #$00
  STA b                     ; b and c will serve as a counter
  STA c          
       
  .clearTilesLoop:
    LDA #CLEAR_TILE
    STA $2007               ; write a byte
    
    LDA b
    CLC
    ADC #$01
    STA b
    LDA c
    ADC #$00
    STA c                   ; increment the counter
    
    CMP #$03
    BNE .clearTilesLoop
    LDA b
    CMP #$C0
    BNE .clearTilesLoop
    
  .clearAttsLoop:
    LDA #CLEAR_ATTS
    STA $2007
    
    LDA b
    CLC
    ADC #$01
    STA b
    LDA c
    ADC #$00
    STA c
    
    CMP #$04
    BNE .clearAttsLoop
  
  RTS

