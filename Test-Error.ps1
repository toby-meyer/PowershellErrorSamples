param(
	[ValidateSet("Test-ErrorCustom","Test-ErrorCustomBroken","Test-ErrorWriteErrorThrowString","Test-ErrorWriteErrorThrowObject","Test-ErrorWriteErrorErrActionStop","Test-ErrorWriteErrorErrActionStopSimpleFunction")] 
    [string]$testFunction,
    [ValidateSet("dollarQuestionCapture","tryCatchCapture")]
    [string]$testType,
    [string]$outputFile
)

function Test-ErrorCustom {
    [CmdletBinding()]
    Param(
        [Parameter(Position=0,mandatory=$false)][int]$divideBy=0
    )

    Write-Host "Executing custom error with return"
    1/$divideBy
    if (!$?){
        $errObj = new-object System.Management.Automation.RuntimeException "Omigosh you tried to divide by 0?"
        $category = [System.Management.Automation.ErrorCategory]::NotSpecified
        $errRecord = new-object System.Management.Automation.ErrorRecord $errObj, "PathNotFound", $category, $divideBy
        $psCmdlet.WriteError($errRecord)

        # do we want to return?
        return $errRecord
    }
}


function Test-ErrorCustomBroken {
    [CmdletBinding()]
    Param(
        [Parameter(Position=0,mandatory=$false)][int]$divideBy=0
    )

    Write-Host "Executing broken custom error with return"
    1/$divideBy
    if (!$?){
        $errObj = new-object System.Management.Automation.ItemNotFoundException "Omigosh you tried to divide by 0?"
        $category = [System.Management.Automation.Error1Category]::ObjectNotFound
        $errRecord = new-object System.Management.Automation.ErrorRecord $errObj, "PathNotFound", $category, $divideBy
        $psCmdlet.WriteError($errRecord)

        # do we want to return?
        return $errRecord
    }

}

function Test-ErrorWriteErrorThrowString {
    # Write-Error with throw
    [CmdletBinding()]
    Param(
        [Parameter(Position=0,mandatory=$false)][int]$divideBy=0
    )
    
    Write-Host "Executing Write-Error with throw (string)"
    1/$divideBy
    if (!$?){
        Write-Error "here is my error in my function"

        # do we want to return?
        throw "git outta here"
    }

}

function Test-ErrorWriteErrorThrowObject {
    [CmdletBinding()]
    Param(
        [Parameter(Position=0,mandatory=$false)][int]$divideBy=0
    )

    Write-Host "Executing Write-Error with throw (object)"
    1/$divideBy
    if (!$?){
        Write-Error "here is my error in my function"

        # do we want to return?
        Throw [System.Management.Automation.ValidationMetadataException] "I returned an error and I'm so proud."
    }

}


function Test-ErrorWriteErrorErrActionStop {
    [CmdletBinding()]
    Param(
        [Parameter(Position=0,mandatory=$false)][int]$divideBy=0
    )

    Write-Host "Executing Write-Error with ErrorAction Stop"
    1/$divideBy
    if (!$?){
        Write-Error "here is my error in my function" -ErrorAction Stop
    }

}

function Test-ErrorWriteErrorErrActionStopSimpleFunction {

    Write-Host "Executing non-advanced function with try/catch and terminating write-error/erroraction stop"
	try {
		1/0
	}
	catch {
		Write-error "That really didn't work.  System Error:`r`n`t$($Error[0] | Out-String)" -ErrorAction stop
	}
	write-host "We got past the error" -foregroundcolor green
}

function Set-OutputTrackerObject {
    Param(
        [Parameter(Position=0,mandatory=$true)]$testFunction,
        [Parameter(Position=1,mandatory=$true)]$testType,
        [Parameter(Position=2,mandatory=$true)]$trapStatus,
        [Parameter(Position=3,mandatory=$true)]$standardOut,
        [Parameter(Position=4,mandatory=$true)]$errorStream
    )
    $trackerObject=@([pscustomobject]@{entry=$testFunction;type=$testType;successfulTrap=$trapStatus;standardOutput=$standardOut;errorStream=$errorStream})
    return $trackerObject
}

