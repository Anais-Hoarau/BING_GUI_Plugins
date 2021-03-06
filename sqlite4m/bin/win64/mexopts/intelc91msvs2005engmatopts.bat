@echo off
rem INTELC91MSVS2005ENGMATOPTS.BAT
rem
rem    Compile and link options used for building stand-alone engine or MAT
rem    programs using the Intel? C++ 9.1 compiler with Microsoft? Visual
rem    Studio? 2005 linker
rem
rem    $Revision: 1.1.6.3 $  $Date: 2009/05/18 19:49:38 $
rem
rem ********************************************************************
rem General parameters
rem ********************************************************************
set MATLAB=%MATLAB%
set ICPP_COMPILER91=%ICPP_COMPILER91%
set VS80COMNTOOLS=%VS80COMNTOOLS%
set LINKERDIR=%VS80COMNTOOLS%\..\..
set PATH=%ICPP_COMPILER91%\EM64T\Bin;%LINKERDIR%\VC\BIN;%LINKERDIR%\Common7\Tools;%LINKERDIR%\Common7\Tools\bin;%LINKERDIR%\Common7\IDE;%LINKERDIR%\SDK\v2.0\bin;%PATH%
set INCLUDE=%ICPP_COMPILER91%\EM64T\Include;%LINKERDIR%\VC\ATLMFC\INCLUDE;%LINKERDIR%\VC\INCLUDE;%LINKERDIR%\VC\PlatformSDK\include;%LINKERDIR%\SDK\v2.0\include;%INCLUDE%
set LIB=%ICPP_COMPILER91%\EM64T\Lib;%LINKERDIR%\VC\ATLMFC\LIB\AMD64;%LINKERDIR%\VC\LIB\AMD64;%LINKERDIR%\VC\PlatformSDK\lib\AMD64;%LINKERDIR%\SDK\v2.0\lib\AMD64;%MATLAB%\extern\lib\win64;%LIB%
set MW_TARGET_ARCH=win64

rem ********************************************************************
rem Compiler parameters
rem ********************************************************************
set COMPILER=icl
set COMPFLAGS=-c -Zp8 -G5 -W3 -nologo /MD
set OPTIMFLAGS=/O2 /Oy- /DNDEBUG
set DEBUGFLAGS=/Z7
set NAME_OBJECT=/Fo

rem ********************************************************************
rem Linker parameters
rem ********************************************************************
set LIBLOC=%MATLAB%\extern\lib\win64\microsoft
set LINKER=link
set LINKFLAGS=/LIBPATH:"%LIBLOC%" libmx.lib libmat.lib libeng.lib /nologo kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib
set LINKOPTIMFLAGS=
set LINKDEBUGFLAGS=/debug /PDB:"%OUTDIR%%MEX_NAME%.pdb" /INCREMENTAL:NO
set LINK_FILE=
set LINK_LIB=
set NAME_OUTPUT=/out:"%OUTDIR%%MEX_NAME%.exe"
set RSP_FILE_INDICATOR=@

rem ********************************************************************
rem Resource compiler parameters
rem ********************************************************************
set RC_COMPILER=
set RC_LINKER=
set POSTLINK_CMDS1=mt -outputresource:"%OUTDIR%%MEX_NAME%.exe";1 -manifest "%OUTDIR%%MEX_NAME%.exe.manifest" 
set POSTLINK_CMDS2=del "%OUTDIR%%MEX_NAME%.exe.manifest" 
