@echo off
if not exist obj\nul mkdir obj
if exist obj\*.obj del obj\*.obj
for %%f in (main palette menu screen game move) do tasm /z /iinc src\%%f,obj\%%f
for %%f in (score next files piece keyboard data) do tasm /z /iinc src\%%f,obj\%%f
tlink @thetris.lnk
