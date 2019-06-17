# ********************************************************************************************************************
#
#			Builds the basic interpreter with program tokenised and pre-loaded, this is basic.bas in this
# 		directory. 
#
# ********************************************************************************************************************
#
#		Delete old files
#
rm basic.dump basic.bin basic.lst ../source/temp/*
#
#		Run the scripts. Generates tokens/offset include file, and BASIC binary file.
#
pushd ../scripts
python gentokens.py
python basicblock.py
python $1
popd
#
#		Copy generated code to source directory
#
cp ../scripts/temp/* ../source/temp
#
#		Assemble and RUN if successful
#
tass64 --m65816 -f -q ../source/start.asm -o basic.bin -L basic.lst
if [ -e basic.bin ]
then
../emulator/m65816 basic.bin go
fi
#
#		So I can benchmark it.
#
python ../scripts/calctime.py
