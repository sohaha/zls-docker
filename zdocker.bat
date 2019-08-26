@ECHO OFF
set mycd=%cd%
cd /d %~dp0
set c=%1
set a=%*
call :CurDIR "%cd%"
goto :eof
:CurDIR
set _dockerDir=%~nx1
set volume=--volume %mycd%:/var/www/html

if %c% == php (docker run --tty --interactive --rm --cap-add SYS_PTRACE %volume% --workdir /var/www/html "%_dockerDir%_php" %a%) 

if %c% == composer (docker run --tty --interactive --rm --cap-add SYS_PTRACE %volume% --workdir /var/www/html "%_dockerDir%_php" %a%) 

if %c% == node (docker run --tty --interactive --rm --cap-add SYS_PTRACE %volume% --workdir /var/www/html "%_dockerDir%_node" %a%) 

if %c% == npm (docker run --tty --interactive --rm --cap-add SYS_PTRACE %volume% --workdir /var/www/html "%_dockerDir%_node" %a%) 

cd /d %mycd%