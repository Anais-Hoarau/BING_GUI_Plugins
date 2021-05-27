@echo off
echo Pour arreter le convertisseur, tapez CTRL+C, et repondre "n" pour finir le script et remettre les variables correctement!
set OLDPYTHONPATH=%PYTHONPATH% 
set PYTHONPATH=%CD%
set PYTHON=c:\python27\python.exe
set CONFIGFILE=..\config\example_config.ini

%PYTHON% xupy\runner.py %CONFIGFILE%

set PYTHONPATH=%OLDPYTHONPATH%
