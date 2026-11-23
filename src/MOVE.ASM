;----------------------------------------------------------------------------
; MOVE.ASM - Dropping, moving and rotating the current piece.
;----------------------------------------------------------------------------

                include common.inc

cseg            segment
                assume  cs:cseg,ds:dseg

drop            proc    near
                mov     dx,seg dseg
                mov     ds,dx
                call    clr_piece
                mov     dx,seg dseg
                mov     ds,dx
                inc     ds:[current_row]
                call    test_piece
                test    al,0ffh
                jz      draw_new_one
                dec     ds:[current_row]
                mov     dx,seg dseg
                mov     ds,dx
                call    put_piece
                mov     al,1
                ret
draw_new_one:   mov     dx,seg dseg
                mov     ds,dx
                call    put_piece
                xor     al,al
                ret
                endp

drop_at_once    proc    near
                mov     dx,seg dseg
                mov     ds,dx
                call    clr_piece
                mov     dx,seg dseg
                mov     ds,dx
dao_loop:       inc     ds:[current_row]
                call    test_piece
                test    al,0ffh
                jz      dao_loop
                dec     ds:[current_row]
                mov     dx,seg dseg
                mov     ds,dx
                call    put_piece
                ret
                endp

move_right      proc    near
                mov     dx,seg dseg
                mov     ds,dx
                call    clr_piece
                mov     dx,seg dseg
                mov     ds,dx
                inc     ds:[current_column]
                call    test_piece
                test    al,0ffh
                jz      dno
                dec     ds:[current_column]
dno:            mov     dx,seg dseg
                mov     ds,dx
                call    put_piece
                ret
                endp

move_left       proc    near
                mov     dx,seg dseg
                mov     ds,dx
                call    clr_piece
                mov     dx,seg dseg
                mov     ds,dx
                dec     ds:[current_column]
                call    test_piece
                test    al,0ffh
                jz      dno2
                inc     ds:[current_column]
dno2:           mov     dx,seg dseg
                mov     ds,dx
                call    put_piece
                ret
                endp

rotate          proc    near
                mov     dx,seg dseg
                mov     ds,dx
                call    clr_piece
                mov     dx,seg dseg
                mov     ds,dx
                inc     ds:[current_angle]
                and     ds:[current_angle],3
                call    test_piece
                test    al,0ffh
                jz      dno3
                dec     ds:[current_angle]
                and     ds:[current_angle],3
dno3:           mov     dx,seg dseg
                mov     ds,dx
                call    put_piece
                ret
                endp

rotate2         proc    near
                mov     dx,seg dseg
                mov     ds,dx
                call    clr_piece
                mov     dx,seg dseg
                mov     ds,dx
                dec     ds:[current_angle]
                and     ds:[current_angle],3
                call    test_piece
                test    al,0ffh
                jz      dno32
                inc     ds:[current_angle]
                and     ds:[current_angle],3
dno32:          mov     dx,seg dseg
                mov     ds,dx
                call    put_piece
                ret
                endp

cseg            ends

                end
