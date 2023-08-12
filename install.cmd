@echo off

setlocal enableextensions
setlocal enabledelayedexpansion

cd /d "%~dp0"

set "wslImage=mosh8"
set "wslLocation=c:\serguey\wsl"
set "wslPrepareFile=mosh.wsl.tar.gz"
set "rootfsFile=photon-rootfs-4.0-1601b6aef.tar.gz"
set "rootfsUri=https://github.com/vmware/photon-docker-image/raw/79534947b866070f2e2ad119e0960ac4ba3589de/docker/photon-rootfs-4.0-1601b6aef.tar.gz"

call :isMoshInstalled || (
    if not exist "%rootfsFile%" (
        powershell Invoke-WebRequest '%rootfsUri%' -outfile '%rootfsFile%'
    )
    if not exist "%rootfsFile%" (
        echo Error downloading rootfs
        exit /b 1
    )
    wsl --import %wslImage% "%wslLocation%\%wslImage%" "%rootfsFile%" --version 1
    wsl --cd ~ -d %wslImage% -- /bin/bash -c "tdnf -y install tar"
    if exist "%wslPrepareFile%" (
        copy /y "%wslPrepareFile%" "%wslLocation%\%wslImage%\rootfs\root\"
        wsl --cd ~ -d %wslImage% -- /bin/bash -c "mkdir -p mosh.wsl && tar xvzf %wslPrepareFile% --no-recursion -C mosh.wsl"
        wsl --cd ~ -d %wslImage% -- /bin/bash -c "cd mosh.wsl && chmod +x prepare.sh && ./prepare.sh"
        wsl --cd ~ -d %wslImage% -- /bin/bash -c "rm -f %wslPrepareFile%"
        wsl -t %wslImage%
    )
)

exit /b 0


:isMoshInstalled
wsl -l -q --all >in.file
@<"in.file">"out.file" (for /f "delims=" %%i in ('find/v ""') do @chcp 1251>nul& set x=%%i& cmd/v/c echo[!x:*]^^=!)
type out.file | find "%wslImage%" >nul 2>&1 && set "notfound=0" || set "notfound=1"
del /f /q in.file out.file
exit /b %notfound%

:PressAnyKey
rem Press any key to continue
echo.
echo.Press any key continue... & pause >nul
exit /b 0