@echo off
setlocal enabledelayedexpansion
set "TARGET_DIR=C:\Users\%USERNAME%\Documents\GitHub\stable-diffusion-webui"

if not exist "%TARGET_DIR%" (
    echo Installing stable diffusion for the first time. 
) else (
    goto UpdateRepository
)

:promptUserGPU
echo(
powershell -Command "& {Write-Host '********************************************************************************' -ForegroundColor Green}"
powershell -Command "& {Write-Host '****** Do you have an Nvidia GPU? (4GB of VRAM recommended minimum) (Y/N) ******' -ForegroundColor Green}"
powershell -Command "& {Write-Host '********************************************************************************' -ForegroundColor Green}"
echo(
set /p userResponse=
echo.
if /i "%userResponse%"=="Y" (
    echo Proceeding...
) else if /i "%userResponse%"=="N" (
    echo This program requires an Nvidia GPU to run and 4 GB of VRAM is the recommended minimum.
    echo cancelling installation.
    pause
    exit /b
) else (
    echo Invalid response. Please enter Y or N.
    goto promptUserGPU
)

echo.
echo ***********************************************************************************
echo.

:promptUserTime
echo Stable diffusion requires downloading large files and can take 1-3+ hours depending on your internet speed.
echo(
powershell -Command "& {Write-Host '****************************************************************************************************' -ForegroundColor Green}"
powershell -Command "& {Write-Host '****** Do you have 10GB of space on your hard drive and 1+ hours for this installation? (Y/N) ******' -ForegroundColor Green}"
powershell -Command "& {Write-Host '****************************************************************************************************' -ForegroundColor Green}"
echo(
set /p userResponse=
echo.
if /i "%userResponse%"=="Y" (
    echo Proceeding...
) else if /i "%userResponse%"=="N" (
    echo This program recommends at least 10GB of hard drive space and 1+ hours of installation.
    echo please run the installation script at a later time when you meet these requirements.
    echo cancelling installation.
    pause
    exit /b
) else (
    echo Invalid response. Please enter Y or N.
    goto promptUserTime
)

echo.
echo ***********************************************************************************
echo.
set pythonJustInstalled=false

:: Check Python version
echo Checking Python installation...
python --version 2>&1 | findstr "3.10.6" > nul
if %errorlevel% NEQ 0 (
    :: If not found, download and install Python 3.10.6
    echo Downloading Python 3.10.6...
    curl -L -o python-3.10.6-amd64.exe https://www.python.org/ftp/python/3.10.6/python-3.10.6-amd64.exe
    echo Installing Python...
    echo.
    echo(
    powershell -Command "& {Write-Host '*********************************************' -ForegroundColor Green}"
    powershell -Command "& {Write-Host '****** Allow windows to install python ******' -ForegroundColor Green}"
    powershell -Command "& {Write-Host '*********************************************' -ForegroundColor Green}"
    echo.
    powershell -Command "& {Write-Host '******************************************************' -ForegroundColor Green}"
    powershell -Command "& {Write-Host '****** Select -> Add Python 3.10 to PATH        ******' -ForegroundColor Green}"
    powershell -Command "& {Write-Host '****** Select -> Install now                    ******' -ForegroundColor Green}"
    powershell -Command "& {Write-Host '******************************************************' -ForegroundColor Green}"
    powershell -Command "& {Write-Host '****** Once Python installation is complete     ******' -ForegroundColor Green}"
    powershell -Command "& {Write-Host '****** Close the installation window            ******' -ForegroundColor Green}"
    powershell -Command "& {Write-Host '****** And the installation script will proceed ******' -ForegroundColor Green}"
    powershell -Command "& {Write-Host '******************************************************' -ForegroundColor Green}"
    echo(
    echo.
    
    start /wait python-3.10.6-amd64.exe /VERYSILENT InstallAllUsers=1 PrependPath=1
    del python-3.10.6-amd64.exe
    set pythonJustInstalled=true
) else (
    echo Python 3.10.6 is already installed.
)

set gitJustInstalled=false

:: Check if git installed
git --version
git --version >nul 2>&1
if %errorlevel% NEQ 0 (
    echo Downloading Git...
    curl -L -o Git-2.42.0-64-bit.exe https://github.com/git-for-windows/git/releases/download/v2.42.0.windows.1/Git-2.42.0-64-bit.exe
    echo Installing Git...
    echo(
    powershell -Command "& {Write-Host '******************************************' -ForegroundColor Green}"
    powershell -Command "& {Write-Host '****** Allow windows to install git ******' -ForegroundColor Green}"
    powershell -Command "& {Write-Host '****** Please wait for 5 minutes    ******' -ForegroundColor Green}"
    powershell -Command "& {Write-Host '******************************************' -ForegroundColor Green}"
    echo(
    start /wait Git-2.42.0-64-bit.exe /VERYSILENT InstallAllUsers=1 PrependPath=1
    del Git-2.42.0-64-bit.exe
    set gitJustInstalled=true
) else (
    echo Git is already installed
)

:: Check the variables and print messages
if !gitJustInstalled! == true (
    echo(
    powershell -Command "& {Write-Host '****************************************************' -ForegroundColor Green}"
    powershell -Command "& {Write-Host '**************** Git was installed *****************' -ForegroundColor Green}"
    powershell -Command "& {Write-Host '************ The script will now restart ***********' -ForegroundColor Green}"
    powershell -Command "& {Write-Host '****** Rerun the script to be able to use git ******' -ForegroundColor Green}"
    powershell -Command "& {Write-Host '****************************************************' -ForegroundColor Green}"
    echo(
    pause
    exit /b
) else if !pythonJustInstalled! == true (
    echo(
    powershell -Command "& {Write-Host '*******************************************************' -ForegroundColor Green}"
    powershell -Command "& {Write-Host '**************** Python was installed *****************' -ForegroundColor Green}"
    powershell -Command "& {Write-Host '************* The script will now restart *************' -ForegroundColor Green}"
    powershell -Command "& {Write-Host '****** Rerun the script to be able to use Python ******' -ForegroundColor Green}"
    powershell -Command "& {Write-Host '*******************************************************' -ForegroundColor Green}"
    echo(
    pause
    exit /b
)

set REPO_URL=https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
if not exist "%TARGET_DIR%" (
    echo Cloning stable-diffusion-webui repository...
    git clone %REPO_URL% "%TARGET_DIR%"
    if %errorlevel% NEQ 0 (
        echo Failed to clone repository.
        pause
        exit /b
    )
    cd /d "%TARGET_DIR%"
) else (
    :UpdateRepository
    echo Repository already exists. Checking for updates...
    cd /d "%TARGET_DIR%"

    :: Fetch the latest changes from remote without modifying local branches
    git fetch
    if %errorlevel% NEQ 0 (
        echo Failed to fetch updates.
        pause
        exit /b
    )

    :: Check if the local branch is up-to-date with the remote branch
    FOR /F "tokens=*" %%i IN ('git rev-parse HEAD') DO SET LOCAL_HEAD=%%i
    FOR /F "tokens=*" %%i IN ('git rev-parse @{u}') DO SET REMOTE_HEAD=%%i

    if "%LOCAL_HEAD%"=="%REMOTE_HEAD%" (
        echo Repository is up-to-date.
    ) else (
        echo Repository is not up-to-date. You might want to pull the latest changes.
    )

    @REM echo Listing the contents of the cloned repository...
    @REM dir .\
)

:: Check if models are already downloaded
SET stableDiffusion=.\models\Stable-diffusion\v1-5-pruned-emaonly.safetensors
SET stableDiffusionXL1=.\models\Stable-diffusion\sd_xl_refiner_1.0_0.9vae.safetensors
SET stableDiffusionXL2=.\models\Stable-diffusion\sd_xl_base_1.0_0.9vae.safetensors

SET allFilesExist=true

IF NOT EXIST %stableDiffusion% (
    SET allFilesExist=false
) ELSE (
    echo model v1-5-pruned-emaonly.safetensors already installed 
)
IF NOT EXIST %stableDiffusionXL1% (
    SET allFilesExist=false
) ELSE (
    echo model sd_xl_refiner_1.0_0.9vae.safetensors already installed 
)
IF NOT EXIST %stableDiffusionXL2% (
    SET allFilesExist=false
) ELSE (
    echo model sd_xl_base_1.0_0.9vae.safetensors already installed 
)

IF "%allFilesExist%"=="true" (
    echo All models already installed.
    goto CompleteModelDownload
) ELSE (
    :: Prompt the user if models are not found
    :ModelDownloadPrompt
    echo(
    powershell -Command "& {Write-Host '*********************************************************************************' -ForegroundColor Green}"
    powershell -Command "& {Write-Host '****** Which model would you like to download?                             ******' -ForegroundColor Green}"
    powershell -Command "& {Write-Host '****** 1. Stable Diffusion (recommended for Nvidia GPU with 4+ GB VRAM)    ******' -ForegroundColor Green}"
    powershell -Command "& {Write-Host '****** 2. Stable Diffusion XL (recommended for Nvidia GPU with 8+ GB VRAM) ******' -ForegroundColor Green}"
    powershell -Command "& {Write-Host '****** 3. Both                                                             ******' -ForegroundColor Green}"
    powershell -Command "& {Write-Host '****** 4. None. (you can download them yourself later)                     ******' -ForegroundColor Green}"
    powershell -Command "& {Write-Host '****** Enter your choice (1/2/3/4):                                        ******' -ForegroundColor Green}"
    powershell -Command "& {Write-Host '*********************************************************************************' -ForegroundColor Green}"
    echo(
    set /p choice=Enter your choice 1/2/3/4)
    echo.
    set "choice=%choice: =%"
    echo.

    if /i "%choice%"=="1" (
        echo Downloading stable diffusion
    ) else if /i "%choice%"=="2" (
        echo Downloading stable diffusion XL
    ) else if /i "%choice%"=="3" (
        echo Downloading both stable diffusion and stable diffusion XL
    ) else if /i "%choice%"=="4" (
        echo Continuing. Not downloading any models.
        goto CompleteModelDownload
    ) else (
        echo Invalid response. Please enter 1, 2, 3, or 4.
        goto ModelDownloadPrompt
    )

    :: Download based on choice
    IF "%choice%"=="2" GOTO DownloadStableDiffusionXL

    IF NOT EXIST %stableDiffusion% (
        echo Downloading v1-5-pruned-emaonly.safetensors model...
        curl -L -o %stableDiffusion% https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.safetensors
        if %errorlevel% NEQ 0 (
            echo Failed to download model v1-5-pruned-emaonly.safetensors.
            pause
            exit /b
        )
    ) ELSE (
        echo File v1-5-pruned-emaonly.safetensors already installed.
    )

    IF "%choice%"=="1" GOTO CompleteModelDownload 

    :DownloadStableDiffusionXL
    IF NOT EXIST %stableDiffusionXL1% (
        echo Downloading sd_xl_refiner_1.0_0.9vae.safetensors model...
        curl -L -o %stableDiffusionXL1% https://huggingface.co/stabilityai/stable-diffusion-xl-refiner-1.0/resolve/main/sd_xl_refiner_1.0_0.9vae.safetensors
        if %errorlevel% NEQ 0 (
            echo Failed to download model sd_xl_refiner_1.0_0.9vae.safetensors.
            pause
            exit /b
        )
    ) ELSE (
        echo File sd_xl_refiner_1.0_0.9vae.safetensors already installed.
    )

    IF NOT EXIST %stableDiffusionXL2% (
        echo Downloading sd_xl_base_1.0_0.9vae.safetensors model...
        curl -L -o %stableDiffusionXL2% https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0_0.9vae.safetensors
        if %errorlevel% NEQ 0 (
            echo Failed to download model sd_xl_base_1.0_0.9vae.safetensors.
            exit /b
        )
    ) ELSE (
        echo File sd_xl_base_1.0_0.9vae.safetensors already installed.
    )
    
)

:CompleteModelDownload
echo Models downloaded successfully!


echo Running webui-user.bat...
call webui-user.bat

echo Done!
pause