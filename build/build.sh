rm basic.dump  basic.bin basic.lst ../source/temp/*
cp ../scripts/tokens.txt .
pushd ../scripts
python gentokens.py
python dispvariables.py
python test_assert.py
popd
cp ../scripts/temp/* ../source/temp
tass64 --m65816 -f -q ../source/start.asm -o basic.bin -L basic.lst
if [ -e basic.bin ]
then
../emulator/m65816 basic.bin go
fi