@echo off
echo setting up system to build the MS-DOS 4.01 SOURCE BAK...
set CL=
set LINK=
set MASM=
set COUNTRY=usa-ms
if exist %TEMP%\setcurd.bat del %TEMP%\setcurd.bat
copy setcurd.bat %TEMP%\
cd >> %TEMP%\setcurd.bat
call %TEMP%\setcurd.bat
set BAKROOT=%CURRENTDIR%
rem BAKROOT points to the home drive/directory of the sources.
set LIB=%BAKROOT%\tools\bld\lib
set INIT=%BAKROOT%\tools
set INCLUDE=%BAKROOT%\tools\bld\inc
set PATH=%BAKROOT%\tools;%PATH%
