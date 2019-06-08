@echo off
del /Q 	basic.dump  
del /Q 	basic.bin 
del /Q 	basic.lst 
del /Q 	..\source\temp\*
copy ..\scripts\tokens.txt .
pushd ..\scripts
python gentokens.py

rem python dispvariables.py
	
rem python test_assert.py
rem python test_math.py
rem python test_compare.py
python test_functions.py

popd
copy ..\scripts\temp\* ..\source\temp
64tass --m65816 -f -q ..\source\start.asm -o basic.bin -L basic.lst
if errorlevel 1 goto :exit
..\emulator\m65816.exe basic.bin go
rem python ..\scripts\showdump.py
:exit
