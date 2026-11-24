;----------------------------------------------------------------------------
; SCREEN.ASM - Text output with the proportional font, and clearing the screen.
;----------------------------------------------------------------------------

                include common.inc

cseg            segment
                assume  cs:cseg,ds:dseg

; Draws a text centred on a point. si=text (ends in 0), ax=x of the centre,
; bx=y.
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

; Draws a number so that it ends at a point. si=address of the word to draw,
; ax=x of the right edge, bx=y.
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

; Draws a text. si=text (ends in 0), ax=x, bx=y.
output_text     proc    near
                mov     dx,dseg
                mov     ds,dx
                mov     ds:[text_x],ax
                mov     ds:[text_y],bx
ot_loop:        lodsb
                test    al,0ffh
                jz      ot_done
                call    output_char
                jmp     ot_loop
ot_done:        ret
                endp

; Measures a text. si=text (ends in 0). Returns dx=width in pixels.
text_width      proc    near
                mov     dx,dseg
                mov     ds,dx
                xor     dx,dx
tw_loop:        lodsb
                test    al,0ffh
                jz      tw_done
                call    char_width
                add     dx,ax
                jmp     tw_loop
tw_done:        ret

; al=character. Returns ax=its width in pixels.
char_width:     mov     cx,seg font_chars
                mov     es,cx
                mov     di,offset font_chars
                mov     cx,89
                repne   scasb
                mov     bx,88
                sub     bx,cx
                add     bx,bx
                mov     ax,es:[font_widths+BX]
                ret
                endp

; Draws one character at text_x, text_y and moves text_x past it.
; al=character. The font picture is 317 pixels wide and holds three rows of
; letters, each 11 pixels high.
output_char     proc    near
                push    ds
                push    si
                mov     dx,dseg
                mov     fs,dx
                mov     dx,seg font_chars
                mov     es,dx
                mov     di,offset font_chars
                mov     cx,89
                repne   scasb
                mov     bx,88
                sub     bx,cx
                add     bx,bx
                mov     cx,fs:[font_widths+BX]  ;cx=width of the letter
                mov     bx,fs:[font_offsets+BX]  ;bx=its offset in the font
                mov     dx,vga_seg
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
; ax and bx step di and si from the end of one pixel row to the start of
; the next.
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
                pop     si
                pop     ds
                ret
                endp

;-----------------------------------------------------------------------------

clear_screen    proc    near
                mov     dx,vga_seg
                mov     es,dx
                xor     di,di
                xor     eax,eax
                mov     cx,16000
                rep     stosd                   ;clear screen
                ret
                endp

cseg            ends

                end
