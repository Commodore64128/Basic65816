# ***************************************************************************************************************
#
#		This is the DogFood area. Whenever the exec is started, the text version is tokenised and loaded.
#		whenever you exit it is saved, detokenised to text, and archived. 
#
#		The idea is that it probably has some bugs #aining, and if it crashes work is preserved.
#
# ***************************************************************************************************************
#
#		Generate the block in ../scripts/temp
#
pushd ../scripts
python make_basic.py ../develop/basic.bas
popd
#
#		cp the binary executable here and inject that block into it.
#
cp ../build/basic.bin .
python ../scripts/import_block.py basic.bin ../scripts/temp/basic.bin 
../emulator/m65816 basic.bin go
#
#		Tidy up. Convert Basic.Dump back to text in basic.bas format *and* an archived
# 	version stored in the backup directory with a timestamp.
#
rm basic.bin
python ../scripts/dump_export.py





