@echo off

set batchPath=%~dp0%
set NaturalDocsParams=

rem Shift and loop so we can get more than nine parameters.
rem This is especially important if we have spaces in file names.

:MORE
if "%1"=="" goto NOMORE
set NaturalDocsParams=%NaturalDocsParams% %1
shift
goto MORE
:NOMORE

perl %batchPath%NaturalDocs %NaturalDocsParams%

set NaturalDocsParams=