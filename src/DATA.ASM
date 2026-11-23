;----------------------------------------------------------------------------
; DATA.ASM - Data segment: palette, font tables, high score tables, texts,
;            piece shapes, key tables, settings and variables.
;----------------------------------------------------------------------------

                include common.inc

dseg            segment

                include thetris.pal
                include kirjapu.asm
                include defhigh.asm
highscore_filename db   'thetris.hi',0
setup_filename  db      'thetris.cfg',0
data_handle     dw      ?
text_1          db      'A .................................................................... Game A',0
text_2          db      'B .................................................................... Game B',0
text_3          db      'S ........................................................................ Setup',0
text_6          db      'H ................................................. See the top ten',0
text_info       db      'I ................ Information about the program',0
text_4          db      'Esc .............................................. Enough of this!',0
setup_menu      db      '-+ The Tris Setup +-',0
setup_1         db      'R ................................................. Redefine keys',0
setup_2off      db      'F .................................................... Fading is off',0
setup_2on       db      'F ..................................................... Fading is on',0
setup_3off      db      'S .................................... Sound default is off',0
setup_3on       db      'S ..................................... Sound default is on',0
setup_4off      db      'N .......................... Next piece default is off',0
setup_4on       db      'N ........................... Next piece default is on',0
setup_5         db      'Esc .......... Save changes and exit setup',0
level_text      db      'Choose starting level (0 - 9)',0
game_over_tx    db      '  Game over!  ',0
a_again_tx      db      'A .............. Play again',0
main_men_tx     db      'Esc ...... Game menu',0
high_score_tx   db      'Top 10 score!',0
type_name_tx    db      'Type your name:',0
player_name     dw      0
redefine_text   db      '-+ Key redefinition +-',0
left_key_text   db      'Move left: ',0
right_key_text  db      'Move right: ',0
rcw_key_text    db      'Rotate clockwise: ',0
rccw_key_text   db      'Rotate counter-clockwise: ',0
drop_key_text   db      'Drop: ',0
sound_key_text  db      'Sound toggle: ',0
next_key_text   db      'Next piece shown toggle: ',0
pause_key_text  db      'Pause: ',0
int_conv_buf    db      0,0,0,0,0,0,0
bufbuf          db      0,0
converter       db      230
empty_buf2      db      '           '
empty_buf       db      '         ',0
it_1            db      '-+ The Tris +-',0
it_2            db      '(c) Copyright 1994 TT-Soft',0
it_3            db      0
it_4            db      'Programmed by Timo Haanp„„',0
it_5            db      'Graphics by Tero Saarni',0
it_6            db      'This program is not free, please support',0
it_7            db      'the shareware concept.',0
it_8            db      'The contact addresses can be found in the',0
it_9            db      'document file included in the package.',0
it_10           db      'This is an unregistered version',0
;it_11           db      "Tero Saarni",0
;it_12           db      'ONLY',0
info_texts      dw      offset it_1
                dw      offset it_3
                dw      offset it_2
                dw      offset it_3
                dw      offset it_4
                dw      offset it_5
                dw      offset it_3
                dw      offset it_6
                dw      offset it_7
                dw      offset it_8
                dw      offset it_9
                dw      offset it_3
                dw      offset it_10
;                dw      offset it_11
;                dw      offset it_12
                dw      0
paloja          dw      044c0h,00e20h,06440h,08e00h     ;0 white
                dw      00f00h,02222h,00f00h,02222h     ;1 red
                dw      00cc0h,00cc0h,00cc0h,00cc0h     ;2 blue
                dw      006c0h,04620h,006c0h,04620h     ;3 green
                dw      00e80h,04460h,02e00h,0c440h     ;4 magenta
                dw      00e40h,04640h,04e00h,04c40h     ;5 brown
                dw      00c60h,02640h,00c60h,02640h     ;6 cyan
;--- level B
                dw      08000h,08000h,08000h,08000h     ;7 yellow
                dw      0c8c0h,00ae0h,06260h,0ea00h
                dw      0c800h,08c00h,04c00h,0c400h
                dw      04800h,08400h,04800h,08400h
                dw      08e20h,064c0h,08e20h,064c0h
                dw      02e80h,0c460h,02e80h,0c460h
                dw      04e40h,04e40h,04e40h,04e40h
                dw      06c80h,08c60h,026c0h,0c620h
