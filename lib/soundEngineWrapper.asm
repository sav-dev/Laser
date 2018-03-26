;****************************************************************
; SoundEngineWrapper                                            ;
; Wrapper for all sound enigne calls                            ;
;****************************************************************

;****************************************************************
; Name:                                                         ;
;   SoundEngineInit                                             ;
;                                                               ;
; Description:                                                  ;
;   Initializes the sound engine                                ;
;****************************************************************

SoundEngineInit:
  ;LDA #SOUND_REGION_NTSC
  ;STA sound_param_byte_0
  ;LDA #LOW(song_list)
  ;STA sound_param_word_0
  ;LDA #HIGH(song_list)
  ;STA sound_param_word_0 + $01
  ;LDA #LOW(sfx_list)
  ;STA sound_param_word_1
  ;LDA #HIGH(sfx_list)
  ;STA sound_param_word_1 + $01
  ;JSR sound_initialize
  ;LDA #$FF
  ;STA currentSong
  RTS
  
;****************************************************************
; Name:                                                         ;
;   PlaySong                                                    ;
;                                                               ;
; Description:                                                  ;
;   Plays a song (unless it's already playing)                  ;
;                                                               ;
; Input vars:                                                   ;
;   sound_param_byte_0 - index of the song to play              ;
;****************************************************************
  
PlaySong:
  ;LDA sound_param_byte_0
  ;CMP currentSong
  ;BNE .playSong
  RTS  
  ;.playSong:  
  ;  STA currentSong
  ;  JSR play_song
  ;  RTS

;****************************************************************
; Name:                                                         ;
;   PlaySongNone                                                ;
;                                                               ;
; Description:                                                  ;
;   Plays the "none" song                                       ;
;****************************************************************
  
PlaySongNone:
  ;LDA #song_index_song_none
  ;STA sound_param_byte_0
  ;JSR PlaySong
  RTS
  
;****************************************************************
; Name:                                                         ;
;   PlaySongEditor                                              ;
;                                                               ;
; Description:                                                  ;
;   Plays the "editor" song                                     ;
;****************************************************************
  
PlaySongEditor:
  ;LDA #song_index_editor_song
  ;STA sound_param_byte_0
  ;JSR PlaySong
  RTS  
    
  
;****************************************************************
; Name:                                                         ;
;   PlaySongLaser                                               ;
;                                                               ;
; Description:                                                  ;
;   Plays the "laser" song                                      ;
;****************************************************************
  
PlaySongLaser:
  ;LDA #song_index_laser
  ;STA sound_param_byte_0
  ;JSR PlaySong
  RTS      
    
;****************************************************************
; Name:                                                         ;
;   SfxInvalid                                                  ;
;                                                               ;
; Description:                                                  ;
;   Plays the "invalid" sfx                                     ;
;****************************************************************

SfxInvalid:
  ;LDA #sfx_index_sfx_invalid
  ;STA sound_param_byte_0
  ;LDA #soundeffect_one
  ;STA sound_param_byte_1
  ;JSR play_sfx
  RTS
  
;****************************************************************
; Name:                                                         ;
;   SfxAction                                                   ;
;                                                               ;
; Description:                                                  ;
;   Plays the "action" sfx                                      ;
;****************************************************************

SfxAction:
  ;LDA #sfx_index_sfx_action
  ;STA sound_param_byte_0
  ;LDA #soundeffect_one
  ;STA sound_param_byte_1
  ;JSR play_sfx
  RTS
  
;****************************************************************
; Name:                                                         ;
;   SfxMirror                                                   ;
;                                                               ;
; Description:                                                  ;
;   Plays the "mirror" sfx                                      ;
;****************************************************************

SfxMirror:
  ;LDA #sfx_index_sfx_mirror
  ;STA sound_param_byte_0
  ;LDA #soundeffect_one
  ;STA sound_param_byte_1
  ;JSR play_sfx
  RTS
  
;****************************************************************
; Name:                                                         ;
;   SfxTarget                                                   ;
;                                                               ;
; Description:                                                  ;
;   Plays the "target" sfx                                      ;
;****************************************************************

SfxTarget:
  ;LDA #sfx_index_sfx_target
  ;STA sound_param_byte_0
  ;LDA #soundeffect_one
  ;STA sound_param_byte_1
  ;JSR play_sfx
  RTS
  
;****************************************************************
; Name:                                                         ;
;   SfxSuccess                                                  ;
;                                                               ;
; Description:                                                  ;
;   Plays the "success" sfx                                     ;
;****************************************************************

SfxSuccess:
  ;LDA #sfx_index_sfx_success
  ;STA sound_param_byte_0
  ;LDA #soundeffect_one
  ;STA sound_param_byte_1
  ;JSR play_sfx
  RTS
