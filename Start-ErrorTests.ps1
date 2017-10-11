$ErrorExampleFunctions="Test-ErrorCustom","Test-ErrorCustomBroken","Test-ErrorWriteErrorThrowString","Test-ErrorWriteErrorThrowObject","Test-ErrorWriteErrorErrActionStop","Test-ErrorWriteErrorErrActionStopSimpleFunction"
$ErrorExecutionTypes="dollarQuestionCapture","tryCatchCapture"
if ($outputTrackerData){Remove-Variable outputTrackerData}

$outputTrackerData=@()


foreach ($name in $ErrorExampleFunctions){
    foreach ($type in $ErrorExecutionTypes){
        powershell -noProfile -Command ". $PSScriptRoot\Test-Error.ps1" -testFunction $name -testType $type -outputFile $PSScriptRoot\object.xml
        $outputTrackerDataObject=Import-CliXML $PSScriptRoot\object.xml
        $outputTrackerDataObject | Add-Member -Type NoteProperty -Name ExitCode -Value $lastexitcode
        $outputTrackerData+=$outputTrackerDataObject
        $Error.Clear()
    }
}