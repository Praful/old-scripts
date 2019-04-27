@echo off
REM =============================================================================
REM  File: compile_vim_mvc_64_v8.cmd
REM  Description: compiles vim and gvim using MSVS 2019 community edition
REM  Author: Praful https://github.com/Praful/vim-config
REM  Licence: GPL v3
REM  Requires:
REM  - MSVS 2019 community edition
REM  - Lua 5.x
REM  - Perl 5.x
REM  - Pyhton 2 and 3
REM  - Ruby 2.x
REM  
REM  
REM This creates a 64-bit version of vim that's dynamically linked to Lua, Perl, 
REM Python 2, Python 3 and Ruby.
REM
REM If having trouble incuding Perl, manually generate the if_perl.c file using:
REM
REM   rem put Perl in the path. This assumes this script has already been run and this command prepends Perl.
REM   cd %SRC%
REM   set path=c:\apps\perl\5.18.2\bin;%path%
REM   %PERL_DIR%\bin\xsubpp.bat -prototypes -typemap %PERL_DIR%\lib\ExtUtils\typemap if_perl.xs > if_perl.c
REM
REM For Ruby, see INSTALLpc.txt file that comes with Vim. You will need to generate a new config.h file and copy it to where Ruby is installed:
REM
REM    git clone https://github.com/ruby/ruby.git -b ruby_2_2
REM    cd ruby
REM    win32\configure.bat
REM    nmake .config.h.time
REM    copy .ext\include\x64-mswin64_120\ruby\config.h \apps\Ruby\2.0-64\include\ruby-2.0.0\ruby
REM
REM TODO
REM Compile following:
REM  - VisVim 
REM  - vimtbar.dll
REM  - vimtutor.bat
REM  - vimtutor.com
REM =============================================================================


set VIM=c:\data\vim\src\latest
set SRC=%VIM%\src
set RELEASE=%VIM%\release64
set VIMRUNTIMEDIR=%VIM\runtime64

set APPS=c:\apps
set PYTHON_DIR=%APPS%\Python\latest2-64
set PYTHON3_DIR=%APPS%\Python\latest3-64
set RUBY_DIR=%APPS%\ruby\2.0-64
set PERL_DIR=%APPS%\perl\5.24.0\perl
set LUA_DIR=%APPS%\Lua\5.2.3-64
set THIS_SCRIPT=%~dpnx0
set MSVCDIR=c:\apps\Microsoft Visual Studio\2019\community

REM clear path since vcvarsall.bat keeps appending then blows up after a few runs since path is too long.
set LIBPATH=
set LIB=
set INCLUDE=
REM  set SDK_INCLUDE_DIR=C:\Program Files (x86)\Microsoft SDKs\Windows\v7.1A\Include

REM TODO
REM set TCL_DIR
REM
PATH=c:\data\scripts;c:\windows;c:\windows\system32;C:\apps\Git\bin;%PERL_DIR%\bin;%RUBY_DIR%\bin;%PYTHON3_DIR%;%PYTHON_DIR%

call "%MSVCDIR%\VC\Auxiliary\Build\vcvarsall.bat" amd64 10.0.17763.0

set LOGFILE=%VIM%\log.txt

echo Vim directory: %VIM%
echo Vim source directory: %SRC%

cd /d %SRC%

git pull origin master

REM Clean out previous compilation.
if exist del /Q ObjCULYHTRZAMD64\*.*
if exist del /Q ObjCULYHTRZi386\*.*
if exist del /Q ObjGXOULYHTRZAMD64\*.*
if exist del /Q ObjGXOULYHTRZi386\*.*
if exist del /Q ObjGXULYHTRZAMD64\*.*
if exist del /Q ObjGXULYHTRZi386\*.*

echo Building gvim.exe ...

REM no OLE
nmake /C /S /F Make_mvc.mak clean
nmake /C /S /F Make_mvc.mak TERMINAL=yes GUI=yes ARCH=x86-64 DEBUG=no FEATURES=HUGE MBYTE=yes CSCOPE=yes IME=yes GIME=yes OLE=no PYTHON=%PYTHON_DIR% PYTHON_VER=27 DYNAMIC_PYTHON=yes PYTHON3=%PYTHON3_DIR% PYTHON3_VER=36 DYNAMIC_PYTHON3=yes LUA=%LUA_DIR% DYNAMIC_LUA=yes LUA_VER=52 DYNAMIC_PERL=yes PERL=%PERL_DIR% PERL_VER=524 RUBY=%RUBY_DIR% RUBY_VER=25 RUBY_VER_LONG=2.5.0 DYNAMIC_RUBY=yes RUBY_MSVCRT_NAME=msvcrt  DIRECTX=yes OPTIMIZE=MAXSPEED 
REM  nmake /C /S /F Make_mvc.mak clean

REM  With OLE
REM  nmake /D /f Make_mvc.mak TERMINAL=yes GUI=yes ARCH=x86-64 DEBUG=no FEATURES=HUGE MBYTE=yes CSCOPE=yes IME=yes GIME=yes OLE=yes PYTHON=%PYTHON_DIR% PYTHON_VER=27 DYNAMIC_PYTHON=yes PYTHON3=%PYTHON3_DIR% PYTHON3_VER=36 DYNAMIC_PYTHON3=yes LUA=%LUA_DIR% DYNAMIC_LUA=yes LUA_VER=52 DYNAMIC_PERL=yes PERL=%PERL_DIR% PERL_VER=524 RUBY=%RUBY_DIR% RUBY_VER=25 RUBY_VER_LONG=2.5.0 DYNAMIC_RUBY=yes RUBY_MSVCRT_NAME=msvcrt  WINVER=0x501 DIRECTX=yes OPTIMIZE=MAXSPEED 


echo Building vim.exe ...

nmake /C /S /F Make_mvc.mak clean
nmake /C /S /F Make_mvc.mak TERMINAL=yes GUI=no ARCH=x86-64 DEBUG=no FEATURES=HUGE MBYTE=yes CSCOPE=yes IME=yes GIME=yes OLE=no PYTHON=%PYTHON_DIR% PYTHON_VER=27 DYNAMIC_PYTHON=yes PYTHON3=%PYTHON3_DIR% PYTHON3_VER=36 DYNAMIC_PYTHON3=yes LUA=%LUA_DIR% DYNAMIC_LUA=yes LUA_VER=52 DYNAMIC_PERL=yes PERL=%PERL_DIR% PERL_VER=524 RUBY=%RUBY_DIR% RUBY_VER=25 RUBY_VER_LONG=2.5.0 DYNAMIC_RUBY=yes RUBY_MSVCRT_NAME=msvcrt  DIRECTX=yes OPTIMIZE=MAXSPEED 

REM the switches disable logging and mirror the runtime folder
REM  TODO reinstate after 64-bit compile working.
REM  robocopy %VIM%\runtime %RELEASE% /MIR /NS /NC /NP /NFL /NDL
REM  goto THEEND

echo Moving files ...
move gvim.exe %RELEASE%
move vim.exe %RELEASE%
move vimrun.exe %RELEASE%
move install.exe %RELEASE%
move uninstal.exe %RELEASE%
move .\gvimext\gvimext.dll %RELEASE%
move .\tee\tee.exe %RELEASE%
move .\xxd\xxd.exe  %RELEASE%

rem copy this batch file so that we know what paramters were used to build vim
copy %THIS_SCRIPT% %RELEASE%

:THEEND

REM  pause
