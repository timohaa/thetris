;----------------------------------------------------------------------------
; FILES.ASM - Reading and writing the high score and setup files.
;----------------------------------------------------------------------------

                include common.inc

cseg            segment
                assume  cs:cseg,ds:dseg

read_highscores proc    near
                call    hscrypt

                mov     ax,3d00h
                mov     dx,seg highscore_filename
                mov     ds,dx
                mov     dx,offset highscore_filename
                int     21h
                jc      rb_ohi

                mov     dx,seg dseg
                mov     ds,dx
                mov     ds:[data_handle],ax
                mov     bx,ax
                mov     cx,43*22
                mov     dx,seg hstab_a
                mov     ds,dx
                mov     dx,offset hstab_a
                mov     ah,3fh
                int     21h

                mov     bx,ds:[data_handle]
                mov     ah,3eh
                int     21h
rb_ohi:
                call    hscrypt
                ret
                endp

write_highscores proc    near
                call    hscrypt
                mov     ax,3c00h
                mov     dx,seg highscore_filename
                mov     ds,dx
                mov     dx,offset highscore_filename
                int     21h
                jc      wb_ohi

                mov     dx,seg dseg
                mov     ds,dx
                mov     ds:[data_handle],ax
                mov     bx,ax
                mov     cx,43*22
                mov     dx,seg hstab_a
                mov     ds,dx
                mov     dx,offset hstab_a
                mov     ah,40h
                int     21h

                mov     bx,ds:[data_handle]
                mov     ah,3eh
                int     21h
wb_ohi:
                call    hscrypt
                ret
                endp

hscrypt         proc    near

                pusha

                mov     dx,seg hstab_a
                mov     es,dx
                mov     di,offset hstab_a

                mov     cx,22*43
hscrypt_loop:   xor     es:[di],cl
                inc     di
                loop    hscrypt_loop

                popa

                ret
                endp

read_setup      proc    near
                mov     ax,3d00h
                mov     dx,seg setup_filename
                mov     ds,dx
                mov     dx,offset setup_filename
                int     21h
                jc      rbs_ohi

                mov     dx,seg dseg
                mov     ds,dx
                mov     ds:[data_handle],ax
                mov     bx,ax
                mov     cx,17
                mov     dx,seg flags
                mov     ds,dx
                mov     dx,offset flags
                mov     ah,3fh
                int     21h

                mov     bx,ds:[data_handle]
                mov     ah,3eh
                int     21h
rbs_ohi:
                ret
                endp

write_setup     proc    near
                mov     ax,3c00h
                mov     dx,seg setup_filename
                mov     ds,dx
                mov     dx,offset setup_filename
                int     21h
                jc      wbs_ohi

                mov     dx,seg dseg
                mov     ds,dx
                mov     ds:[data_handle],ax
                mov     bx,ax
                mov     cx,17
                mov     dx,seg flags
                mov     ds,dx
                mov     dx,offset flags
                mov     ah,40h
                int     21h

                mov     bx,ds:[data_handle]
                mov     ah,3eh
                int     21h

wbs_ohi:
                ret
                endp

cseg            ends

                end
