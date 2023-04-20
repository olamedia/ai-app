@echo off
title KoboldAI Runtime Installer (miniconda)

echo Errors? Rerun this as admin so it can add the needed LongPathsEnabled registery tweak.
echo Installer failed or crashed? Run it again so it can continue.
echo Only Windows 10 and higher officially supported, older Windows installations can't handle the paths.
echo.

Reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "LongPathsEnabled" /t REG_DWORD /d "1" /f 2>nul
cd /D %~dp0
SET CONDA_SHLVL=

@rem config
set INSTALL_DIR=%cd%\installer_files
set CONDA_ROOT_PREFIX=%cd%\installer_files\conda
set INSTALL_ENV_DIR=%cd%\installer_files\env
set MINICONDA_DOWNLOAD_URL=https://repo.anaconda.com/miniconda/Miniconda3-py310_23.1.0-1-Windows-x86_64.exe
set conda_exists=F

@rem figure out whether git and conda needs to be installed
call "%CONDA_ROOT_PREFIX%\_conda.exe" --version >nul 2>&1
if "%ERRORLEVEL%" EQU "0" set conda_exists=T

@rem (if necessary) install git and conda into a contained environment
@rem download conda
if "%conda_exists%" == "F" (
	echo Downloading Miniconda from %MINICONDA_DOWNLOAD_URL% to %INSTALL_DIR%\miniconda_installer.exe

	mkdir "%INSTALL_DIR%"
	call curl -Lk "%MINICONDA_DOWNLOAD_URL%" > "%INSTALL_DIR%\miniconda_installer.exe" || ( echo. && echo Miniconda failed to download. && goto end )

	echo Installing Miniconda to %CONDA_ROOT_PREFIX%
	start /wait "" "%INSTALL_DIR%\miniconda_installer.exe" /InstallationType=JustMe /NoShortcuts=1 /AddToPath=0 /RegisterPython=0 /NoRegistry=1 /S /D=%CONDA_ROOT_PREFIX%

	@rem test the conda binary
	echo Miniconda version:
	call "%CONDA_ROOT_PREFIX%\_conda.exe" --version || ( echo. && echo Miniconda not found. && goto end )
)

@rem create the installer env
if not exist "%INSTALL_ENV_DIR%" (
  echo Packages to install: %PACKAGES_TO_INSTALL%
  call "%CONDA_ROOT_PREFIX%\_conda.exe" create --no-shortcuts -y -k --prefix "%INSTALL_ENV_DIR%" python=3.8 || ( echo. && echo Conda environment creation failed. && goto end )
)

echo 2 > loader.settings
SET TEMP=%CONDA_ROOT_PREFIX%
SET TMP=%CONDA_ROOT_PREFIX%

@rem check if conda environment was actually created
if not exist "%INSTALL_ENV_DIR%\python.exe" ( echo. && echo Conda environment is empty. && goto end )

@rem activate installer env
call "%CONDA_ROOT_PREFIX%\condabin\conda.bat" activate "%INSTALL_ENV_DIR%" || ( echo. && echo Miniconda hook not found. && goto end )

call conda env update --prefix "%INSTALL_ENV_DIR%" --file KoboldAI\environments\huggingface.yml

rem call pip install "https://github.com/0cc4m/GPTQ-for-LLaMa/releases/download/2023-04-10/quant_cuda-0.0.0-cp38-cp38-win_amd64.whl"
pause
exit