koordit         dw      n_p+9+4*320,n_p+4,n_p+320*4,n_p+4+8*320
                dw      n_p+320*4,n_p-5,n_p+320*4,n_p-5
                dw      n_p+9,n_p+9,n_p+9,n_p+9
                dw      n_p+4,n_p+4*320,n_p+4,n_p+4*320
                dw      n_p+4,n_p+4*320,n_p+4+8*320,n_p+9+4*320
                dw      n_p+4,n_p+4*320,n_p+4+8*320,n_p+9+4*320
                dw      n_p+4,n_p+4*320,n_p+4,n_p+4*320
                dw      n_p+13+12*320,n_p+13+12*320,n_p+13+12*320,n_p+13+12*320
                dw      n_p+4+4*320,n_p+4+4*320,n_p+4+4*320,n_p+4+4*320
                dw      n_p+4+4*320,n_p+4+4*320,n_p+4+4*320,n_p+4+4*320
                dw      n_p+9+8*320,n_p+9+8*320,n_p+9+8*320,n_p+9+8*320
                dw      n_p+4+4*320,n_p+4+4*320,n_p+4+4*320,n_p+4+4*320
                dw      n_p+4+4*320,n_p+4+4*320,n_p+4+4*320,n_p+4+4*320
                dw      n_p+4+4*320,n_p+4+4*320,n_p+4+4*320,n_p+4+4*320
                dw      n_p+4+4*320,n_p+4+4*320,n_p+4+4*320,n_p+4+4*320

asciilista      dw      0,esctx,n1tx,n2tx,n3tx,n4tx,n5tx,n6tx,n7tx,n8tx,n9tx,n0tx
                dw      miinustx,onyhtakuintx,bstx,tabtx,qtx,wtx,etx,rtx,ttx
                dw      ytx,utx,itx,otx,ptx,vasenhakatx,oikeahakatx,entertx
                dw      ctrltx,atx,stx,dtx,ftx,gtx,htx,jtx,ktx,ltx
                dw      puolipilkkutx,heittotx,heitto2tx,leftshifttx
                dw      kenoviivatx,ztx,xtx,ctx,vtx,btx,ntx,mtx,pilkkutx
                dw      pistetx,kauttamerkkitx,rightshifttx,greytahtitx
                dw      alttx,spacebartx,capslocktx,f1tx,f2tx,f3tx,f4tx
                dw      f5tx,f6tx,f7tx,f8tx,f9tx,f10tx,numlocktx,scrolllocktx
                dw      hometx,arruptx,pguptx,greyminustx,arrlttx,kp5tx
                dw      arrrttx,greyplustx,endtx,arrdntx,pgdntx,instx
                dw      deltx,sysrqtx,0,leftkeno,f11tx,f12tx,PA1tx,f13tx
                dw      f14tx,f15tx,f16tx,f17tx,f18tx,f19tx,f20tx,f21tx
                dw      f22tx,f23tx,f24tx,0,0,0,0,0,0,0,0,0,0,0
ascii_dcase     db      0,0,"1234567890-=",BS,0,"qwertyuiop[]",CR
                db      0,"asdfghjkl;'",0,0,"\zxcvbnm,./",0,"*",0," ",0
                db      0,0,0,0,0,0,0,0,0,0,0,0,"789-456+1230.",0,0,"\"
                db      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                db      156 dup(0)
ascii_ucase     db      0,0,"!@#$%^&*()_+",BS,0,"QWERTYUIOP{}",CR
                db      0,'ASDFGHJKL:"',0,0,"|ZXCVBNM<>?",0,"*",0," ",0
                db      0,0,0,0,0,0,0,0,0,0,0,0,"789-456+1230.",0,0,"\"
                db      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                db      156 dup(0)


