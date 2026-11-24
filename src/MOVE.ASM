;----------------------------------------------------------------------------
; MOVE.ASM - Dropping, moving and rotating the current piece.
;----------------------------------------------------------------------------

                include common.inc

cseg            segment
                assume  cs:cseg,ds:dseg

; Moves the current piece one row down. Returns al=0 if it moved, al=1 if
; it landed.
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

; Drops the current piece straight down until it lands.
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

; Moves the current piece one column right if there is room.
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

; Moves the current piece one column left if there is room.
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

; Turns the current piece counter-clockwise, to the next angle, if there is
; room.
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

; Turns the current piece clockwise, to the previous angle, if there is room.
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
