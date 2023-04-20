@echo off
TITLE KoboldAI - Server
cd /D %~dp0

@rem config
set INSTALL_DIR=%cd%\installer_files
set CONDA_ROOT_PREFIX=%cd%\installer_files\conda
set INSTALL_ENV_DIR=%cd%\installer_files\env

@rem activate installer env
call "%CONDA_ROOT_PREFIX%\condabin\conda.bat" activate "%INSTALL_ENV_DIR%" || ( echo. && echo Miniconda hook not found. && goto end )

SET TEMP=%CONDA_ROOT_PREFIX%
SET TMP=%CONDA_ROOT_PREFIX%

cd KoboldAI
python aiserver.py %*
cmd /k
