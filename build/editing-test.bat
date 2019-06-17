@echo off
rem
rem		Do modification infinite loop
rem
call exec.bat make_editor.py
python ..\scripts\check_editor.py

editing-test

