;****************************************************************
; Memory layout related constans                                ;
;****************************************************************

; $0000-$000F    16 bytes   Local variables and function arguments  
; $0010-$00FF   240 bytes   Global variables accessed most often, including certain pointer tables  
; $0100-$019F   160 bytes   Data to be copied to nametable during next vertical blank (see The frame and NMIs)  
; $01A0-$01FF    96 bytes   Stack  
; $0200-$02FF   256 bytes   Data to be copied to OAM during next vertical blank  
; $0300-$03FF   256 bytes   Variables used by sound player, and possibly other variables  
; $0400-$07FF  1024 bytes   Arrays and less-often-accessed global variables 

SPRITES_LOW_BYTE        = $00  ; low byte of the sprites page
SPRITES_HIGH_BYTE       = $02  ; high sprite of the sprites page
                                                  
BUFFER_LOW_BYTE         = $00  ; low byte of the data buffer
BUFFER_HIGH_BYTE        = $01  ; high byte of the data buffer

STACK_LOW_BYTE          = $A0  ; low byte of where the stack begins (vide table above)
METATILE_SIZE_BUFFER    = $0B  ; number of bytes buffered for one metatile
MAX_METATILES_BUFFERED  = $06  ; how many metatiles can be buffered in one frame

METATILE_MAX_BUFFER     = BUFFER_LOW_BYTE + (METATILE_SIZE_BUFFER * MAX_METATILES_BUFFERED)

;****************************************************************
; Controllers                                                   ;
;****************************************************************

CONTROLLER_A            = %10000000  ; controller bitmasks
CONTROLLER_B            = %01000000               
CONTROLLER_SEL          = %00100000               
CONTROLLER_START        = %00010000               
CONTROLLER_UP           = %00001000               
CONTROLLER_DOWN         = %00000100               
CONTROLLER_LEFT         = %00000010               
CONTROLLER_RIGHT        = %00000001               
CONTROLLER_L_OR_R       = %00000011               
                        
TIMER_THRESHOLD         = $20  ; button timers related
TIMER_DECREASE          = $03

;****************************************************************
; Graphics related constans                                     ;
;****************************************************************

CLEAR_SPRITE            = $FE  ; when any of the sprite's values are set to this then the sprite is cleared
CLEAR_TILE              = $FE  ; clear background tile
CLEAR_ATTS              = $00  ; clear background atts
                        
Y_OFF                   = $00  ; sprite offsets
TILE_OFF                = $01
ATT_OFF                 = $02
X_OFF                   = $03
                        
SPRITE_OFF              = $04

BUFFER_MODE_TILE        = $00
BUFFER_MODE_METATILE    = $01

;****************************************************************
; Metatiles related constans                                    ;
;****************************************************************

METATILES_WIDTH         = $0D  ; $0D = 14
METATILES_HEIGHT        = $0E  ; $0E = 15
METATILES_COUNT         = $D2  ; $D2 = 210 = 14 (width) x 15 (height). Changes must be reflected in variables->levelMetatiles and variables->levelStates
MAX_AV_ELEMENTS         = $06  ; max. number of available elements. Changes must be reflected in variables->availableElements and sprites->elementCounts
DEFAULT_STATE           = $00  ; default metatile state

;****************************************************************
; Game state                                                    ;
;****************************************************************

GAMESTATE_TITLE         = $00
GAMESTATE_PASSWORD      = $01
GAMESTATE_PRELEVEL      = $02
GAMESTATE_EDITOR        = $03
GAMESTATE_FIRING_LASER  = $04
GAMESTATE_END_GAME      = $05
GAMESTATE_NONE          = $FF

;****************************************************************
; Sound                                                         ;
;****************************************************************

  .include "sound\ggsound.inc"