;----------------------------------------------------------------------------
; GAME.ASM - The game itself: main loop, key handling, game over and typing a
;            name into the high score table.
;----------------------------------------------------------------------------

                include common.inc

cseg            segment
                assume  cs:cseg,ds:dseg

; Plays games until the player returns to the menu.
game            proc    near

                mov     dx,seg dseg
                mov     ds,dx
                mov     al,ds:[flags]
                mov     ds:[curr_flags],al

new_game:       call    ask_level
                cmp     al,1h
                jnz     start_game
                ret
; Draw the playfield picture.
start_game:     mov     dx,seg picture
                mov     ds,dx
                mov     si,offset picture
                mov     dx,vga_seg
                mov     es,dx
                xor     di,di
                mov     cx,16000
                rep     movsd

                mov     dx,seg dseg
                mov     ds,dx

; speed = 31-3*level frames between drops
                mov     al,ds:[level]
                mov     bl,3
                mul     bl
                mov     bl,4+9*3
                sub     bl,al
                mov     ds:[speed],bl

; Pick twice: the first call fills the next piece, the second makes it
; the current one.
                mov     ds:[next_piece],0
                mov     ds:[next_angle],0
                call    pick_next_piece
                call    pick_next_piece

                mov     al,ds:[speed]
                dec     al
                mov     ds:[timer],al
                mov     ds:[rows],0
                mov     ds:[current_row],0
                mov     ds:[score],0
                mov     ds:[current_column],4

                call    show_score
                call    fade_in

; Main loop: poll the keyboard until the vertical retrace, then count the
; frame and drop the piece when the timer reaches speed.
wait_loop:      mov     dx,seg dseg
                mov     ds,dx
                mov     dx,3dah
wait_blank:     mov     ax,word ptr ds:[keycode]
                test    al,0ffh
                jnz     key_hit
                in      al,dx
                test    al,8
                jz      wait_blank
wbl2:           in      al,dx
                test    al,8
                jnz     wbl2
                inc     ds:[timer]
                mov     al,ds:[speed]
                cmp     ds:[timer],al
                jnz     no_event
                xor     al,al
                mov     ds:[timer],al
                push    ds
                call    drop
                pop     ds
                test    al,0ffh
                jz      wait_loop

; The piece has landed: 3*(level+1) points.
piece_landed:   xor     ah,ah
                mov     al,ds:[level]
                inc     al
                mov     bl,3
                mul     bl
                add     ds:[score],ax

                push    ds
                call    show_score
                pop     ds

                mov     al,ds:[speed]
                dec     al
                mov     ds:[timer],al

                push    ds
                call    check_lines
                pop     ds
                test    al,0ffh
                jnz     lines_removed

; A piece that landed on the top row ends the game.
                test    ds:[current_row],0ffh
                jz      game_over

lines_removed:  call    pick_next_piece
                mov     ds:[current_row],0
                mov     ds:[current_column],4
no_event:
                jmp     wait_loop

key_hit:        mov     word ptr ds:[keycode],0h

                cmp     byte ptr ds:[ccw_rotate],al
                jnz     no_rotate
                call    rotate
                jmp     wait_loop
no_rotate:
                cmp     byte ptr ds:[cw_rotate],al
                jnz     no_rotate2
                call    rotate2
                jmp     wait_loop
no_rotate2:
                cmp     byte ptr ds:[left_key],al
                jnz     no_left
                call    move_left
                jmp     wait_loop
no_left:
                cmp     byte ptr ds:[right_key],al
                jnz     no_right
                call    move_right
                jmp     wait_loop
no_right:
                cmp     byte ptr ds:[drop_key],al
                jnz     no_spacebar
; Dropping gives (level+20-current_row)/4 extra points.
                xor     ah,ah
                mov     al,ds:[level]
                mov     bx,20
                sub     bx,ds:[current_row]
                add     al,bl
                shr     al,2
                add     ds:[score],ax
                push    ds
                call    drop_at_once
                pop     ds
                jmp     piece_landed
no_spacebar:
                cmp     byte ptr ds:[pause_key],al
                jnz     no_pause

; Pause: black out the screen until the pause key is pressed again.
                pusha
                mov     bl,0
                call    set_pal
                popa

                mov     ds:[keycode],0
wait_for_key:
                mov     ax,word ptr ds:[keycode]
                test    al,0ffh
                jz      wait_for_key
                mov     ds:[keycode],0

                cmp     byte ptr ds:[pause_key],al
                jnz     wait_for_key

                pusha
                mov     bl,32
                call    set_pal
                popa
                jmp     wait_loop
