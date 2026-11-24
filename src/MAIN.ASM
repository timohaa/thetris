;----------------------------------------------------------------------------
; MAIN.ASM - Program entry point: initialisation, the call to the game menu,
;            clean-up and exit to DOS.
;----------------------------------------------------------------------------

                dosseg
                model   compact
                .stack  1024

                include common.inc

cseg            segment
                assume  cs:cseg,ds:dseg

start:
                mov     dx,dseg
                mov     ds,dx
; Seed the random numbers from the BIOS timer tick count at 40:6ch.
                mov     dx,040h
                mov     es,dx
                mov     ax,word ptr es:[6ch]
                add     ax,word ptr es:[6eh]
                add     ah,byte ptr es:[67h]
                add     ds:[random_seed],ax

                call    read_highscores
                call    read_setup

                call    set_kbhandler

                xor     esi,esi
                xor     edi,edi
                cld

                mov     dx,dseg
                mov     ds,dx

; Save the video mode and switch to mode 13h (320*200, 256 colours).
                mov     ah,0fh
                int     10h
                mov     ds:[old_video_mode],al

                mov     ax,0013h
                int     10h

                call    clear_palette

                call    game_menu

; Restore the video mode and the keyboard interrupt, then exit to DOS.
                mov     dx,dseg
                mov     ds,dx
                xor     ah,ah
                mov     al,ds:[old_video_mode]
                int     10h

                call    remove_kbhandler
exit:
                mov     ax,4c00h
                int     21h

cseg            ends

                end     start
