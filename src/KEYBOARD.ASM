;----------------------------------------------------------------------------
; KEYBOARD.ASM - Keyboard interrupt handler, and installing and removing it.
;----------------------------------------------------------------------------

                include common.inc

cseg            segment
                assume  cs:cseg,ds:dseg

; Saves the old keyboard interrupt vector (int 9) and installs new_kb_int.
set_kbhandler   proc    near

                mov     ax,3509h
                int     21h

                mov     dx,seg dseg
                mov     ds,dx
                mov     word ptr ds:[old_kb_seg],es
                mov     word ptr ds:[old_kb_off],bx

                mov     dx,seg new_kb_int
                mov     ds,dx
                mov     dx,offset new_kb_int
                mov     ax,2509h
                int     21h

                ret
                endp

; Restores the keyboard interrupt vector saved by set_kbhandler.
remove_kbhandler proc   near

                mov     dx,seg dseg
                mov     es,dx
                mov     ds,word ptr es:[old_kb_seg]
                mov     dx,word ptr es:[old_kb_off]
                mov     ax,2509h
                int     21h

                ret
                endp

cseg            ends

int_seg         segment para public use16 'CODE2'
                assume  cs:int_seg

; Keyboard interrupt handler. Stores the scan code of a pressed key in the
; low byte of keycode, with 1 in the high byte when a shift key is down, and
; keeps the shift state in flags. Every key press also changes random_seed.
new_kb_int      proc    far

                push    es
                push    ds
                push    ax
                push    bx

                mov     bx,seg dseg
                mov     ds,bx
                mov     bx,40h
                mov     es,bx

                in      al,060h         ; get key code
                push    ax              ; save it
                in      al,061h         ; get current control
                mov     ah,al           ; save PB control
                or      al,80h          ; set keyboard bit
                out     061h,al         ; keyboard acknowledge
                xchg    ah,al           ; get back PB
                out     061h,al         ; reset PB control

                pop     ax              ; get back code

                xor     ah,ah
                test    ds:[flags],lshiftflag+rshiftflag
                jz      kb_no_shift
                mov     ah,1
kb_no_shift:

                test    ax,80h
                jnz     kb_released     ;key releases are not saved
                inc     ds:[random_seed]
                mov     word ptr ds:[keycode],ax
kb_released:

                cmp     al,2ah          ;left shift
                jnz     not_lshift
                or      ds:[flags],lshiftflag
not_lshift:
                cmp     al,36h          ;right shift
                jnz     not_rshift
                or      ds:[flags],rshiftflag
not_rshift:
                cmp     al,0aah         ;left shift released
                jnz     not_lshift_up
                and     ds:[flags],-1-lshiftflag
not_lshift_up:
                cmp     al,0b6h         ;right shift released
                jnz     not_rshift_up
                and     ds:[flags],-1-rshiftflag
not_rshift_up:

                cli
                mov     al,20h
                out     20h,al          ; send eoi to interrupt controller
                pop     bx
                pop     ax
                pop     ds
                pop     es
                iret

                endp
                ends

                end
