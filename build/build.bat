@echo off
call exec.bat ..\scripts\make_gc.py
python ..\scripts\showdump.py gc

