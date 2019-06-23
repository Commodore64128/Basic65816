#
#		Runs all current tests in an infinite loop.
#
while true
do
	sh exec.sh test_creation.py
	sh exec.sh test_comparison.py
	sh exec.sh test_functions.py
	sh exec.sh test_maths.py
	sh exec.sh test_change.py
	sh exec.sh make_tokenise.py

	sh exec.sh make_editor.py
	python ../scripts/check_editor.py

	sh exec.sh test_strings.py
	python ../scripts/string_usage.py	
done
