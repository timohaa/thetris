;----------------------------------------------------------------------------
; NEXT.ASM - Random numbers, picking the next piece and the next piece preview.
;----------------------------------------------------------------------------

                include common.inc

cseg            segment
                assume  cs:cseg,ds:dseg

; bl=range. Returns ax=random number, 0 - bl-1.
rand            proc    near
                mov     dx,seg dseg
                mov     ds,dx
                mov     ax,ds:[random_seed]
                add     ax,55555
                xor     ax,0eeeeh

                mov     ds:[random_seed],ax
                xor     ah,ah
                div     bl
                shr     ax,8
                ret
                endp

; Makes the next piece the current one and picks a new next piece and angle.
; A pick equal to the current piece is redone once, so repeats are rarer.
pick_next_piece proc    near

                call    clr_next

                mov     ax,ds:[next_piece]
                mov     ds:[current_piece],ax
                mov     ax,ds:[next_angle]
                mov     ds:[current_angle],ax
                mov     bl,ds:[number_of_pieces]
                call    rand
                cmp     ds:[current_piece],ax
                jnz     np_ok
                mov     bl,ds:[number_of_pieces]
                call    rand
np_ok:          mov     ds:[next_piece],ax
                mov     bl,4
                call    rand
                mov     ds:[next_angle],ax

                call    draw_next
                ret
                endp

; Draws the next piece preview when the preview is on.
draw_next       proc    near
                test    ds:[curr_flags],nextflag
                jz      dn_skip
                push    ds
                mov     cx,ds:[next_piece]
                mov     dx,ds:[next_angle]
                mov     bx,cx
                sal     bx,3
                add     bx,dx
                add     bx,dx
                mov     bx,ds:[preview_coords+BX]
                call    put_put
                pop     ds
dn_skip:        ret
                endp

; Erases the next piece preview.
clr_next        proc    near
                push    ds
                mov     cx,ds:[next_piece]
                mov     dx,ds:[next_angle]
                mov     bx,cx
                sal     bx,3
                add     bx,dx
                add     bx,dx
                mov     bx,ds:[preview_coords+BX]
                call    clr_clr
                pop     ds
                ret
                endp

cseg            ends

                end
