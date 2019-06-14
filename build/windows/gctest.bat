@echo off
call exec.bat make_gc.py
python ..\scripts\showdump.py gc
gctest