@echo off
rem
rem		Runs the basic tests .... until you get bored or the lack of Garbage collection (at the time of writing)
rem		causes chaos.
rem

rem  call exec.bat test_creation.py
rem call exec.bat test_comparison.py
call exec.bat test_func.py
rem call exec.bat test_maths.py
rem call exec.bat test_change.py

rem call exec.bat make_gc.py
rem python ../scripts/showdump.py gc

test