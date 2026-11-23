;----------------------------------------------------------------------------
; SCREEN.ASM - Text output with the proportional font, and clearing the screen.
;----------------------------------------------------------------------------

                include common.inc

cseg            segment
                assume  cs:cseg,ds:dseg

center_text     proc    near
                push    si
                push    bx
                push    ax
                call    text_width
                pop     ax
                sar     dx,1
                sub     ax,dx
                pop     bx
                pop     si
                call    output_text
                ret
                endp

right_align_int proc    near
                mov     dx,dseg
                mov     ds,dx

                push    ax
                push    bx

                mov     ax,ds:[si]
                mov     byte ptr ds:[converter],'0'
                call    conv_int
                mov     si,di

                push    si
                call    text_width
                pop     si

                pop     bx
                pop     ax
                sub     ax,dx

                call    output_text
                ret
                endp

output_text     proc    near
                mov     dx,dseg
                mov     ds,dx
                mov     ds:[text_x],ax
                mov     ds:[text_y],bx
ot_loop:        lodsb
                test    al,0ffh
                jz      ot_pois
                call    output_char
                jmp     ot_loop
ot_pois:        ret
                endp

text_width      proc    near
                mov     dx,dseg
                mov     ds,dx
                xor     dx,dx
tw_loop:        lodsb
                test    al,0ffh
                jz      tw_pois
                call    char_width
                add     dx,ax
                jmp     tw_loop
tw_pois:        ret

char_width:     mov     cx,seg kirjapu
                mov     es,cx
                mov     di,offset kirjapu
                mov     cx,89
                repne   scasb
                mov     bx,88
                sub     bx,cx
                add     bx,bx
                mov     ax,es:[kirj_leveydet+BX]
                ret
                endp

output_char     proc    near
                push    ds
                push    si
                mov     dx,dseg
                mov     fs,dx
                mov     dx,seg kirjapu
                mov     es,dx
                mov     di,offset kirjapu
                mov     cx,89
                repne   scasb
                mov     bx,88
                sub     bx,cx
                add     bx,bx
                mov     cx,fs:[kirj_leveydet+BX]                ;ax = kirjaimen leveys
                mov     bx,fs:[kirj_offsetit+BX]                ;bx = offsetti kirjaimen alkuun
                mov     dx,0a000h
                mov     es,dx
                mov     dx,seg fontti
                mov     ds,dx
                mov     si,offset fontti
                add     si,bx
                mov     ax,fs:[text_y]
                mov     dx,320
                mul     dx
                add     ax,fs:[text_x]
                add     fs:[text_x],cx
                mov     di,ax
                mov     ax,320
                mov     bx,317
                sub     ax,cx
                sub     bx,cx
                mov     dx,cx
                rep     movsb
                add     si,bx
                add     di,ax
                mov     cx,dx
                rep     movsb
                add     si,bx
                add     di,ax
                mov     cx,dx
                rep     movsb
                add     si,bx
                add     di,ax
                mov     cx,dx
                rep     movsb
                add     si,bx
                add     di,ax
                mov     cx,dx
                rep     movsb
                add     si,bx
                add     di,ax
                mov     cx,dx
                rep     movsb
                add     si,bx
                add     di,ax
                mov     cx,dx
                rep     movsb
                add     si,bx
                add     di,ax
                mov     cx,dx
                rep     movsb
                add     si,bx
                add     di,ax
                mov     cx,dx
                rep     movsb
                add     si,bx
                add     di,ax
                mov     cx,dx
                rep     movsb
                add     si,bx
                add     di,ax
                mov     cx,dx
                rep     movsb
;                add     si,bx
;                add     di,ax
;                mov     cx,dx
;                rep     movsb
                pop     si
                pop     ds
                ret
                endp

;-----------------------------------------------------------------------------

clear_screen    proc    near
                mov     dx,0a000h
                mov     es,dx
                xor     di,di
                xor     eax,eax
                mov     cx,16000
                rep     stosd                   ;clear screen
                ret
                endp

cseg            ends

                end
