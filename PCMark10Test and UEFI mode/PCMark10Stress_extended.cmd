@echo off
IF NOT EXIST "C:\Program Files\Futuremark\PCMark 10\" GOTO ELSE
cd "C:\Program Files\Futuremark\PCMark 10\"
GOTO RUN

:ELSE
IF NOT EXIST "C:\Program Files\UL\PCMark 10\" GOTO NOT_INSTALLED
cd "C:\Program Files\UL\PCMark 10\"
GOTO RUN

:NOT_INSTALLED
echo "PCMark10 is not installed on this system."
exit /b

:RUN
call PCMark10Cmd.exe -d .\pcm10_extended.pcmdef -l 300 --log pcm.log
GOTO RUN


