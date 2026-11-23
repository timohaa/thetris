;----------------------------------------------------------------------------
; PIECE.ASM - Drawing, erasing and collision testing of blocks and pieces.
;----------------------------------------------------------------------------

                include common.inc

cseg            segment
                assume  cs:cseg,ds:dseg

put_block       proc    near

                push    dx
                push    ax

                mov     dx,seg palat
                mov     ds,dx
                mov     si,offset palat
                and     ax,7
                add     si,ax           ;ax=block number
                sal     ax,3
                add     si,ax

                mov     dx,0a000h
                mov     es,dx
                mov     di,bx           ;bx=x+y*320

                mov     cx,9
                rep     movsb
                add     si,63
                add     di,311
                mov     cx,9
                rep     movsb
                add     si,63
                add     di,311
                mov     cx,9
                rep     movsb
                add     si,63
                add     di,311
                mov     cx,9
                rep     movsb
                add     si,63
                add     di,311
                mov     cx,9
                rep     movsb
                add     si,63
                add     di,311
                mov     cx,9
                rep     movsb
                add     si,63
                add     di,311
                mov     cx,9
                rep     movsb
                add     si,63
                add     di,311
                mov     cx,9
                rep     movsb
                pop     ax
                pop     dx
                ret
                endp

;-----------------------------------------------------------------

clr_block       proc    near

                push    dx

                mov     dx,0a000h
                mov     es,dx
                mov     di,bx           ;bx=x+y*320
                xor     al,al
                mov     cx,9
                rep     stosb
                add     di,311
                mov     cx,9
                rep     stosb
                add     di,311
                mov     cx,9
                rep     stosb
                add     di,311
                mov     cx,9
                rep     stosb
                add     di,311
                mov     cx,9
                rep     stosb
                add     di,311
                mov     cx,9
                rep     stosb
                add     di,311
                mov     cx,9
                rep     stosb
                add     di,311
                mov     cx,9
                rep     stosb
                pop     dx
                ret
                endp

;-----------------------------------------------------------------------

; ax=row
; bx=column
; cx=piece shape (0 - 6)
; dx=angle (0-3)


put_piece       proc    near
                mov     bx,ds:[current_column]
                mov     ax,ds:[current_row]

                mov     cx,320*8
                mul     cx              ;ax=ax*320*8
                add     ax,eka_x
                add     ax,bx
                sal     bx,3
                add     bx,ax

                mov     cx,ds:[current_piece]
                mov     dx,ds:[current_angle]

put_put:        mov     ax,cx
                sal     cx,3                    ;piece number
                sal     dx,1                    ;angle

                add     cx,dx
                mov     si,cx
                mov     dx,seg dseg
                mov     ds,dx
                mov     dx,word ptr ds:paloja[si]

                mov     cx,4

pp_l:           push    cx
                test    dh,080h
                jz      pp_1
                call    put_block
pp_1:           add     bx,9
                test    dh,040h
                jz      pp_2
                call    put_block
pp_2:           add     bx,9
                test    dh,020h
                jz      pp_3
                call    put_block
pp_3:           add     bx,9
                test    dh,010h
                jz      pp_4
                call    put_block
pp_4:           add     bx,320-9*3+320*7
                sal     dx,4
                pop     cx
                loop    pp_l

                ret
                endp

;---------------------------------------------------------------------

clr_piece       proc    near

                mov     bx,ds:[current_column]
                mov     ax,ds:[current_row]

                mov     cx,320*8
                mul     cx              ;ax=ax*320*8
                add     ax,eka_x
                add     ax,bx
                sal     bx,3
                add     bx,ax

                mov     cx,ds:[current_piece]
                mov     dx,ds:[current_angle]

clr_clr:        mov     ax,cx
                sal     cx,3                    ;piece number
                sal     dx,1                    ;angle

                add     cx,dx
                mov     si,cx
                mov     dx,seg dseg
                mov     ds,dx
                mov     dx,word ptr ds:paloja[si]

                mov     cx,4

cp_l:           push    cx
                test    dh,080h
                jz      cp_1
                call    clr_block
cp_1:           add     bx,9
                test    dh,040h
                jz      cp_2
                call    clr_block
cp_2:           add     bx,9
                test    dh,020h
                jz      cp_3
                call    clr_block
cp_3:           add     bx,9
                test    dh,010h
                jz      cp_4
                call    clr_block
cp_4:           add     bx,320-9*3+320*7
                sal     dx,4
                pop     cx
                loop    cp_l
                ret
                endp

;------------------------------------------------------------------------

; ax=row
; bx=column
; cx=piece shape (0 - 6)
; dx=angle (0-3)

test_piece      proc    near

                mov     bx,ds:[current_column]
                mov     ax,ds:[current_row]

                mov     cx,320*8
                mul     cx              ;ax=ax*320*8
                add     ax,eka_x
                add     ax,bx
                sal     bx,3
                add     bx,ax

                mov     cx,ds:[current_piece]
                mov     dx,ds:[current_angle]

                mov     ax,cx
                sal     cx,3                    ;piece number
                sal     dx,1                    ;angle

                add     cx,dx
                mov     si,cx
                mov     dx,seg dseg
                mov     ds,dx
                mov     dx,word ptr ds:paloja[si]

                mov     cx,4

                mov     ax,0a000h
                mov     es,ax
                mov     di,bx

tp_l:           test    dh,080h
                jz      tp_1
                mov     bl,es:[di]
                test    bl,0ffh
                jnz     not_zero
tp_1:           add     di,9
                test    dh,040h
                jz      tp_2
                mov     bl,es:[di]
                test    bl,0ffh
                jnz     not_zero
tp_2:           add     di,9
                test    dh,020h
                jz      tp_3
                mov     bl,es:[di]
                test    bl,0ffh
                jnz     not_zero
tp_3:           add     di,9
                test    dh,010h
                jz      tp_4
                mov     bl,es:[di]
                test    bl,0ffh
                jnz     not_zero
tp_4:           add     di,320-9*3+320*7
                sal     dx,4
                loop    tp_l
                xor     al,al
                ret
not_zero:       mov     al,1
                ret

                endp

cseg            ends

                end
