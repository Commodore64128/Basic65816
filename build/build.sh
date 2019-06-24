#
#	Generally used for building stuff. Most of these scripts set up random
#	basic programs which check the various operations / functions etc.
#
# sh exec.sh test_functions.py
# sh exec.sh basicblock.py

# sh exec.sh test_creation.py
# python ../scripts/showdump.py

# sh exec.sh make_tokenise.py
# python ../scripts/showdump.py


# sh exec.sh test_change.py
# python ../scripts/stringusage.py

#sh exec.sh make_editor.py
#python ../scripts/check_editor.py

#sh exec.sh test_strings.py
#python ../scripts/string_usage.py

sh exec.sh make_basic.py ../build/basic.bas
python ../scripts/string_usage.py

#sh exec.sh test_maths.py


