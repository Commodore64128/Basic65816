@echo off
rem
rem		Runs all current tests in an infinite loop.
rem

call exec.bat test_creation.py
call exec.bat test_comparison.py
call exec.bat test_functions.py
call exec.bat test_maths.py
call exec.bat test_change.py
call exec.bat make_tokenise.py

call exec.bat make_editor.py
python ..\scripts\check_editor.py

composite-test
