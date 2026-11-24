;----------------------------------------------------------------------------
; PALETTE.ASM - Palette fades and waiting for the vertical retrace.
;----------------------------------------------------------------------------

                include common.inc

cseg            segment
                assume  cs:cseg,ds:dseg

; Sets every colour to black.
clear_palette   proc    near
                push    ds
                xor     bl,bl
                call    set_pal
                pop     ds
                ret
                endp

; Fades the screen to black over 32 frames when fading is on. With fading
; off the screen stays as it is and only keycode is cleared.
fade_out        proc    near
                pusha
                mov     dx,dseg
                mov     ds,dx
                test    ds:[flags],fadeflag
                jz      no_fade
                mov     bl,32
fo_loop:        call    waitblank
                call    set_pal
                dec     bl
                test    bl,bl
                jnz     fo_loop
                popa
                ret
no_fade:        mov     ds:[keycode],0
                popa
                ret
                endp

; Fades the screen in from black over 32 frames. With fading off the full
; palette is set at once.
fade_in         proc    near
                pusha
                mov     dx,dseg
                mov     ds,dx
                test    ds:[flags],fadeflag
                jnz     do_fade
                mov     bl,31
                jmp     fi_loop
do_fade:        xor     bl,bl
fi_loop:        inc     bl
                call    waitblank
                call    set_pal
                cmp     bl,32
                jnz     fi_loop
                popa
                ret
                endp

; Sets the whole palette at one brightness. bl=brightness, 0 (black) - 32
; (full).
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

; Waits until a vertical retrace has started and ended.
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
