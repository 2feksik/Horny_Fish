@echo off
setlocal enabledelayedexpansion

set "PROJECT_DIR=%~dp0"
set "GAME_DIR=%PROJECT_DIR%Horny_Fish"
set "SOURCE_DIR=%GAME_DIR%\source"
set "VM_DIR=%GAME_DIR%\vm"
set "TOOLS_DIR=%PROJECT_DIR%tools"
set "TOOLS_ARCHIVE=%PROJECT_DIR%tools.zip"

set "JACK_COMPILER=%TOOLS_DIR%\JackCompiler.bat"
set "VM_EMULATOR=%TOOLS_DIR%\VMEmulator.bat"

if not exist "%TOOLS_DIR%" (
    echo Extracting tools archive...
    if exist "%TOOLS_ARCHIVE%" (
        powershell -Command "Expand-Archive -Path '%TOOLS_ARCHIVE%' -DestinationPath '%PROJECT_DIR%' -Force"
    ) else (
        echo Tools archive not found! Please ensure tools.zip is in the project directory.
        pause
        goto :eof
    )
)

echo Cleaning up old vm-files from all directories...
for /R "%PROJECT_DIR%" %%f in (*.vm) do (
    del "%%f" >nul 2>&1
)

if not exist "%SOURCE_DIR%" (
    echo Creating source directory...
    mkdir "%SOURCE_DIR%"
)

if not exist "%VM_DIR%" (
    echo Creating vm directory...
    mkdir "%VM_DIR%"
)

pushd "%GAME_DIR%"
dir /b *.jack >nul 2>&1
if not errorlevel 1 (
    echo Moving jack files to source...
    for %%f in (*.jack) do (
        move /Y "%%f" "source\" >nul
    )
)
popd

dir /b "%SOURCE_DIR%\*.jack" >nul 2>&1
if errorlevel 1 (
    echo No jack files existed. We are sorry, but we have no idea where they went  :(
    echo Click any button to stop this script execution.
    pause
    goto :eof
)

echo Compiling jack-files...
for %%f in ("%SOURCE_DIR%\*.jack") do (
    call "%JACK_COMPILER%" "%%f"
)

echo If there are no compilation errors:
echo First of all, you are very lucky. And secondly, you should click any button to continue script execution.

echo If there are any compilation errors:
echo so... God help you... Because our authority in this language ended and we are tired of all this :( help us pls
pause

echo Moving vm-files...
for %%f in ("%SOURCE_DIR%\*.vm") do (
    move /Y "%%f" "%VM_DIR%" >nul
)

:ask_user
echo Do you want to start VMEmulator, before this script stop? (Y/N)
set /p "USER_INPUT=Your choice: "
set "USER_INPUT=!USER_INPUT:~0,1!"
if /i "%USER_INPUT%"=="Y" goto start_vm
if /i "%USER_INPUT%"=="N" goto end_script
echo Invalid input. Please enter Y or N.
goto ask_user

:start_vm
echo Starting VMEmulator...
pushd "%VM_DIR%"
call "%VM_EMULATOR%"
popd

goto end_script

:end_script
endlocal