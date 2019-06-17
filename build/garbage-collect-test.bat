@echo off
rem
rem		Runs the garbage collect test for ever.
rem

rem
rem		Creates a basic script with garbage collectable strings by
rem		using "asdas"+"" then makes sure none of the G\C stuff should
rem		be there after G\C. The script checks the strings are the
rem		same, the following call checks there is no "garbage" left over.
rem
call exec.bat make_garbage.py

rem
rem		This checks that there is no text that should have been
rem 		collected away.
rem
python ..\scripts\showdump.py gc

garbage-collect-test