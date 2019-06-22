# ********************************************************************************************************************
#
#		Builds the basic interpreter with program tokenised and pre-loaded, this is basic.bas in this
# 		directory. 
#
# ********************************************************************************************************************
#
#		Delete old files
#
rm basic.dump basic.bin basic.lst 
rm ../source/temp/*
#
#		Run the scripts. Generates tokens/offset include file, and BASIC binary file.
#
pushd ../scripts
python gentokens.py
python basicblock.py
python $1 $2
popd
#
#		cp generated code to source directory
#
cp ../scripts/temp/* ../source/temp 
#
#		Assemble and RUN if successful
#
64tass --m65816 -f -q ../source/start.asm -o basic.bin -L basic.lst
if [ -e basic.bin ]
then
../emulator/m65816 basic.bin go
python ../scripts/calctime.py
fi
