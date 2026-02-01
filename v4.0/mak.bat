@echo off

:: Public Domain

cd src
call setenv.bat
nmake
if errorlevel 1 goto :eof
call cpy.bat ..\
:eof
