;----------------------------------------------------------------------------
; MENU.ASM - Game menu, information screen, setup, key redefinition, high score
;            screen and the starting level prompt.
;----------------------------------------------------------------------------

                include common.inc

cseg            segment
                assume  cs:cseg,ds:dseg

; The game menu. Returns when Esc is pressed.
game_menu       proc    near

menu_again:
                call    clear_screen
                mov     dx,seg logo
                mov     ds,dx
                mov     si,offset logo
                mov     edi,320*20
                mov     cx,60*80
                rep     movsd

                mov     dx,dseg
                mov     fs,dx

                mov     si,offset text_1
                mov     ax,159
                mov     bx,90
                call    center_text
                mov     si,offset text_2
                mov     ax,159
                mov     bx,101
                call    center_text
                mov     si,offset text_3
                mov     ax,159
                mov     bx,112
                call    center_text

                mov     si,offset text_6
                mov     ax,159
                mov     bx,123
                call    center_text

                mov     si,offset text_info
                mov     ax,159
                mov     bx,134
                call    center_text

                mov     si,offset text_4
                mov     ax,159
                mov     bx,145
                call    center_text

                call    fade_in

wait_keyb:      mov     ax,fs:[keycode]
                test    al,0ffh
                jz      wait_keyb

                mov     word ptr ds:[keycode],0h

                cmp     al,1eh          ;A
                jnz     not_a
                mov     fs:[number_of_pieces],7
                call    fade_out
                call    game
                jmp     menu_again
not_a:
                cmp     al,30h          ;B
                jnz     not_b
                mov     fs:[number_of_pieces],15
                call    fade_out
                call    game
                jmp     menu_again

not_b:          cmp     al,23h          ;H
                jnz     not_h

                call    fade_out
                call    show_highscores
                jmp     menu_again

not_h:          cmp     al,17h          ;I
                jnz     not_i
                call    fade_out
                call    show_info
                jmp     menu_again
not_i:          cmp     al,1fh          ;S
                jnz     not_s
                call    fade_out
                call    game_setup
                jmp     menu_again

not_s:
                cmp     al,1h           ;Esc
                jnz     wait_keyb
                call    fade_out
                ret


; The information screen: the texts listed in info_texts, centred, 11
; pixels apart.

show_info:
                call    clear_screen
                mov     dx,seg info_texts
                mov     ds,dx
                mov     es,dx
                mov     di,offset info_texts

                mov     bx,20
sin_loop:       mov     si,es:[di]
                add     di,2
                cmp     si,0h
                jz      sin_done
                push    bx
                push    es
                push    di
                mov     ax,159
                call    center_text
                pop     di
                pop     es
                pop     bx
                add     bx,11
                jmp     sin_loop

sin_done:
                call    fade_in
                mov     dx,seg dseg
                mov     ds,dx

                mov     ds:[keycode],0
wait_keybsh:    mov     ax,ds:[keycode]
                test    al,0ffh
                jz      wait_keybsh
                mov     ds:[keycode],0
                call    fade_out
                ret

;-----------------------------------------------------------------------

; The setup screen. Esc saves the settings and returns.

game_setup:
                call    clear_screen
                mov     dx,dseg
                mov     ds,dx
                mov     fs,dx
                call    setup_screen
                call    fade_in

setup_again:    call    setup_screen
wait_keybs:     mov     ax,ds:[keycode]
                test    al,0ffh
                jz      wait_keybs
                mov     ds:[keycode],0

                cmp     al,13h          ;R
                jnz     setup_not_r
                call    redefine_keys
                jmp     game_setup
setup_not_r:
                cmp     al,1fh          ;S
                jnz     setup_not_s
                xor     ds:[flags],soundflag
                jmp     setup_again
setup_not_s:
                cmp     al,21h          ;F
                jnz     setup_not_f
                xor     ds:[flags],fadeflag
                jmp     setup_again
setup_not_f:
                cmp     al,31h          ;N
                jnz     setup_not_n
                xor     ds:[flags],nextflag
                jmp     setup_again
setup_not_n:
                cmp     al,1h           ;Esc
                jnz     wait_keybs

                call    fade_out
                call    write_setup
                ret

; Draws the setup menu with the current state of each setting.

setup_screen:   mov     si,offset setup_menu
                mov     ax,159
                mov     bx,50
                call    center_text
                mov     si,offset setup_1
                mov     ax,159
                mov     bx,77
                call    center_text
                mov     si,offset setup_2off
                test    ds:[flags],fadeflag
                jz      ff_off
                mov     si,offset setup_2on
ff_off:
                mov     ax,159
                mov     bx,88
                call    center_text

                mov     si,offset setup_3off
                test    ds:[flags],soundflag
                jz      sf_off
                mov     si,offset setup_3on
sf_off:
                mov     ax,159
                mov     bx,99
                call    center_text

                mov     si,offset setup_4off
                test    ds:[flags],nextflag
                jz      nf_off
                mov     si,offset setup_4on
nf_off:
                mov     ax,159
                mov     bx,110
                call    center_text

                mov     si,offset setup_5
                mov     ax,159
                mov     bx,121
                call    center_text
                ret

; Asks for the eight game keys in turn. The keys are cleared first, so that
; get_key can refuse a key that is already taken.

