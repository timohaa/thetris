;----------------------------------------------------------------------------
; KEYBOARD.ASM - Keyboard interrupt handler, and installing and removing it.
;----------------------------------------------------------------------------

                include common.inc

cseg            segment
                assume  cs:cseg,ds:dseg

set_kbhandler   proc    near

                mov     ax,3509h
                int     21h

                mov     dx,seg dseg
                mov     ds,dx
                mov     word ptr ds:[old_kb_seg],es
                mov     word ptr ds:[old_kb_off],bx

                mov     dx,seg oma_kb_int
                mov     ds,dx
                mov     dx,offset oma_kb_int
                mov     ax,2509h
                int     21h

                ret
                endp

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

intit           segment para public use16 'CODE2'
                assume  cs:intit

oma_kb_int      proc    far

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
                jz      ei_lsifti
                mov     ah,1
ei_lsifti:

                test    ax,80h
                jnz     eieieieiei      ;depressions not saved
                inc     ds:[random_seed]
                mov     word ptr ds:[keycode],ax
eieieieiei:

                cmp     al,2ah          ;left shift
                jnz     eieieilshift
                or      ds:[flags],lshiftflag
eieieilshift:
                cmp     al,36h          ;right shift
                jnz     eieieirshift
                or      ds:[flags],rshiftflag
eieieirshift:
                cmp     al,0aah          ;left shift dep
                jnz     eieieilshiftd
                and     ds:[flags],-1-lshiftflag
eieieilshiftd:
                cmp     al,0b6h          ;right shift dep
                jnz     eieieirshiftd
                and     ds:[flags],-1-rshiftflag
eieieirshiftd:

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
