;----------------------------------------------------------------------------
; PIECE.ASM - Drawing, erasing and collision testing of blocks and pieces.
;----------------------------------------------------------------------------

                include common.inc

cseg            segment
                assume  cs:cseg,ds:dseg

; Draws one block of 9*8 pixels. ax=block number (0 - 7), bx=x+y*320.
; The blocks lie side by side in a picture 72 pixels wide.
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

                mov     dx,vga_seg
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

; Clears one block of 9*8 pixels to colour 0. bx=x+y*320.
clr_block       proc    near

                push    dx

                mov     dx,vga_seg
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

; Draws the current piece at current_row, current_column. The entry point
; put_put draws any piece: bx=x+y*320 of the piece, cx=piece shape (0 - 14),
; dx=angle (0-3).

put_piece       proc    near
                mov     bx,ds:[current_column]
                mov     ax,ds:[current_row]

                mov     cx,320*8
                mul     cx              ;ax=row*320*8
                add     ax,first_x
                add     ax,bx
                sal     bx,3
                add     bx,ax           ;bx=x+y*320 of the piece

                mov     cx,ds:[current_piece]
                mov     dx,ds:[current_angle]

put_put:        mov     ax,cx           ;the piece number picks the block
                sal     cx,3                    ;piece number
                sal     dx,1                    ;angle

                add     cx,dx
                mov     si,cx
                mov     dx,seg dseg
                mov     ds,dx
                mov     dx,word ptr ds:piece_shapes[si]

                mov     cx,4

; dx holds the shape as a 4*4 bit map, top row in the highest four bits.
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

; Erases the current piece at current_row, current_column. The entry point
; clr_clr erases any piece: bx=x+y*320 of the piece, cx=piece shape (0 - 14),
; dx=angle (0-3).

clr_piece       proc    near

                mov     bx,ds:[current_column]
                mov     ax,ds:[current_row]

                mov     cx,320*8
                mul     cx              ;ax=row*320*8
                add     ax,first_x
                add     ax,bx
                sal     bx,3
                add     bx,ax           ;bx=x+y*320 of the piece

                mov     cx,ds:[current_piece]
                mov     dx,ds:[current_angle]

clr_clr:        mov     ax,cx
                sal     cx,3                    ;piece number
                sal     dx,1                    ;angle

                add     cx,dx
                mov     si,cx
                mov     dx,seg dseg
                mov     ds,dx
                mov     dx,word ptr ds:piece_shapes[si]

                mov     cx,4

; dx holds the shape as a 4*4 bit map, top row in the highest four bits.
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

; Tests whether the current piece (current_piece, current_angle) at
; current_row, current_column overlaps non-zero pixels on the screen.
; Returns al=0 if free, al=1 if not.

test_piece      proc    near

                mov     bx,ds:[current_column]
                mov     ax,ds:[current_row]

                mov     cx,320*8
                mul     cx              ;ax=row*320*8
                add     ax,first_x
                add     ax,bx
                sal     bx,3
                add     bx,ax           ;bx=x+y*320 of the piece

                mov     cx,ds:[current_piece]
                mov     dx,ds:[current_angle]

                mov     ax,cx
                sal     cx,3                    ;piece number
                sal     dx,1                    ;angle

                add     cx,dx
                mov     si,cx
                mov     dx,seg dseg
                mov     ds,dx
                mov     dx,word ptr ds:piece_shapes[si]

                mov     cx,4

                mov     ax,vga_seg
                mov     es,ax
                mov     di,bx

; dx holds the shape as a 4*4 bit map, top row in the highest four bits.
; Only the top left pixel of each block is tested.
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