redefine_keys:
                call    fade_out
                call    clear_screen
                mov     si,offset redefine_text
                mov     ax,159
                mov     bx,10
                call    center_text

                mov     si,offset left_key
                mov     ax,0
                mov     ds:[si],ax
                mov     ds:2[si],ax
                mov     ds:4[si],ax
                mov     ds:6[si],ax
                mov     ds:8[si],ax
                mov     ds:10[si],ax
                mov     ds:12[si],ax
                mov     ds:14[si],ax

                mov     si,offset left_key_text
                mov     ax,10
                mov     bx,30
                call    output_text
                call    fade_in
                call    get_key
                mov     left_key,ax

                mov     si,offset right_key_text
                mov     ax,10
                mov     bx,42
                call    output_text
                call    get_key
                mov     right_key,ax

                mov     si,offset rcw_key_text
                mov     ax,10
                mov     bx,54
                call    output_text
                call    get_key
                mov     cw_rotate,ax

                mov     si,offset rccw_key_text
                mov     ax,10
                mov     bx,66
                call    output_text
                call    get_key
                mov     ccw_rotate,ax

                mov     si,offset drop_key_text
                mov     ax,10
                mov     bx,78
                call    output_text
                call    get_key
                mov     drop_key,ax

                mov     si,offset sound_key_text
                mov     ax,10
                mov     bx,90
                call    output_text
                call    get_key
                mov     sound_key,ax

                mov     si,offset next_key_text
                mov     ax,10
                mov     bx,102
                call    output_text
                call    get_key
                mov     next_key,ax

                mov     si,offset pause_key_text
                mov     ax,10
                mov     bx,114
                call    output_text
                call    get_key
                mov     pause_key,ax

                call    fade_out
                ret

; Waits for a key that is not taken yet and draws its name after the
; prompt. Returns ax=key code. Left shift is not accepted.

get_key:
wait_keybsr:    mov     ax,ds:[keycode]
                test    al,0ffh
                jz      wait_keybsr
                mov     ds:[keycode],0

                cmp     al,02ah
                jz      get_key

                mov     si,offset left_key
                cmp     [si],ax
                jz      get_key
                cmp     2[si],ax
                jz      get_key
                cmp     4[si],ax
                jz      get_key
                cmp     6[si],ax
                jz      get_key
                cmp     8[si],ax
                jz      get_key
                cmp     10[si],ax
                jz      get_key
                cmp     12[si],ax
                jz      get_key
                cmp     14[si],ax
                jz      get_key

                push    ax

                mov     si,offset key_names
                mov     bx,ax
                and     bx,0ffh
                shl     bx,1
                mov     si,ds:[si+bx]
                mov     bx,text_y
                mov     ax,text_x
                call    output_text

                pop     ax

                ret

;-----------------------------------------------------------------------

; The high score screen: game A on the left, game B on the right.

show_highscores:
                call    clear_screen

                mov     dx,seg high_tausta
                mov     ds,dx
                mov     si,offset high_tausta
                mov     dx,vga_seg
                mov     es,dx
                mov     di,high_bg_y*320

                mov     cx,320*188
                rep     movsb

                mov     dx,dseg
                mov     ds,dx

                mov     cx,10
                mov     si,offset hstab_a
                mov     bx,high_a_y
hs_loop:        push    si
                push    bx
                push    cx
                push    bx
                push    si
                mov     ax,high_a_x
                call    output_text
                pop     si
                pop     bx
                add     si,41
                mov     ax,high_a_xr
                call    right_align_int
                pop     cx
                pop     bx
                pop     si
                add     bx,11
                add     si,43
                loop    hs_loop

                mov     cx,10
                mov     si,offset hstab_b
                mov     bx,high_b_y
hs_loop2:       push    si
                push    bx
                push    cx
                push    bx
                push    si
                mov     ax,high_b_x
                call    output_text
                pop     si
                pop     bx
                add     si,41
                mov     ax,high_b_xr
                call    right_align_int
                pop     cx
                pop     bx
                pop     si
                add     bx,11
                add     si,43
                loop    hs_loop2

                call    fade_in

                mov     dx,seg dseg
                mov     ds,dx

                mov     ds:[keycode],0
wait_keybh2:    mov     ax,ds:[keycode]
                test    al,0ffh
                jz      wait_keybh2
                mov     ds:[keycode],0
                call    fade_out
                ret


; Asks for the starting level. Returns al=0 with level set, or al=1 if Esc
; was pressed.

ask_level:      call    clear_screen
                mov     si,offset level_text
                mov     ax,159
                mov     bx,94
                call    center_text

                call    fade_in

wait_keyc:      mov     ax,fs:[keycode]
                test    al,0ffh
                jz      wait_keyc
                mov     word ptr ds:[keycode],0h

                cmp     al,1h           ;Esc
                jz      esc_hit
                cmp     al,0bh          ;the 0 key
                ja      wait_keyc
                jnz     level_not_0
                call    fade_out
                xor     al,al
                mov     ds:[level],al
                ret
level_not_0:    dec     al              ;keys 1 - 9 have scan codes 2 - 10
                mov     ds:[level],al
                xor     al,al
esc_hit:
                call    fade_out
                ret
                endp

cseg            ends

                end