no_pause:
                cmp     ds:[next_key],ax
                jnz     no_next_key
                xor     ds:[curr_flags],nextflag
                pusha
                call    clr_next
                call    draw_next
                popa
no_next_key:
                cmp     ds:[sound_key],ax
                jnz     no_sound_key
                xor     ds:[curr_flags],soundflag
no_sound_key:
                jmp     wait_loop
game_over:
                mov     dx,seg requester
                mov     ds,dx
                mov     si,offset requester
;the requester picture is 159*65 pixels

                mov     dx,vga_seg
                mov     es,dx
                mov     di,80+67*320

                mov     cx,65
req_loop:       push    cx
                mov     cx,159
                rep     movsb
                pop     cx
                add     di,320-159
                loop    req_loop

                mov     dx,dseg
                mov     ds,dx

                call    check_high_score

                mov     si,offset game_over_tx
                mov     ax,159
                mov     bx,80
                call    center_text
                mov     si,offset a_again_tx
                mov     ax,159
                mov     bx,96
                call    center_text
                mov     si,offset main_men_tx
                mov     ax,159
                mov     bx,108
                call    center_text

wait_keyr:      mov     ax,fs:[keycode]
                test    al,0ffh
                jz      wait_keyr
                mov     word ptr ds:[keycode],0h
                cmp     al,1eh          ;A
                jnz     not_again

                call    fade_out
                jmp     new_game
not_again:
                cmp     al,1            ;Esc
                jnz     wait_keyr
                call    fade_out
                ret

; Checks the score against the high score table of the game played. A top
; ten score makes room in the table, asks for a name and saves the tables.

check_high_score:
                pusha

                mov     si,offset hstab_a

                cmp     number_of_pieces,7  ;game A has 7 pieces
                jz      hs_not_game_b
                mov     si,offset hstab_b
hs_not_game_b:
                mov     ax,score

                mov     cx,10
hs_find_loop:   cmp     41[si],ax       ;the score is at offset 41
                jb      bigger
                add     si,43
                loop    hs_find_loop
                jmp     no_high_score
bigger:
                mov     dx,ds
                mov     es,dx
                mov     dx,si
                mov     di,dx

                mov     player_name,dx

; Move the entries from this place on one place down, the last one first.
                mov     ax,43
                mul     cx

                add     si,ax
                add     di,ax

                sub     si,43

hscopyloop:     movsd
                movsd
                movsd
                movsd
                movsd
                movsd
                movsd
                movsd
                movsd
                movsd
                movsw
                movsb
                sub     si,43*2
                sub     di,43*2
                loop    hscopyloop

                mov     di,player_name

; Empty the name of the freed entry and store the score in it.
                mov     name_counter,0h
                mov     byte ptr [di],0h
                mov     ax,score
                mov     word ptr 41[di],ax
                mov     si,offset high_score_tx
                mov     ax,159
                mov     bx,80
                call    center_text
                mov     si,offset type_name_tx
                mov     ax,159
                mov     bx,96
                call    center_text

                mov     word ptr ds:[keycode],0h
wait_keyrrrr:   mov     ax,fs:[keycode]
                test    al,0ffh
                jz      wait_keyrrrr
                mov     word ptr ds:[keycode],0h

; Turn the scan code into a character, upper case with shift.
                mov     si,offset ascii_dcase

                test    ax,100h
                jz      no_shift

                mov     si,offset ascii_ucase
no_shift:
                xor     bx,bx
                mov     bl,al

                mov     al,[si+bx]

                test    al,al
                jz      wait_keyrrrr

; A name does not start with a space.
                cmp     al,' '
                jnz     not_space

                cmp     name_counter,0
                jz      wait_keyrrrr

not_space:

                cmp     al,CR
                jz      name_entered

                mov     si,player_name
                mov     bx,name_counter

                cmp     al,BS
                jnz     not_bs

                test    bx,bx
                jz      redraw_name

                dec     bx
                mov     byte ptr [si+bx],0h
                jmp     redraw_name

not_bs:

; A name holds 40 letters at most and has to fit its column.
                cmp     bx,40
                jz      redraw_name

                pusha

                mov     si,player_name
                call    text_width

                cmp     dx,110

                popa

                ja      redraw_name

                mov     [si+bx],al
                inc     bx
                mov     byte ptr [si+bx],0h

redraw_name:
                mov     name_counter,bx

; Draw the name again over a blanked line.
                mov     si,offset empty_buf2
                mov     ax,159
                mov     bx,108
                call    center_text

                mov     si,player_name
                mov     ax,159
                mov     bx,108
                call    center_text

                jmp     wait_keyrrrr

name_entered:   call    write_highscores

no_high_score:  popa
                ret


                endp

cseg            ends

                end
