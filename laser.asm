;****************************************************************
; iNES headers                                                  ;
;****************************************************************

  .inesprg 2  ; 2x 16KB PRG code (banks 0-3)
  .ineschr 1  ; 1x  8KB CHR data (bank 4)
  .inesmap 0  ; mapper 0 = NROM, no bank swapping
  .inesmir 0  ; horizontal mirroring (doesn't matter)
  
;****************************************************************
; Global constants                                              ;
;****************************************************************

  .include "inc\constants.asm"

;****************************************************************
; Variables                                                     ;
;****************************************************************
    
  .include "inc\sprites.asm"
  .include "inc\zeroPage.asm"
  .include "inc\variables.asm"
  
;****************************************************************
; RESET handler                                                 ;
;****************************************************************

  .bank 2
  .org $C000 
RESET:
  SEI               ; disable IRQs
  CLD               ; disable decimal mode
  LDX #$40          
  STX $4017         ; disable APU frame IRQ
  LDX #$FF          
  TXS               ; Set up stack
  INX               ; now X = 0
  STX $2000         ; disable NMI
  STX $2001         ; disable rendering
  STX $4010         ; disable DMC IRQs
                    
vblankwait1:        ; First wait for vblank to make sure PPU is ready
  BIT $2002         
  BPL vblankwait1   
                    
clrmem:             
  LDA #$00          
  STA $0000, x      
  STA $0100, x      
  STA $0300, x      
  STA $0400, x      
  STA $0500, x      
  STA $0600, x      
  STA $0700, x      
  INX
  BNE clrmem        
     
vblankwait2:        ; Second wait for vblank, PPU is ready after this
  BIT $2002              
  BPL vblankwait2
  
;****************************************************************
; Initialization logic                                          ;
;****************************************************************
  
initSoundEngine:  
  JSR SoundEngineInit
  
initGame:
  LDA #GAMESTATE_NONE
  STA gameState
  LDA #$00
  STA currentLevel  
  
initPPU:
  LDA #$00                 
  STA needDma
  STA needDraw
  STA needPpuReg
                                                                                
  LDA #BUFFER_LOW_BYTE     ; init the buffer pointer
  STA bufferPointer            
  LDA #BUFFER_HIGH_BYTE    
  STA bufferPointer + $01                            
                           
  JSR ClearPalettes        ; clear all palettes so there's no initial color flashing
  JSR ClearSprites         ; clear all sprites
  JSR ClearBackground      ; clear the background
                           
  LDA #%00000110           ; init PPU - disable sprites and background
  STA soft2001             
  STA $2001                
  LDA #%10010000           ; enable NMI
  STA soft2000             
  STA $2000                
  BIT $2002                
  LDA #$00                 ; no horizontal scroll
  STA $2005                
  LDA #$00                 ; no vertical scroll
  STA $2005                
                
  INC needDma
  INC needDraw
  JSR WaitForFrame         ; wait for one frame for everything to get loaded
  
;****************************************************************
; Game loop                                                     ;
;****************************************************************

GameLoop:
  
  .readController:
    JSR ReadController      ; always read controller input first    
  .readControllerDone:      
                            
  .checkGameState:          
    LDA gameState
    CMP #GAMESTATE_TITLE
    BEQ .gameStateTitle
    CMP #GAMESTATE_PRELEVEL
    BEQ .gameStatePreLevel
    CMP #GAMESTATE_PASSWORD
    BEQ .gameStatePassword    
    CMP #GAMESTATE_EDITOR   
    BEQ .gameStateEditor    
    CMP #GAMESTATE_FIRING_LASER
    BEQ .gameStateFiringLaser
    CMP #GAMESTATE_END_GAME
    BEQ .gameStateEndGame    
    JMP .gameStateNone      ; nothing was matched => game state is "none"  
  .checkGameStateDone:      

  .gameStateTitle:
    JSR TitleFrame
    JMP GameLoopDone
  .gameStateTitleDone:

  .gameStatePassword:
    JSR PasswordFrame
    JMP GameLoopDone
  .gameStatePasswordDone:
  
  .gameStatePreLevel:
    JSR PreLevelFrame
    JMP GameLoopDone
  .gameStatePreLevelDone:

  .gameStateEditor:         
    JSR EditorFrame           
    JMP GameLoopDone        
  .gameStateEditorDone:     
                            
  .gameStateFiringLaser:
    JSR FiringLaserFrame
    JMP GameLoopDone
  .gameStateFiringLaserDone:

  .gameStateEndGame:
    JSR EndGameFrame
    JMP GameLoopDone
  .gameStateEndGameDone:
  
  .gameStateNone:           
    JSR LoadTitle
    JMP GameLoopDone        
  .gameStateNoneDone:       
                            
GameLoopDone:               
  JSR WaitForFrame          ; always wait for a frame at the end of the loop iteration
  JMP GameLoop
  
;****************************************************************
; NMI handler                                                   ;
;****************************************************************

NMI:
  PHA                       ; back up registers
  TXA                       
  PHA                       
  TYA                       
  PHA                       
                            
  LDA needDma               
  BEQ DmaDone               
    LDA #SPRITES_LOW_BYTE   ; do sprite DMA
    STA $2003               ; conditional via the 'needDma' flag
    LDA #SPRITES_HIGH_BYTE  
    STA $4014               
    DEC needDma             
  DmaDone:                  
                            
  LDA needDraw              ; do other PPU drawing
  BEQ DrawDone              ; conditional via the 'needDraw' flag
    BIT $2002               ; clear VBl flag, reset $2005/$2006 toggle
    JSR DoDrawing           ; draw the stuff from the drawing buffer
    DEC needDraw            
  DrawDone:                 
                            
  LDA needPpuReg            ; PPU register updates
  BEQ PpuRegDone            ; conditional via the 'needPpuReg' flag
    LDA soft2001            ; copy buffered $2000/$2001
    STA $2001               
    LDA soft2000            
    STA $2000               
                            
    BIT $2002               ; set the scroll
    LDA #$00
    STA $2005               
    LDA #$00
    STA $2005               
    DEC needPpuReg          
  PpuRegDone:               
                             
  soundengine_update
                            
  LDA #$00                  ; clear the sleeping flag so that WaitForFrame will exit
  STA sleeping              
                            
  INC frameCount            ; INC the frame count
                            
  PLA                       ; restore regs and exit
  TAY                       
  PLA
  TAX
  PLA
  RTI

  RTI
  
;****************************************************************
; Global subroutines                                            ;
;****************************************************************

;****************************************************************
; Name:                                                         ;
;   WaitForFrame                                                ;
;                                                               ;
; Description:                                                  ;
;   Wait for NMI to happen, then exit                           ;
;****************************************************************

WaitForFrame
  INC sleeping
  .loop:
    LDA sleeping
    BNE .loop
  RTS

;****************************************************************
; Name:                                                         ;
;   ClearSprites                                                ;
;                                                               ;
; Description:                                                  ;
;   Clears all 64 sprites by setting all values to $FE          ;
;****************************************************************

ClearSprites:
  LDA #CLEAR_SPRITE
  LDX #$FF

  .loop:
    STA $0200, x
    DEX
    BNE .loop
    
  RTS
  
;****************************************************************
; Name:                                                         ;
;   SleepForXFrames                                             ;
;                                                               ;
; Description:                                                  ;
;   Wait for NMI to happen X times, then exit                   ;
;****************************************************************

SleepForXFrames:
  .loop:
    JSR WaitForFrame
    DEX
    BNE .loop
    
  RTS

;****************************************************************
; Name:                                                         ;
;   DoDrawing                                                   ;
;                                                               ;
; Description:                                                  ;
;   Copies buffered draw data to the PPU.                       ;
;****************************************************************
  
DoDrawing:

  LDA #BUFFER_LOW_BYTE     ; load the address of the buffer
  STA drawPointer         
  LDA #BUFFER_HIGH_BYTE     
  STA drawPointer + $01      

  LDA bufferMode
  BEQ .tile                ; #BUFFER_MODE_TILE == 0
  
  .metatile:
    JSR DoDrawingMetatile
    JMP DoDrawingDone
    
  .tile:
    JSR DoDrawingTile
    
DoDrawingDone:
  RTS
  
;****************************************************************
; Name:                                                         ;
;   DoDrawingTile                                               ;
;                                                               ;
; Description:                                                  ;
;   Copies buffered draw data to the PPU.                       ;
;   Tile mode version.                                          ;
;   Input data has the following format:                        ;
;     Byte 0  = length                                          ;
;     Byte 1  = high byte of the PPU address                    ;
;     Byte 2  = low byte of the PPU address                     ;
;     Byte 3+ = {length} bytes                                  ;
;                                                               ;
;   Repeat until length == 0 is found.                          ;
;   Data starts at BUFFER_HIGH_BYTE;BUFFER_LOW_BYTE             ;
;                                                               ;
;   Uses the drawPointer and resets the bufferPointer           ;
;****************************************************************

DoDrawingTile:

  .draw:                    
    
    LDA $2002                 ; read PPU status to reset the high/low latch    
    
    LDY #$00                  ; load 0 to the Y register
    LDA [drawPointer], y      ; load the length of the data
    BEQ DoDrawingTileDone     ; length equal 0 means that the drawing is done  
    
    LDY #$01                  ; load 1 to the Y register
    LDA [drawPointer], y      ; load the high byte of the target address
    STA $2006                 ; write the high byte to PPU
    LDA #$00
    STA [drawPointer], y      ; reset the high byte to 0
    
    INY                       ; increment Y
    LDA [drawPointer], y      ; load the low byte of the target address
    STA $2006                 ; write the low byte to PPU
    LDA #$00
    STA [drawPointer], y      ; reset the low byte to 0
    
    LDY #$00                  ; load 0 to the Y register
    LDA [drawPointer], y      ; load the length of the data again
    TAX                       ; transfer the length to the X register
                              ; we're not resetting the data yet since we'll need it later
                              
    LDY #$03                  ; load 3 to the Y register (where data starts)
    
    .loop:      
      LDA [drawPointer], y    ; load a byte of the data
      STA $2007               ; write it to PPU
      LDA #$00
      STA [drawPointer], y    ; reset the data byte to #$00
      INY                     ; increment Y
      DEX                     ; decrement X
      BNE .loop               ; if X != 0 jump to .copyLoop
      
    LDY #$00                  ; load 0 to the Y register
    LDA [drawPointer], y      ; load the length of the data again
    TAX                       ; transfer the length of the data to X
    LDA #$00
    STA [drawPointer], y      ; reset the length to 0
    TXA                       ; transfer the length of the data back to A
    
    CLC
    ADC drawPointer           ; add the length of previous data to drawPointerLo
    STA drawPointer
    LDA drawPointer + $01
    ADC #$00                  ; add carry to the high byte
    STA drawPointer + $01
    
    LDA drawPointer
    CLC
    ADC #$03                  ; must add 3 to drawPointerLo to make sure it's pointing to next segment
    STA drawPointer
    LDA drawPointer + $01     
    ADC #$00                  ; add carry to the high byte
    STA drawPointer + $01
    
    JMP .draw                 ; jump back to draw
 
DoDrawingTileDone:

  LDA #BUFFER_LOW_BYTE        ; reset the buffer pointer to default values
  STA bufferPointer
  LDA #BUFFER_HIGH_BYTE
  STA bufferPointer + $01

  RTS

;****************************************************************
; Name:                                                         ;
;   DoDrawingMetatile                                           ;
;                                                               ;
; Description:                                                  ;
;   Copies buffered draw data to the PPU.                       ;
;   Metatile mode version.                                      ;
;****************************************************************

DoDrawingMetatile:

  JMP .draw

  .done:
    JMP DoDrawingMetatileDone

  .draw:                    
    
    LDA $2002                  ; read PPU status to reset the high/low latch      
                               
    LDY #$00                   
    LDA [drawPointer], y       ; load the high byte of the first row address
    BEQ .done                  ; high byte equal 0 means that the drawing is done  
    STA $2006                  ; write to PPU
    LDA #$00                   
    STA [drawPointer], y       ; reset to 0
                               
    INY                        
    LDA [drawPointer], y       ; load the low byte of the first row address
    STA $2006                  ; write to PPU
    LDA #$00                   
    STA [drawPointer], y       ; reset to 0
                               
    INY                        
    LDA [drawPointer], y       ; load tile 0
    STA $2007                  ; write to PPU
    LDA #$00                   
    STA [drawPointer], y       ; reset to 0
                               
    INY                        
    LDA [drawPointer], y       ; load tile 1
    STA $2007                  ; write to PPU
    LDA #$00                   
    STA [drawPointer], y       ; reset to 0
                               
    LDA $2002                  ; read PPU status to reset the high/low latch      
                               
    INY                        
    LDA [drawPointer], y       ; load the high byte of the second row address
    STA $2006                  ; write to PPU
    LDA #$00                   
    STA [drawPointer], y       ; reset to 0
                               
    INY                        
    LDA [drawPointer], y       ; load the low byte of the second row address
    STA $2006                  ; write to PPU
    LDA #$00                   
    STA [drawPointer], y       ; reset to 0
                               
    INY                        
    LDA [drawPointer], y       ; load tile 2
    STA $2007                  ; write to PPU
    LDA #$00                   
    STA [drawPointer], y       ; reset to 0
                               
    INY                        
    LDA [drawPointer], y       ; load tile 3
    STA $2007                  ; write to PPU
    LDA #$00                   
    STA [drawPointer], y       ; reset to 0  
                               
    LDA $2002                  ; read PPU status to reset the high/low latch      
                               
    INY                        
    LDA [drawPointer], y       ; load the high byte of the atts address
    STA $2006                  ; write to PPU
    LDA #$00                   
    STA [drawPointer], y       ; reset to 0
                               
    INY                        
    LDA [drawPointer], y       ; load the low byte of the atts address
    STA $2006                  ; write to PPU
    LDA #$00                   
    STA [drawPointer], y       ; reset to 0
                               
    INY                        
    LDA [drawPointer], y       ; load atts
    STA $2007                  ; write to PPU
    LDA #$00                   
    STA [drawPointer], y       ; reset to 0   
    
    LDA drawPointer
    CLC
    ADC #METATILE_SIZE_BUFFER  ; advance the draw pointer
    STA drawPointer
    LDA drawPointer + $01
    ADC #$00
    STA drawPointer + $01
        
    JMP .draw                  ; jump back to draw
                               
DoDrawingMetatileDone:         
                               
  LDA #BUFFER_LOW_BYTE         ; reset the buffer pointer to default values
  STA bufferPointer
  LDA #BUFFER_HIGH_BYTE
  STA bufferPointer + $01

  RTS
  
;****************************************************************
; Name:                                                         ;
;   FadeOut                                                     ;
;                                                               ;
; Description:                                                  ;
;   Fades out to black                                          ;
;****************************************************************

FadeOut:

  LDA #%00111110           ; intensify reds
  STA soft2001             
  INC needPpuReg           
  LDX #$04
  JSR SleepForXFrames
  
  LDA #%01111110           ; intensify greens and reds
  STA soft2001             
  INC needPpuReg           
  LDX #$04
  JSR SleepForXFrames

  LDA #%00000100           ; disable PPU
  STA soft2001
  INC needPpuReg
  LDX #$04
  JSR SleepForXFrames
  
  RTS

;****************************************************************
; Name:                                                         ;
;   DisablePPU                                                  ;
;                                                               ;
; Description:                                                  ;
;   Disable sprites and backgrounds                             ;
;****************************************************************
  
DisablePPU:  
  LDA #%00000110                ; disable sprites and background
  STA soft2001                  
  INC needPpuReg                
  JSR WaitForFrame              
  RTS
  
;****************************************************************
; Modules import                                                ;
;****************************************************************

  .include "lib\backgroundManager.asm"
  .include "lib\controllerManager.asm"
  .include "lib\laserProcessor.asm"   
  .include "lib\levelManager.asm"
  .include "lib\paletteManager.asm"  
  .include "lib\soundEngineWrapper.asm"
  .include "lib\stringManager.asm"
  
  .include "states\stateEditor.asm"
  .include "states\stateFiringLaser.asm"
  .include "states\statePassword.asm"
  
  .bank 3
  .org $E000

  .include "states\statePreLevel.asm"
  .include "states\stateEndGame.asm"  
  .include "states\stateTitle.asm"  
  
  .include "sound\ggsound.asm"  
  
  .include "sound\sound.asm"  
  
  .include "data\tiles.asm"  
  .include "data\levels\levels.asm"
  
  .bank 0
  .org $8000
    
  .bank 1
  .org $A000

;****************************************************************
; Vectors                                                       ;
;****************************************************************

  .bank 3
  .org $FFFA  ; vectors starts here
  .dw NMI     ; when an NMI happens (once per frame if enabled) the processor will jump to the label NMI:
  .dw RESET   ; when the processor first turns on or is reset, it will jump to the label RESET:
  .dw 0       ; external interrupt IRQ is not used

;****************************************************************
; CHR import                                                    ;
;****************************************************************
  
  .bank 4
  .org $0000

  .incbin "graphics\chr\graphics.chr"