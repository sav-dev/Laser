;****************************************************************
; StringManager                                                 ;                           
; Responsible for displaying strings                            ;
;****************************************************************

;****************************************************************
; Data & constants:                                             ;
;****************************************************************

strPressStart:
  .byte $0C
  .byte $23, $4A   
  .byte CHAR_P
  .byte CHAR_R
  .byte CHAR_E
  .byte CHAR_S
  .byte CHAR_S
  .byte CHAR_SPACE
  .byte CHAR_SPACE
  .byte CHAR_S
  .byte CHAR_T
  .byte CHAR_A
  .byte CHAR_R
  .byte CHAR_T
  
strPressStartBlank:
  .byte $0C 
  .byte $23, $4A   
  .byte CHAR_SPACE
  .byte CHAR_SPACE
  .byte CHAR_SPACE
  .byte CHAR_SPACE
  .byte CHAR_SPACE
  .byte CHAR_SPACE
  .byte CHAR_SPACE
  .byte CHAR_SPACE
  .byte CHAR_SPACE
  .byte CHAR_SPACE
  .byte CHAR_SPACE
  .byte CHAR_SPACE
  
PS_TIMER_FREQ        = $20        ; frequency of the blinking "press start" string

CHAR_0              = $00
CHAR_1              = $01
CHAR_2              = $02
CHAR_3              = $03
CHAR_4              = $04
CHAR_5              = $05
CHAR_6              = $06
CHAR_7              = $07
CHAR_8              = $08
CHAR_9              = $09
CHAR_A              = $0A
CHAR_B              = $0B
CHAR_C              = $0C
CHAR_D              = $0D
CHAR_E              = $0E
CHAR_F              = $0F
CHAR_G              = $10
CHAR_H              = $11
CHAR_I              = $12
CHAR_J              = $13
CHAR_K              = $14
CHAR_L              = $15
CHAR_M              = $16
CHAR_N              = $17
CHAR_O              = $18
CHAR_P              = $19
CHAR_Q              = $1A
CHAR_R              = $1B
CHAR_S              = $1C
CHAR_T              = $1D
CHAR_U              = $1E
CHAR_V              = $1F
CHAR_W              = $20
CHAR_X              = $21
CHAR_Y              = $22
CHAR_Z              = $23
CHAR_COLON          = $24
CHAR_EXCLAMATION    = $25
CHAR_APOSTROPHE     = $26
CHAR_LEFT           = $27
CHAR_RIGHT          = $28
CHAR_SPACE          = CLEAR_TILE
CHAR_DASH           = $29

;****************************************************************
; Name:                                                         ;
;   PrintString                                                 ;
;                                                               ;
; Description:                                                  ;
;   Print a string based on the data in the pointer             ;
;****************************************************************

PrintString:

  LDY #$00                   ; Y = 0
  LDA [stringPointer], y     ; load the string length
  STA [bufferPointer], y     ; store it in the buffer
  TAX                        ; move the length to X
  
  INY                        ; Y = 1
  LDA [stringPointer], y     ; load the high byte of the destination
  STA [bufferPointer], y     ; store it in the buffer
                             
  INY                        ; Y = 2
  LDA [stringPointer], y     ; load the low byte of the destination
  STA [bufferPointer], y     ; store it in the buffer
                             
  .bufferedDrawLoop:
    INY
    LDA [stringPointer], y   ; load a byte of the draw data
    STA [bufferPointer], y   ; store the byte of draw data in the buffer
    DEX                      ; decrement X (the loop counter)
    BNE .bufferedDrawLoop    ; loop if there's more data to be copied
                
  INY                
  TYA                        ; advance the buffer pointer
  CLC                        
  ADC bufferPointer              
  STA bufferPointer 
  LDA bufferPointer + $01
  ADC #$00      
  STA bufferPointer + $01

  RTS