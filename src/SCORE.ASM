;----------------------------------------------------------------------------
; SCORE.ASM - Removing full lines, scoring, level changes, sound effects, the
;             score panel and number-to-text conversion.
;----------------------------------------------------------------------------

                include common.inc

cseg            segment
                assume  cs:cseg,ds:dseg

; Removes the full lines among the four rows the landed piece covers, adds
; the score, raises the level and plays the sounds. Always returns al=0.
check_lines     proc    near

                mov     dx,seg dseg
                mov     ds,dx
                xor     ax,ax
                mov     ds:[lines_eliminated],ax

                mov     cx,320*8
                mov     ax,ds:[current_row]
                mul     cx

                mov     dx,vga_seg
                mov     es,dx

                add     ax,first_x
                mov     di,ax           ;di=left end of current_row

; Check four rows, fewer when the piece is near the bottom.
                mov     cx,22
                sub     cx,ds:[current_row]
                cmp     cx,4
                jb      cl_row_loop
                mov     cx,4
cl_row_loop:    push    cx
; Count the blocks on the row; ten means the row is full.
                xor     bx,bx
                mov     cx,10
cl_col_loop:    mov     ax,es:[di]
                test    ax,0ffh
                jz      cl_empty
                inc     bx
cl_empty:       add     di,9
                loop    cl_col_loop
                cmp     bx,10
                jnz     cl_not_full

                inc     ds:[lines_eliminated]

; Move everything above the full row down by one row of blocks.
                push    ds
                push    es
                push    di

                add     di,320*7-90
                mov     si,di
                sub     si,320*8
                mov     dx,vga_seg
                mov     ds,dx
                mov     es,dx

                xor     dx,dx
                mov     bx,320
                mov     ax,si
                div     bx
                mov     cx,ax
clclclcl:       push    cx
                mov     cx,90
                rep     movsb
                pop     cx
                sub     di,410
                sub     si,410
                loop    clclclcl

                pop     di
                pop     es
                pop     ds

cl_not_full:    add     di,320-90+320*7
                pop     cx
                loop    cl_row_loop

; Score: lines*lines*3*(level+1).
                mov     ax,ds:[lines_eliminated]
                test    ax,0ffh
                jz      cl_done
                add     ds:[rows],ax
                mov     bx,ax
                mul     bl
                mov     bl,3
                mul     bl
                mov     bl,ds:[level]
                inc     bl
                mul     bl
                add     ds:[score],ax
                push    ds
                call    show_score
                test    ds:[curr_flags],soundflag
                jz      skip_beep
                call    beep
skip_beep:      pop     ds
; The level is the line count/10, 9 at most. A game started on a higher
; level keeps it.
                mov     ax,ds:[rows]
                xor     ah,ah
                mov     bl,10
                div     bl
                cmp     al,9
                jbe     level_ok
                mov     al,9
level_ok:
                cmp     ds:[level],al
                jae     level_higher
                mov     ds:[level],al
; speed = 31-3*level frames between drops
                mov     bl,3
                mul     bl
                mov     bl,4+9*3
                sub     bl,al
                mov     ds:[speed],bl
                dec     bl
                mov     ds:[timer],bl
                call    show_score
                test    ds:[curr_flags],soundflag
                jz      skip_beep2
                call    beep2
skip_beep2:
level_higher:

cl_done:        xor     al,al
                ret
cl_yepp:        mov     al,1h
                ret

; Sound of a removed line: two tones on the PC speaker, one frame each.
beep:           push    ax
                push    cx
                push    dx
                mov     al,0b6h         ;timer 2, square wave
                out     043h,al
                mov     al,0cch
                out     042h,al
                mov     al,00ch
                out     042h,al         ;divisor 0ccch = 364 Hz
                in      al,061h
                or      al,3h
                out     061h,al         ;speaker on
                call    beep_timer
                mov     al,066h
                out     042h,al
                mov     al,006h
                out     042h,al         ;divisor 0666h = 728 Hz
                call    beep_timer
                in      al,061h
                and     al,0ffh-3h
                out     061h,al         ;speaker off
                pop     dx
                pop     cx
                pop     ax
                ret

; Sound of a new level: two tones, three frames each.
beep2:          push    ax
                push    cx
                push    dx
                mov     al,0b6h         ;timer 2, square wave
                out     043h,al
                mov     al,044h
                out     042h,al
                mov     al,004h
                out     042h,al         ;divisor 0444h = 1093 Hz
                in      al,061h
                or      al,3h
                out     061h,al         ;speaker on
                call    beep_timer2
                mov     al,088h
                out     042h,al
                mov     al,008h
                out     042h,al         ;divisor 0888h = 546 Hz
                call    beep_timer2
                in      al,061h
                and     al,0ffh-3h
                out     061h,al         ;speaker off
                pop     dx
                pop     cx
                pop     ax
                ret

; beep_timer waits one frame, beep_timer2 three.
beep_timer2:    mov     cx,3
                jmp     bapp
beep_timer:     mov     cx,1
bapp:           mov     dx,3DAh
beep_l:         in      al,dx
                test    al,8
                jz      beep_l
beep_l_2:       in      al,dx
                test    al,8
                jnz     beep_l_2
                loop    beep_l
                ret

; Draws the score, the line count and the level in the panel. The panel
; digits are the font characters 230 - 239, so converter is set to 230.
show_score:     mov     dx,dseg
                mov     ds,dx
                mov     si,offset empty_buf
                mov     ax,263
                mov     bx,28
                call    center_text
                mov     si,offset empty_buf
                mov     ax,263
                mov     bx,72
                call    center_text
                mov     si,offset empty_buf
                mov     ax,263
                mov     bx,116
                call    center_text
                mov     ax,ds:[rows]
                mov     byte ptr ds:[converter],230
                call    conv_int
                mov     si,di
                mov     ax,263
                mov     bx,72
                call    center_text
                mov     ax,ds:[score]
                call    conv_int
                mov     si,di
                mov     ax,263
                mov     bx,28
                call    center_text
                xor     ah,ah
                mov     al,ds:[level]
                call    conv_int
                mov     si,di
                mov     ax,263
                mov     bx,116
                call    center_text
                ret
                endp

; Converts a number to text. ax=number, converter=character code of the
; digit zero. Returns di=start of the text in int_conv_buf, without leading
; zeros.
conv_int        proc    near
                lea     di,int_conv_buf+5
                mov     bx,10
                mov     cx,6
                mov     dx,0
si_l:           div     bx
                add     dl,byte ptr ds:[converter]
                mov     byte ptr ds:[di],dl
                mov     dx,0
                dec     di
                loop    si_l
                mov     al,byte ptr ds:[converter]
si_l2:          inc     di
                cmp     byte ptr ds:[di],al
                jnz     si_ok
                cmp     di,offset int_conv_buf+5
                jb      si_l2
si_ok:          ret
                endp

cseg            ends

                end
