;----------------------------------------------------------------------------
; FILES.ASM - Reading and writing the high score and setup files.
;----------------------------------------------------------------------------

                include common.inc

cseg            segment
                assume  cs:cseg,ds:dseg

; Reads both high score tables from the file. The tables are encrypted in
; the file; a missing file leaves the tables in memory as they are.
read_highscores proc    near
                call    hscrypt

                mov     ax,3d00h
                mov     dx,seg highscore_filename
                mov     ds,dx
                mov     dx,offset highscore_filename
                int     21h
                jc      rb_skip

                mov     dx,seg dseg
                mov     ds,dx
                mov     ds:[data_handle],ax
                mov     bx,ax
                mov     cx,43*22        ;two tables of 11 entries, 43 bytes each
                mov     dx,seg hstab_a
                mov     ds,dx
                mov     dx,offset hstab_a
                mov     ah,3fh
                int     21h

                mov     bx,ds:[data_handle]
                mov     ah,3eh
                int     21h
rb_skip:
                call    hscrypt
                ret
                endp

; Encrypts the high score tables, writes them to the file and decrypts them
; again.
write_highscores proc    near
                call    hscrypt
                mov     ax,3c00h
                mov     dx,seg highscore_filename
                mov     ds,dx
                mov     dx,offset highscore_filename
                int     21h
                jc      wb_skip

                mov     dx,seg dseg
                mov     ds,dx
                mov     ds:[data_handle],ax
                mov     bx,ax
                mov     cx,43*22        ;two tables of 11 entries, 43 bytes each
                mov     dx,seg hstab_a
                mov     ds,dx
                mov     dx,offset hstab_a
                mov     ah,40h
                int     21h

                mov     bx,ds:[data_handle]
                mov     ah,3eh
                int     21h
wb_skip:
                call    hscrypt
                ret
                endp

; Encrypts or decrypts both high score tables by xoring each byte with a
; down counter. Running it twice restores the tables.
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

; Reads the settings from the setup file: flags and the eight keys, 17
; bytes. A missing file leaves the defaults.
read_setup      proc    near
                mov     ax,3d00h
                mov     dx,seg setup_filename
                mov     ds,dx
                mov     dx,offset setup_filename
                int     21h
                jc      rbs_skip

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
rbs_skip:
                ret
                endp

; Writes the settings to the setup file.
write_setup     proc    near
                mov     ax,3c00h
                mov     dx,seg setup_filename
                mov     ds,dx
                mov     dx,offset setup_filename
                int     21h
                jc      wbs_skip

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

wbs_skip:
                ret
                endp

cseg            ends

                end