function Write-OutputTrackerObject {
    Param(
        [Parameter(Position=0,mandatory=$true)]$objectToWrite,
        [Parameter(Position=1,mandatory=$true)]$fileToWriteTo
    )
    #Write-Warning "***********************************************************WRITING OBJECT*********************************************"
    $objectToWrite| Export-Clixml $fileToWriteTo -Force
    if (!$?){
        return $false
    }
    else {
        return $true
    }
}

$Error.Clear()
if ($output){Remove-Variable output}
$successfultrap=$false
$standardOut="null"
$errorStream=$Error.Clone()
$outputTrackerDataObject=Set-OutputTrackerObject $testFunction $testType $successfultrap $standardOut $errorStream
$writeStatus=Write-OutputTrackerObject $outputTrackerDataObject $PSScriptRoot\object$random.xml
if (!$writeStatus){
    throw "Could not persist object to file"
}
Write-Warning "*******************************TESTING FUNCTION $testFunction using $testType ********************************** `n"
switch ($testType){
    dollarQuestionCapture{
        #NOTE: We can't do Invoke-Expression $testFunction because $? will always be true since invoke-expression actually succeeded. 
        switch ($testFunction){
            Test-ErrorCustom{$output=Test-ErrorCustom}
            Test-ErrorCustomBroken{$output=Test-ErrorCustomBroken}
            Test-ErrorWriteErrorThrowString{$output=Test-ErrorWriteErrorThrowString}
            Test-ErrorWriteErrorThrowObject{$output=Test-ErrorWriteErrorThrowObject}
            Test-ErrorWriteErrorErrActionStop{$output=Test-ErrorWriteErrorErrActionStop}
            Test-ErrorWriteErrorErrActionStopSimpleFunction{$output=Test-ErrorWriteErrorErrActionStopSimpleFunction}
        }
        if (!$?){
            $successfultrap=$true
            if ($output -eq $null){
                $standardOut="null"
            }
            else {$standardOut=$output}
            $errorStream=$Error.Clone()
            $outputTrackerDataObject=Set-OutputTrackerObject $testFunction $testType $successfultrap $standardOut $errorStream
            $writeStatus=Write-OutputTrackerObject $outputTrackerDataObject $outputFile
            if (!$writeStatus){
                throw "Could not persist object to file"
            }
        }
        else {
            $successfultrap=$false
            if ($output -eq $null){
                $standardOut="null"
            }
            else {$standardOut=$output}
            $errorStream=$Error.Clone()
            $outputTrackerDataObject=Set-OutputTrackerObject $testFunction $testType $successfultrap $standardOut $errorStream
            $writeStatus=Write-OutputTrackerObject $outputTrackerDataObject $outputFile
            if (!$writeStatus){
                throw "Could not persist object to file"
            }
        }
    }
    tryCatchCapture{
        try{
            $output=Invoke-Expression "$testFunction"
        }
        catch {
            $successfultrap=$true
            if ($output -eq $null){
                $standardOut="null"
            }
            else {$standardOut=$output}
            $errorStream=$Error.Clone()
            $outputTrackerDataObject=Set-OutputTrackerObject $testFunction $testType $successfultrap $standardOut $errorStream
            $writeStatus=Write-OutputTrackerObject $outputTrackerDataObject $outputFile
            if (!$writeStatus){
                throw "Could not persist object to file"
            }
        }
        if (!$successfultrap){
            $successfultrap=$false
            if ($output -eq $null){
                $standardOut="null"
            }
            else {$standardOut=$output}
            $errorStream=$Error.Clone()
            $outputTrackerDataObject=Set-OutputTrackerObject $testFunction $testType $successfultrap $standardOut $errorStream
            $writeStatus=Write-OutputTrackerObject $outputTrackerDataObject $outputFile
            if (!$writeStatus){
                throw "Could not persist object to file"
            }
        }
    }
}
Write-Warning "******************************* $testFunction TESTING COMPLETE using $testType **********************************`n`n"