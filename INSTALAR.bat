@echo off
title Instalador SlotOS - monta a ISO do Tigre da Sorte
cd /d "%~dp0"
echo.
echo ==============================================
echo   SlotOS - criando a ISO (pode levar 10 a 30 min)
echo ==============================================
echo.

where docker >nul 2>&1
if errorlevel 1 (
  echo [ERRO] O Docker nao foi encontrado. Instale o Docker Desktop, reinicie o PC e rode este arquivo de novo.
  pause
  exit /b 1
)

docker info >nul 2>&1
if not errorlevel 1 goto pronto

echo O Docker ainda nao esta ligado. Tentando abrir o Docker Desktop...
if exist "%ProgramFiles%\Docker\Docker\Docker Desktop.exe" start "" "%ProgramFiles%\Docker\Docker\Docker Desktop.exe"
set /a tentativas=0
:espera
set /a tentativas+=1
if %tentativas% GTR 60 goto falhou
echo Esperando o Docker ficar pronto... (%tentativas%/60)
timeout /t 5 /nobreak >nul
docker info >nul 2>&1
if errorlevel 1 goto espera
goto pronto

:falhou
echo.
echo [ERRO] O Docker nao ficou pronto. Reinicie o PC, abra o Docker Desktop, espere aparecer "Engine running" e rode este arquivo de novo.
pause
exit /b 1

:pronto
echo Docker pronto. Montando a ISO...
echo.
set "SAIDA=%USERPROFILE%\Downloads\SlotOS-ISO"
if not exist "%SAIDA%" mkdir "%SAIDA%"

docker run --rm --privileged -v "%CD%:/kit" -v "%SAIDA%:/out" alpine:latest sh /kit/build.sh
if errorlevel 1 (
  echo.
  echo [ERRO] A montagem falhou. Tire uma foto ou copie o texto acima e mande pro Claude.
  pause
  exit /b 1
)

echo.
echo ==============================================
echo   PRONTO! A ISO esta na pasta:
echo   %SAIDA%
echo ==============================================
echo Agora grave no pendrive (Rufus, modo Imagem DD) ou copie para o Ventoy.
explorer "%SAIDA%"
pause
