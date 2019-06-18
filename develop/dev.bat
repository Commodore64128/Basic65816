@echo off
rem ***************************************************************************************************************
rem
rem		This is the DogFood area. Whenever the exec is started, the text version is tokenised and loaded.
rem		whenever you exit it is saved, detokenised to text, and archived. 
rem
rem		The idea is that it probably has some bugs remaining, and if it crashes work is preserved.
rem
rem ***************************************************************************************************************
rem
rem		Generate the block in ..\scripts\temp
rem
pushd ..\scripts
python make_basic.py ..\develop\basic.bas
popd
rem
rem		Copy the binary executable here and inject that block into it.
rem
copy ..\build\basic.bin .
python ..\scripts\import_block.py basic.bin ..\scripts\temp\basic.bin 
..\emulator\m65816.exe basic.bin go
rem
rem		Tidy up. Convert Basic.Dump back to text in basic.bas format *and* an archived
rem 	version stored in the backup directory with a timestamp.
rem
del /Q basic.bin
python ..\scripts\dump_export.py





