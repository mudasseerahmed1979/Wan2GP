@set @x=0 /*
@echo off
cd /d "%~dp0"
setlocal enabledelayedexpansion
title WanGP Installer

python -c "import sys; sys.exit(0 if sys.version_info >= (3,10) else 1)" >nul 2>&1
if !errorlevel! equ 0 goto :MENU

echo [*] Python 3.10+ not found. Running automated installer...
call :INSTALL_PYTHON

python -c "import sys; sys.exit(0 if sys.version_info >= (3,10) else 1)" >nul 2>&1
if !errorlevel! neq 0 (
    echo [-] Automated installation failed or Python is still not recognized.
    echo [*] Please install Python 3.10+ manually.
    pause
    exit /b 1
)
goto :MENU

:MENU
echo ======================================================
echo                WAN2GP AUTOMATED INSTALLER
echo ======================================================
echo [*] Starting automatic installation with venv + CUDA 12.8
echo [*] This may take 15-30 minutes depending on your connection
echo ======================================================
set "ENV_TYPE=venv"
set "AUTO_FLAG=--auto"
goto START_INSTALL

:START_INSTALL
if "!ENV_TYPE!"=="" set "ENV_TYPE=venv"
python setup.py install --env !ENV_TYPE! !AUTO_FLAG!

echo ======================================================
echo [*] Installation complete!
echo ======================================================
exit /b 0

:INSTALL_PYTHON
if exist "C:\Program Files\PyManager\pymanager.exe" goto :INSTALL_PY311

set "PY_URL=https://www.python.org/ftp/python/pymanager/python-manager-26.0.msi"

echo [*] Downloading PyManager installer...
call :DOWNLOAD "%PY_URL%" || exit /b 1

echo [*] Installing PyManager...
for %%F in ("%PY_URL%") do set "PY_FILE=%%~nxF"
start /wait msiexec /i "%PY_FILE%" /passive /norestart
del "%PY_FILE%"

if not exist "C:\Program Files\PyManager\pymanager.exe" (
    echo [-] Installation failed.
    exit /b 1
)
echo [*] PyManager installed successfully.

:INSTALL_PY311
echo [*] Configuring Python 3.11...
set "PATH=C:\Program Files\PyManager;%PATH%"

call pymanager install --configure >nul 2>&1
call pymanager install 3.11 >nul 2>&1
call pymanager install --aliases >nul 2>&1

set "PATH=%LOCALAPPDATA%\Programs\Python\Python311;%LOCALAPPDATA%\Programs\Python\Python311\Scripts;%PATH%"
exit /b 0

:INSTALL_CONDA
echo [-] 'conda' not found.

set "CONDA_URL=https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe"

echo [*] Downloading Miniconda3...
call :DOWNLOAD "%CONDA_URL%" || (
    echo [-] Download failed. Please install Miniconda manually.
    exit /b 1
)

for %%F in ("%CONDA_URL%") do set "CONDA_FILE=%%~nxF"

echo [*] Installing Miniconda silently ^(this may take a minute^)...
start /wait "" "%CONDA_FILE%" /InstallationType=JustMe /RegisterPython=0 /S /D="%USERPROFILE%\Miniconda3"
del "%CONDA_FILE%"

echo [*] Auto-accepting Conda Terms of Service...
call "%USERPROFILE%\Miniconda3\condabin\conda.bat" tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main >nul 2>&1
call "%USERPROFILE%\Miniconda3\condabin\conda.bat" tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r >nul 2>&1
call "%USERPROFILE%\Miniconda3\condabin\conda.bat" tos accept --override-channels --channel https://repo.anaconda.com/pkgs/msys2 >nul 2>&1

exit /b 0

:DOWNLOAD
set "DL_URL=%~1"

where curl >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    curl -L -O "%DL_URL%"
    exit /b %ERRORLEVEL%
)

for %%F in ("%DL_URL%") do set "TMP_FILE=%%~nxF"

where certutil >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    certutil -urlcache -split -f "%DL_URL%" "%TMP_FILE%"
    if exist "%TMP_FILE%" exit /b 0
)

where bitsadmin >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    bitsadmin /transfer "WanGPDownload" /download /priority normal "%DL_URL%" "%CD%\%TMP_FILE%"
    if exist "%TMP_FILE%" exit /b 0
)

cscript //nologo //E:JScript "%~f0" "%DL_URL%" "%TMP_FILE%"

if exist "%TMP_FILE%" exit /b 0

echo [-] All native download methods failed.
exit /b 1

*/
var args = WScript.Arguments;
if (args.Length >= 2) {
    try {
        var http = new ActiveXObject("WinHttp.WinHttpRequest.5.1");
        http.Open("GET", args(0), false);
        http.Send();
        
        if (http.Status == 200) {
            var stream = new ActiveXObject("ADODB.Stream");
            stream.Open();
            stream.Type = 1;
            stream.Write(http.ResponseBody);
            stream.SaveToFile(args(1), 2);
            stream.Close();
        }
    } catch (e) {
    }
}