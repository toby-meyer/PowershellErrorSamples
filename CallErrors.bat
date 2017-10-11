@ECHO OFF

set B=Test-ErrorCustom Test-ErrorCustomBroken Test-ErrorWriteErrorThrowString Test-ErrorWriteErrorThrowObject Test-ErrorWriteErrorErrActionStop Test-ErrorWriteErrorErrActionStopSimpleFunction
set A=dollarQuestionCapture tryCatchCapture

FOR %%b in (%B%) DO (
  FOR %%a in (%A% %%b) DO (
    if not %%bb==%%aa powershell.exe -NoProfile -NonInteractive -ExecutionPolicy unrestricted -Command "& ./Err-Test.ps1" -testFunction %%b -testType %%a; exit $LASTEXITCODE
    REM powershell.exe -File Err-Test.ps1 -testFunction %%b -testType %%a
    ECHO %ERRORLEVEL%
    IF %ERRORLEVEL% NEQ 0 (
      ECHO "WARNING: TERMINATING ERROR DETECTED :WARNING"
    )
  )
)