kenoviivatx     db      'Backslash',0
kauttamerkkitx  db      'Slash',0
atx             db      'A',0
btx             db      'B',0
ctx             db      'C',0
dtx             db      'D',0
etx             db      'E',0
ftx             db      'F',0
gtx             db      'G',0
htx             db      'H',0
itx             db      'I',0
jtx             db      'J',0
ktx             db      'K',0
ltx             db      'L',0
mtx             db      'M',0
ntx             db      'N',0
otx             db      'O',0
ptx             db      'P',0
qtx             db      'Q',0
rtx             db      'R',0
stx             db      'S',0
ttx             db      'T',0
utx             db      'U',0
vtx             db      'V',0
wtx             db      'W',0
xtx             db      'X',0
ytx             db      'Y',0
ztx             db      'Z',0
n1tx            db      '1',0
n2tx            db      '2',0
n3tx            db      '3',0
n4tx            db      '4',0
n5tx            db      '5',0
n6tx            db      '6',0
n7tx            db      '7',0
n8tx            db      '8',0
n9tx            db      '9',0
n0tx            db      '0',0
miinustx        db      '-',0
onyhtakuintx    db      'Equal sign',0
heittotx        db      "Quote char",0
heitto2tx       db      'Reverse quote',0
vasenhakatx     db      'Left bracket',0
oikeahakatx     db      'Right bracket',0
puolipilkkutx   db      'Semicolon',0
pistetx         db      '.',0
pilkkutx        db      ',',0
PA1tx           db      'PA1',0
leftkeno        db      'Left backslash',0
esctx           db      'Esc',0
bstx            db      'Backspace',0
tabtx           db      'Tab',0
entertx         db      'Enter',0
ctrltx          db      'Ctrl',0
leftshifttx     db      'Left shift',0
rightshifttx    db      'Right shift',0
greytahtitx     db      'Grey *',0
greyminustx     db      'Grey -',0
greyplustx      db      'Grey +',0
alttx           db      'Alt',0
spacebartx      db      'Space bar',0
capslocktx      db      'Caps lock',0
sysrqtx         db      'SysReq',0
instx           db      'Insert',0
hometx          db      'Home',0
pguptx          db      'PgUp',0
pgdntx          db      'PgDn',0
endtx           db      'End',0
deltx           db      'Delete',0
arruptx         db      'Arrow up',0
arrdntx         db      'Arrow down',0
arrlttx         db      'Arrow left',0
arrrttx         db      'Arrow right',0
kp5tx           db      'Keypad 5',0
prstx           db      'Print screen',0
scrolllocktx    db      'Scroll lock',0
numlocktx       db      'Num lock',0
pausetx         db      'Pause',0
f1tx            db      'F1',0
f2tx            db      'F2',0
f3tx            db      'F3',0
f4tx            db      'F4',0
f5tx            db      'F5',0
f6tx            db      'F6',0
f7tx            db      'F7',0
f8tx            db      'F8',0
f9tx            db      'F9',0
f10tx           db      'F10',0
f11tx           db      'F11',0
f12tx           db      'F12',0
f13tx           db      'F13',0
f14tx           db      'F14',0
f15tx           db      'F15',0
f16tx           db      'F16',0
f17tx           db      'F17',0
f18tx           db      'F18',0
f19tx           db      'F19',0
f20tx           db      'F20',0
f21tx           db      'F21',0
f22tx           db      'F22',0
f23tx           db      'F23',0
f24tx           db      'F24',0
curr_flags      db      0
flags           db      fadeflag
left_key        dw      4bh
right_key       dw      4dh
cw_rotate       dw      48h
ccw_rotate      dw      4ch
drop_key        dw      39h
sound_key       dw      1fh
next_key        dw      31h
pause_key       dw      19h
timer           db      ?
speed           db      ?
number_of_pieces db     ?
level           db      ?
rows            dw      ?
score           dw      ?
text_x          dw      ?
text_y          dw      ?
current_piece   dw      ?
current_angle   dw      ?
current_row     dw      ?
current_column  dw      ?
next_piece      dw      ?
next_angle      dw      ?
name_counter    dw      ?
random_seed     dw      ?
keycode         dw      ?
old_kb_seg      dw      ?
old_kb_off      dw      ?
lines_eliminated dw     ?
old_video_mode  db      ?

dseg            ends

                end
