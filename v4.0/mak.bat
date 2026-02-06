@echo off

:: Public Domain

cd src
call setenv.bat
nmake
if errorlevel 1 goto :done
call cpy.bat ..\
:done
exitemu
