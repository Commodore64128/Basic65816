@echo off
call exec.bat test_creation.py
call exec.bat test_comparison.py
call exec.bat test_func.py
call exec.bat test_maths.py
call exec.bat test_change.py
call exec.bat make_gc.py
python ..\scripts\showdump.py gc

test
