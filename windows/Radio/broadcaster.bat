@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "RECORD_DIR=D:\Recordings"
set "ICECAST_SERVICE_NAME=Icecast"

REM Optional arg: start | stop | restart (default = start)
set "CMD=%~1"
if "%CMD%"=="" set "CMD=start"
set "CMD=%CMD:"=%"

echo [BLKLST] Ensure recordings dir: %RECORD_DIR%
if not exist "%RECORD_DIR%" mkdir "%RECORD_DIR%"

echo [BLKLST] Checking service: %ICECAST_SERVICE_NAME%
sc query "%ICECAST_SERVICE_NAME%" >nul 2>&1 || (
  echo [BLKLST] ERROR: Service not found: %ICECAST_SERVICE_NAME%
  exit /b 1
)

call :GetState
echo [BLKLST] Current state: !SERVICE_STATE!

if /I "%CMD%"=="stop"  goto DO_STOP
if /I "%CMD%"=="restart" goto DO_RESTART
goto DO_START

:DO_RESTART
if "!SERVICE_STATE!"=="4" (
  call :StopService
)
goto DO_START

:DO_STOP
call :StopService
goto END

:DO_START
echo [BLKLST] Starting Icecast...
net start "%ICECAST_SERVICE_NAME%" >nul 2>&1 || (
  echo [BLKLST] ERROR: Failed to start Icecast.
  exit /b 1
)

call :GetState
echo [BLKLST] Now state: !SERVICE_STATE!
echo [BLKLST] OK. Status: http://localhost:8000/status.xsl
echo [BLKLST] Player: http://localhost:8000/player.html
goto END


:GetState
set "SERVICE_STATE="
for /f "tokens=3" %%A in ('sc query "%ICECAST_SERVICE_NAME%" ^| find "STATE"') do set "SERVICE_STATE=%%A"
exit /b 0


:StopService
echo [BLKLST] Stopping Icecast...
net stop "%ICECAST_SERVICE_NAME%" >nul 2>&1

set /a tries=0
:WAIT_STOP
set /a tries+=1
call :GetState
if "!SERVICE_STATE!"=="1" (
  echo [BLKLST] Stopped.
  exit /b 0
)

if !tries! GEQ 20 (
  echo [BLKLST] WARN: Stop timed out after 20s.
  exit /b 0
)

timeout /t 1 /nobreak >nul
goto WAIT_STOP


:END
endlocal
