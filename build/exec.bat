@echo off
rem ********************************************************************************************************************
rem
rem			Builds the basic interpreter with program tokenised and pre-loaded, this is basic.bas in this
rem 		directory. 
rem
rem ********************************************************************************************************************
rem
rem		Delete old files
rem
del /Q basic.dump 
del /Q basic.bin 
del /Q basic.lst 
del /Q ..\source\temp\*
rem
rem		Run the scripts. Generates tokens\offset include file, and BASIC binary file.
rem
pushd ..\scripts
python gentokens.py
python basicblock.py
python %1 %2
popd
rem
rem		Copy generated code to source directory
rem
copy ..\scripts\temp\* ..\source\temp  >NUL
rem
rem		Assemble and RUN if successful
rem
64tass --m65816 -f -q ..\source\start.asm -o basic.bin -L basic.lst
if errorlevel 1 goto exit
..\emulator\m65816 basic.bin go
python ..\scripts\calctime.py
:exit