@echo off
copy ..\core\65816.*  .
copy ..\core\65816core.c . 
copy ..\core\traps.h .
mingw32-make

