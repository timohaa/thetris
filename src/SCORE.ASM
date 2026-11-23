;----------------------------------------------------------------------------
; SCORE.ASM - Removing full lines, scoring, level changes, sound effects, the
;             score panel and number-to-text conversion.
;----------------------------------------------------------------------------

                include common.inc

cseg            segment
                assume  cs:cseg,ds:dseg

check_lines     proc    near

                mov     dx,seg dseg
                mov     ds,dx
                xor     ax,ax
                mov     ds:[lines_eliminated],ax

                mov     cx,320*8
                mov     ax,ds:[current_row]
                mul     cx

                mov     dx,0a000h
                mov     es,dx

                add     ax,eka_x
                mov     di,ax

                mov     cx,22
                sub     cx,ds:[current_row]
                cmp     cx,4
                jb      cl_looppi2
                mov     cx,4
cl_looppi2:     push    cx
                xor     bx,bx
                mov     cx,10
cl_looppi:      mov     ax,es:[di]
                test    ax,0ffh
                jz      nollaa
                inc     bx
nollaa:         add     di,9
                loop    cl_looppi
                cmp     bx,10
                jnz     ei_linjaa_pois

                inc     ds:[lines_eliminated]

                push    ds
                push    es
                push    di

                add     di,320*7-90
                mov     si,di
                sub     si,320*8
                mov     dx,0a000h
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

ei_linjaa_pois: add     di,320-90+320*7
                pop     cx
                loop    cl_looppi2

                mov     ax,ds:[lines_eliminated]
                test    ax,0ffh
                jz      pois
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
                jz      ohi_beep
                call    beep
ohi_beep:       pop     ds
                mov     ax,ds:[rows]
                xor     ah,ah
                mov     bl,10
                div     bl
                cmp     al,9
                jbe     level_ok
                mov     al,9
level_ok:
                cmp     ds:[level],al
                jae     suuremp_level
                mov     ds:[level],al
                mov     bl,3
                mul     bl
                mov     bl,4+9*3
                sub     bl,al
                mov     ds:[speed],bl
                dec     bl
                mov     ds:[timer],bl
                call    show_score
                test    ds:[curr_flags],soundflag
                jz      ohi_beep2
                call    beep2
ohi_beep2:
suuremp_level:

pois:           xor     al,al
                ret
cl_yepp:        mov     al,1h
                ret
beep:           push    ax
                push    cx
                push    dx
                mov     al,0b6h         ;10110110
                out     043h,al
                mov     al,0cch
                out     042h,al
                mov     al,00ch
                out     042h,al         ;???/2 Hz
                in      al,061h
                or      al,3h
                out     061h,al         ;speaker on
                call    beep_timer
                mov     al,066h
                out     042h,al
                mov     al,006h
                out     042h,al         ;??? Hz
                call    beep_timer
                in      al,061h
                and     al,0ffh-3h
                out     061h,al         ;speaker off
                pop     dx
                pop     cx
                pop     ax
                ret
beep2:          push    ax
                push    cx
                push    dx
                mov     al,0b6h         ;10110110
                out     043h,al
                mov     al,044h
                out     042h,al
                mov     al,004h
                out     042h,al         ;???/2 Hz
                in      al,061h
                or      al,3h
                out     061h,al         ;speaker on
                call    beep_timer2
                mov     al,088h
                out     042h,al
                mov     al,008h
                out     042h,al         ;??? Hz
                call    beep_timer2
                in      al,061h
                and     al,0ffh-3h
                out     061h,al         ;speaker off
                pop     dx
                pop     cx
                pop     ax
                ret
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
