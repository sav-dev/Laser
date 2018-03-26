;****************************************************************
; ControllerManager                                             ;                           
; Responsible for checking the state of the controller          ;
;****************************************************************

;****************************************************************
; Name:                                                         ;
;   ReadController                                              ;
;                                                               ;
; Description:                                                  ;
;   Reads the state of the first controller                     ;
;                                                               ;
; Variables used:                                               ;
;  b                                                            ;
;****************************************************************

ReadController:
 
  .readController:
  
    LDA #$01
    STA $4016
    LDA #$00
    STA $4016                 ; latch buttons
    LDX #$08                  ; read 8 buttons for player 1
                              
    .loop:                    
      LDA $4016               
      LSR A                   
      ROL b                   ; store the buttons in b for now
      DEX
      BNE .loop
    
    ; We "NOT" the previous state of controllers, and "AND" it with the current one
    ; to get the list of buttons pressed since the last time ReadController was called.
    ;
    ; E.g. if previously this was the state of controllers: 11000110
    ; And this is the current one: 10001001
    ; This is what will happen:
    ;
    ;   NOT(11000110) = 00111001
    ;   00111001 AND 10001001 = 00001001
     
    LDA #$FF
    EOR controllerDown        ; NOT previous state of controllers
    AND b                     ; AND with the current state
    STA controllerPressed     ; store that as controllerPressed
    LDA controllerDown        ; load previous state of controllers
    STA controllerPrevious    ; store that in controllerPrevious
    LDA b                     ; load the placeholder
    STA controllerDown        ; finally, store that as current state of controllers
    
  .readControllerDone:
  
  .processController:
  
    LDA #$00
    STA controllerActive      ; reset controller active
  
    .checkUp:
    
      LDA controllerPressed   ; check if up was just pressed 
      AND #CONTROLLER_UP   
      BNE .setUp             
      
      LDA controllerDown      ; check if up has been previously pressed
      AND #CONTROLLER_UP
      BNE .checkTimerUp
      
      LDA #$00                ; up not down - reset timer to 0
      STA upTimer
      JMP .checkUpDone
      
      .checkTimerUp:
        
        INC upTimer
        LDA upTimer
        CMP #TIMER_THRESHOLD
        BNE .checkUpDone
        
        SEC
        SBC #TIMER_DECREASE
        STA upTimer
      
      .setUp:
      
        LDA #CONTROLLER_UP
        ORA controllerActive
        STA controllerActive
       
    .checkUpDone:
    
    .checkRight:
    
      LDA controllerPressed   ; check if right was just pressed 
      AND #CONTROLLER_RIGHT   
      BNE .setRight             
      
      LDA controllerDown      ; check if right has been previously pressed
      AND #CONTROLLER_RIGHT
      BNE .checkTimerRight
      
      LDA #$00                ; right not down - reset timer to 0
      STA rightTimer
      JMP .checkRightDone    
    
      .checkTimerRight:
        
        INC rightTimer
        LDA rightTimer
        CMP #TIMER_THRESHOLD
        BNE .checkRightDone
        
        SEC
        SBC #TIMER_DECREASE
        STA rightTimer
      
      .setRight:  
    
        LDA #CONTROLLER_RIGHT
        ORA controllerActive
        STA controllerActive
        
    .checkRightDone:
    
    .checkDown:
    
      LDA controllerPressed   ; check if down was just pressed 
      AND #CONTROLLER_DOWN
      BNE .setDown             
      
      LDA controllerDown      ; check if down has been previously pressed
      AND #CONTROLLER_DOWN
      BNE .checkTimerDown
      
      LDA #$00                ; down not down - reset timer to 0
      STA downTimer
      JMP .checkDownDone    
      
      .checkTimerDown:
        
        INC downTimer
        LDA downTimer
        CMP #TIMER_THRESHOLD
        BNE .checkDownDone
        
        SEC
        SBC #TIMER_DECREASE
        STA downTimer
      
      .setDown:
        
        LDA #CONTROLLER_DOWN
        ORA controllerActive
        STA controllerActive
      
    .checkDownDone:
    
    .checkLeft:
    
      LDA controllerPressed   ; check if left was just pressed 
      AND #CONTROLLER_LEFT   
      BNE .setLeft             
      
      LDA controllerDown      ; check if left has been previously pressed
      AND #CONTROLLER_LEFT
      BNE .checkTimerLeft
      
      LDA #$00                ; left not down - reset timer to 0
      STA leftTimer
      JMP .checkLeftDone
      
      .checkTimerLeft:
        
        INC leftTimer
        LDA leftTimer
        CMP #TIMER_THRESHOLD
        BNE .checkLeftDone
        
        SEC
        SBC #TIMER_DECREASE
        STA leftTimer
      
      .setLeft:  
    
        LDA #CONTROLLER_LEFT
        ORA controllerActive
        STA controllerActive
      
    .checkLeftDone:
    
    .checkSelect:
    
      LDA controllerPressed   ; check if select was just pressed 
      AND #CONTROLLER_SEL   
      BNE .setSelect             
      
      LDA controllerDown      ; check if select has been previously pressed
      AND #CONTROLLER_SEL
      BNE .checkTimerSelect
      
      LDA #$00                ; select not down - reset timer to 0
      STA selectTimer
      JMP .checkSelectDone
      
      .checkTimerSelect:
        
        INC selectTimer
        LDA selectTimer
        CMP #TIMER_THRESHOLD
        BNE .checkSelectDone
        
        SEC
        SBC #TIMER_DECREASE
        STA selectTimer
      
      .setSelect:  
    
        LDA #CONTROLLER_SEL
        ORA controllerActive
        STA controllerActive
      
    .checkSelectDone:  
  
    .checkB:
    
      LDA controllerPressed   ; check if select was just pressed 
      AND #CONTROLLER_B
      BNE .setB

      LDA controllerDown      ; check if select has been previously pressed
      AND #CONTROLLER_B
      BNE .checkTimerB
      
      LDA #$00                ; select not down - reset timer to 0
      STA bTimer
      JMP .checkBDone
      
      .checkTimerB:
        
        INC bTimer
        LDA bTimer
        CMP #TIMER_THRESHOLD
        BNE .checkBDone
        
        SEC
        SBC #TIMER_DECREASE
        STA bTimer
      
      .setB:  
    
        LDA #CONTROLLER_B
        ORA controllerActive
        STA controllerActive
      
    .checkBDone:  
  
    ; add checkA and checkStart if needed
  
  .processControllerDone:
  
  RTS

;****************************************************************
; Name:                                                         ;
;   ResetTimers                                                 ;
;                                                               ;
; Description:                                                  ;
;   Resets all timers used for processing controllers           ;
;****************************************************************

ResetTimers:
  LDA #$00
  STA upTimer
  STA rightTimer
  STA downTimer
  STA leftTimer
  STA selectTimer
  RTS