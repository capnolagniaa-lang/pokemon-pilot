@echo off
rem Sube el juego al servidor online y lo instala o actualiza (docs/SERVIDOR_ONLINE.md).
rem Uso: doble clic. Te pide la contrasena del servidor dos veces.
set IP=216.238.99.5
cd /d "%~dp0..\.."
if not exist "export\Pokemon Pilot\PokemonPilot.pck" (
  echo Falta export\Pokemon Pilot\PokemonPilot.pck: arma primero el zip con tools\build_portable.py
  pause
  exit /b 1
)
echo Subiendo el juego a %IP% ... (contrasena del servidor)
scp -o StrictHostKeyChecking=accept-new "export\Pokemon Pilot\PokemonPilot.pck" "tools\server\instalar_servidor.sh" root@%IP%:/root/
if errorlevel 1 goto error
echo Instalando... (contrasena otra vez)
ssh -o StrictHostKeyChecking=accept-new root@%IP% "bash /root/instalar_servidor.sh"
if errorlevel 1 goto error
echo.
echo Listo. Ya se puede jugar online.
pause
exit /b 0
:error
echo.
echo Algo fallo: mira el mensaje de arriba.
pause
exit /b 1
