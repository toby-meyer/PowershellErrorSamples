param([switch]$enableErrorOutput)

$ErrorExampleFunctions="Test-ErrorCustom","Test-ErrorCustomBroken","Test-ErrorWriteErrorThrowString","Test-ErrorWriteErrorThrowObject","Test-ErrorWriteErrorErrActionStop","Test-ErrorWriteErrorReturn","Test-ErrorWriteErrorReturnTryCatch","Test-ErrorWriteErrorErrActionStopTryCatch","Test-ErrorWriteErrorErrActionStopSimpleFunction","Test-ErrorWriteErrorErrActionStopSimpleFunctionWithERRStringConversion"
$ErrorExecutionTypes="dollarQuestionCapture","tryCatchCapture"
if ($outputTrackerData){Remove-Variable outputTrackerData -Scope Global}

$global:errorOutputInfo=@()

Write-Host "Executing..... errors. Please wait it will take a few seconds."

foreach ($name in $ErrorExampleFunctions){
    foreach ($type in $ErrorExecutionTypes){
        if ($enableErrorOutput){powershell -noProfile -Command ". $PSScriptRoot\Test-Error.ps1" -testFunction $name -testType $type -outputFile $PSScriptRoot\object.xml}
        else {powershell -noProfile -Command ". $PSScriptRoot\Test-Error.ps1" -testFunction $name -testType $type -outputFile $PSScriptRoot\object.xml > $null}
        $outputTrackerDataObject=Import-CliXML $PSScriptRoot\object.xml
        $outputTrackerDataObject | Add-Member -Type NoteProperty -Name ExitCode -Value $lastexitcode
        $global:errorOutputInfo+=$outputTrackerDataObject
        $Error.Clear()
        Remove-Item $PSScriptRoot\object.xml -Force
    }
}

Write-Host "You did it! You can find your test data in the variable errorOutputInfo . Check it out!"