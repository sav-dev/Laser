;****************************************************************
; PaletteManager                                                ;                           
; Responsible for loading palettes                              ;
;****************************************************************

pal_title_bg:
  .incbin "graphics\palettes\title_bg.pal"

pal_title_spr:
  .incbin "graphics\palettes\title_spr.pal"

pal_game_bg:
  .incbin "graphics\palettes\game_bg.pal"

pal_game_spr:
  .incbin "graphics\palettes\game_spr.pal"
  
;****************************************************************
; Name:                                                         ;
;   LoadSpritesPalette                                          ;
;                                                               ;
; Description:                                                  ;
;   Buffers the sprites to be drawn in NMI                      ;
;   Palette pointer must be set                                 ;
;                                                               ;
; Input parameters:                                             ;
;   palettePointer: pointer to the palette                      ;
;                                                               ;
; Variables used:                                               ;
;  b                                                            ;
;  c                                                            ;
;  bufferPointer                                                ;
;  palettePointer                                               ;
;****************************************************************

LoadSpritesPalette:
  LDA #$3F               
  STA b                  ; store the high target byte in b
  LDA #$10               
  STA c                  ; store the low target byte in c
  JSR LoadPalette        ; load the palette
  RTS
  
;****************************************************************
; Name:                                                         ;
;   LoadBgPalette                                               ;
;                                                               ;
; Description:                                                  ;
;   Buffers the bg. palette to be drawn in NMI                  ;
;   Palette pointer must be set                                 ;
;                                                               ;
; Input parameters:                                             ;
;   palettePointer: pointer to the palette                      ;
;                                                               ;
; Variables used:                                               ;
;  b                                                            ;
;  c                                                            ;
;  bufferPointer                                                ;
;  palettePointer                                               ;
;****************************************************************

LoadBgPalette:
  LDA #$3F               
  STA b                  ; store the high target byte in b
  LDA #$00               
  STA c                  ; store the low target byte in c
  JSR LoadPalette        ; load the palette
  RTS
  
;****************************************************************
; Name:                                                         ;
;   LoadPalette                                                 ;
;                                                               ;
; Description:                                                  ; 
;   Buffers a palette to be drawn in NMI                        ;
;   Palette pointer must be set                                 ;
;                                                               ;
; Input parameters:                                             ;
;   b: high byte of the target address                          ;
;   c: low byte of the target address                           ;
;   palettePointer: pointer to the palette                      ;
;                                                               ;
; Variables used:                                               ;
;  b                                                            ;
;  c                                                            ;
;  bufferPointer                                                ;
;  palettePointer                                               ;
;****************************************************************

LoadPalette:

  LDY #$00                   ; load 0 to the Y register
  LDA #$10                   ; load $10 = 16 to the A register (we're drawing a palette == 16 bytes)
  STA [bufferPointer], y     ; set that to byte 0 of the buffer segment
                             
  INY                        ; increment the Y register (now Y == 1)
  LDA b                      ; load the high byte of the target address
  STA [bufferPointer], y     ; set that to byte 1 of the buffer segment
                             
  INY                        ; increment the Y register (now Y == 2)
  LDA c                      ; load the low byte of the target address
  STA [bufferPointer], y     ; set that to byte 2 of the buffer segment   

  INY                        ; increment the Y register (now Y == 3)
  STY b                      ; store the value of the Y register (buffer offset) in b
  LDY #$00                   ; start out at 0
                             
  .bufferedDrawLoop:          
    LDA [palettePointer], y  ; load a byte of the palette data
    STY c                    ; store current source offset in c
    
    LDY b                    ; load the buffer offset from b
    STA [bufferPointer], y   ; write to the buffer
    INY                      ; Y = Y + 1
    STY b                    ; store the new buffer offset back to the b
    
    LDY c                    ; load the source offset from c
    INY                      ; Y = Y + 1
    CPY #$10                 ; compare Y to hex $10, decimal 16 - copying 16 bytes
    BNE .bufferedDrawLoop    ; loop if there's more data to be copied
                             
  LDA b                      ; load the buffer offset from b
  CLC                        
  ADC bufferPointer              
  STA bufferPointer          ; add it to bufferPointer to point to the next segment
  LDA bufferPointer + $01             
  ADC #$00                   
  STA bufferPointer + $01    ; add carry to the high byte
  
  RTS
  
;****************************************************************
; Name:                                                         ;
;   ClearPalettes                                               ;
;                                                               ;
; Description:                                                  ; 
;   Clears both palettes. Cannot be called with NMI enabled.    ; 
;****************************************************************

ClearPalettes:

  LDA $2002  
  LDA #$3F
  STA $2006  
  LDA #$00
  STA $2006  
 
  LDX #$00
  LDA #$0F
  
  .loop:
    STA $2007
    INX      
    CPX #$20            
    BNE .loop
    
  RTS