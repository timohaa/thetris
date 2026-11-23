;----------------------------------------------------------------------------
; GAME.ASM - The game itself: main loop, key handling, game over and typing a
;            name into the high score table.
;----------------------------------------------------------------------------

                include common.inc

cseg            segment
                assume  cs:cseg,ds:dseg

game            proc    near

                mov     dx,seg dseg
                mov     ds,dx
                mov     al,ds:[flags]
                mov     ds:[curr_flags],al

uusi:           call    ask_level
                cmp     al,1h
                jnz     anti_menna
                ret
anti_menna:     mov     dx,seg picture
                mov     ds,dx
                mov     si,offset picture
                mov     dx,0a000h
                mov     es,dx
                xor     di,di
                mov     cx,16000
                rep     movsd

                mov     dx,seg dseg
                mov     ds,dx

                mov     al,ds:[level]
                mov     bl,3
                mul     bl
                mov     bl,4+9*3
                sub     bl,al
                mov     ds:[speed],bl

                mov     ds:[next_piece],0
                mov     ds:[next_angle],0
                call    arvo_next_piece
                call    arvo_next_piece

                mov     al,ds:[speed]
                dec     al
                mov     ds:[timer],al
                mov     ds:[rows],0
                mov     ds:[current_row],0
                mov     ds:[score],0
                mov     ds:[current_column],4

                call    show_score
                call    fade_in
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

pomppa:         xor     ah,ah
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
                jnz     linjoja_poistui

                test    ds:[current_row],0ffh
                jz      game_over

linjoja_poistui:call    arvo_next_piece
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
                jmp     pomppa
no_spacebar:
                cmp     byte ptr ds:[pause_key],al
                jnz     no_pause

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
;159*65

                mov     dx,0a000h
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

                call    high_scoreko

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
                cmp     al,1eh
                jnz     eiuusi

                call    fade_out
                jmp     uusi
eiuusi:
                cmp     al,1
                jnz     wait_keyr
                call    fade_out
                ret

high_scoreko:
                pusha

                mov     si,offset hstab_a

                cmp     number_of_pieces,7
                jz      hsgame_eib
                mov     si,offset hstab_b
hsgame_eib:
                mov     ax,score

                mov     cx,10
hs_looppi:      cmp     41[si],ax
                jb      bigger
                add     si,43
                loop    hs_looppi
                jmp     ei_highscorea
bigger:
                mov     dx,ds
                mov     es,dx
                mov     dx,si
                mov     di,dx

                mov     player_name,dx

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

                mov     si,offset ascii_dcase

                test    ax,100h
                jz      ei_shiftia

                mov     si,offset ascii_ucase
ei_shiftia:
                xor     bx,bx
                mov     bl,al

                mov     al,[si+bx]

                test    al,al
                jz      wait_keyrrrr

                cmp     al,' '
                jnz     ei_space

                cmp     name_counter,0
                jz      wait_keyrrrr

ei_space:

                cmp     al,CR
                jz      retikka

                mov     si,player_name
                mov     bx,name_counter

                cmp     al,BS
                jnz     ei_BS

                test    bx,bx
                jz      ohi

                dec     bx
                mov     byte ptr [si+bx],0h
                jmp     ohi

ei_BS:

                cmp     bx,40
                jz      ohi

                pusha

                mov     si,player_name
                call    text_width

                cmp     dx,110

                popa

                ja      ohi

                mov     [si+bx],al
                inc     bx
                mov     byte ptr [si+bx],0h

ohi:
                mov     name_counter,bx

                mov     si,offset empty_buf2
                mov     ax,159
                mov     bx,108
                call    center_text

                mov     si,player_name
                mov     ax,159
                mov     bx,108
                call    center_text

                jmp     wait_keyrrrr

retikka:        call    write_highscores

ei_highscorea:  popa
                ret


                endp

cseg            ends

                end
