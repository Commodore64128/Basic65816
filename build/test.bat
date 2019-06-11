@echo off
rem
rem		Runs the basic tests .... until you get bored or the lack of Garbage collection (at the time of writing)
rem		causes chaos.
rem
call exec.bat test_creation.py
call exec.bat test_change.py
call exec.bat test_maths.py
call exec.bat test_comparison.py
call exec.bat test_func.py

test