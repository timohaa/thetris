;----------------------------------------------------------------------------
; PALETTE.ASM - Palette fades and waiting for the vertical retrace.
;----------------------------------------------------------------------------

                include common.inc

cseg            segment
                assume  cs:cseg,ds:dseg

clear_palette   proc    near
                push    ds
                xor     bl,bl
                call    set_pal
                pop     ds
                ret
                endp

fade_out        proc    near
                pusha
                mov     dx,dseg
                mov     ds,dx
                test    ds:[flags],fadeflag
                jz      ei_fadea
                mov     bl,32
fo_loop:        call    waitblank
                call    set_pal
                dec     bl
                test    bl,bl
                jnz     fo_loop
                popa
                ret
ei_fadea:       mov     ds:[keycode],0
                popa
                ret
                endp

fade_in         proc    near
                pusha
                mov     dx,dseg
                mov     ds,dx
                test    ds:[flags],fadeflag
                jnz     fadetus
                mov     bl,31
                jmp     fi_loop
fadetus:        xor     bl,bl
fi_loop:        inc     bl
                call    waitblank
                call    set_pal
                cmp     bl,32
                jnz     fi_loop
                popa
                ret
                endp

set_pal         proc    near
                mov     dx,seg palette
                mov     ds,dx
                mov     si,offset palette
                mov     dx,3c8h
                xor     al,al
                out     dx,al
                inc     dx
                mov     cx,3*256
sp_lop:         lodsb
                mul     bl
                shr     ax,5
                out     dx,al
                loop    sp_lop
                ret
                endp

waitblank       proc    near
                mov     dx,3dah
w_bl:           in      al,dx
                test    al,8
                jz      w_bl
w_bl2:          in      al,dx
                test    al,8
                jnz     w_bl2
                ret
                endp

cseg            ends

                end
