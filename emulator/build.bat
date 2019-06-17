@echo off
copy  ..\core\65816.* . >NUL
copy  ..\core\65816core.c . >NUL
copy  ..\core\traps.h . >NUL
mingw32-make



