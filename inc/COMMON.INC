;----------------------------------------------------------------------------
; COMMON.INC - Definitions shared by all the modules: constants, segments
;              and the symbols the modules use from each other.
;----------------------------------------------------------------------------

                .386

;--------------------------------------------------------------- CONSTANTS

BS              equ     20              ;marks backspace in the scan code tables
CR              equ     13              ;marks enter in the scan code tables
; Bits of flags and curr_flags.
fadeflag        equ     1
soundflag       equ     2
lshiftflag      equ     4
rshiftflag      equ     8
nextflag        equ     16
first_x         equ     115             ;x of the left edge of the playfield
n_p             equ     320*28+40       ;x+y*320 of the next piece preview
; High score screen.
high_a_x        equ     11              ;left edge of the game A names
high_b_x        equ     164             ;left edge of the game B names
high_a_xr       equ     157             ;right edge of the game A scores
high_b_xr       equ     310             ;right edge of the game B scores
high_a_y        equ     74              ;y of the first row of game A
high_b_y        equ     74              ;y of the first row of game B
high_bg_y       equ     10              ;y of the background picture
vga_seg         equ     0a000h          ;segment of the VGA screen memory

;---------------------------------------------------------------- GRAPHICS

; The graphics are linked in from the ready-made OBJ files in the GFX
; directory.

                extrn   fontti:byte
                extrn   picture:byte
                extrn   logo:byte
                extrn   requester:byte
                extrn   palat:byte
                extrn   high_tausta:byte

;------------------------------------------------------------- DATA SEGMENT

; GLOBAL makes a symbol public in the module that defines it and external
; in the modules that only use it.

dseg            segment para public use16 'DATA'

; DATA.ASM
                global  highscore_filename:byte, setup_filename:byte
                global  data_handle:word, text_1:byte, text_2:byte
                global  text_3:byte, text_6:byte, text_info:byte, text_4:byte
                global  setup_menu:byte, setup_1:byte, setup_2off:byte
                global  setup_2on:byte, setup_3off:byte, setup_3on:byte
                global  setup_4off:byte, setup_4on:byte, setup_5:byte
                global  level_text:byte, game_over_tx:byte, a_again_tx:byte
                global  main_men_tx:byte, high_score_tx:byte
                global  type_name_tx:byte, player_name:word
                global  redefine_text:byte, left_key_text:byte
                global  right_key_text:byte, rcw_key_text:byte
                global  rccw_key_text:byte, drop_key_text:byte
                global  sound_key_text:byte, next_key_text:byte
                global  pause_key_text:byte, int_conv_buf:byte
                global  converter:byte, empty_buf2:byte, empty_buf:byte
                global  info_texts:word, piece_shapes:word, preview_coords:word
                global  key_names:word, ascii_dcase:byte, ascii_ucase:byte
                global  curr_flags:byte, flags:byte, left_key:word
                global  right_key:word, cw_rotate:word, ccw_rotate:word
                global  drop_key:word, sound_key:word, next_key:word
                global  pause_key:word, timer:byte, speed:byte
                global  number_of_pieces:byte, level:byte, rows:word
                global  score:word, text_x:word, text_y:word
                global  current_piece:word, current_angle:word
                global  current_row:word, current_column:word
                global  next_piece:word, next_angle:word, name_counter:word
                global  random_seed:word, keycode:word, old_kb_seg:word
                global  old_kb_off:word, lines_eliminated:word
                global  old_video_mode:byte, palette:byte, font_chars:byte
                global  font_widths:word, font_offsets:word, hstab_a:byte
                global  hstab_b:byte

dseg            ends

;------------------------------------------------------------- CODE SEGMENT

; The code segment is byte aligned, so the linker joins the code of the
; modules together without any padding in between.

cseg            segment byte public use16 'CODE'

; PALETTE.ASM
                global  clear_palette:near, fade_out:near, fade_in:near
                global  set_pal:near

; MENU.ASM
                global  game_menu:near, ask_level:near

; SCREEN.ASM
                global  center_text:near, right_align_int:near
                global  output_text:near, text_width:near, clear_screen:near

; GAME.ASM
                global  game:near

; MOVE.ASM
                global  drop:near, drop_at_once:near, move_right:near
                global  move_left:near, rotate:near, rotate2:near

; SCORE.ASM
                global  check_lines:near, show_score:near, conv_int:near

; NEXT.ASM
                global  pick_next_piece:near, draw_next:near, clr_next:near

; FILES.ASM
                global  read_highscores:near, write_highscores:near
                global  read_setup:near, write_setup:near

; PIECE.ASM
                global  put_piece:near, put_put:near, clr_piece:near
                global  clr_clr:near, test_piece:near

; KEYBOARD.ASM
                global  set_kbhandler:near, remove_kbhandler:near

cseg            ends
