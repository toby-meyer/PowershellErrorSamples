# PowerShell Error Handling Examples

## PowerShell error handling in functions got you down? You've come to the right place

---

## Goal

PowerShell can be a bit confusing as it pertains to error handling and capturing. Write-Error, throw, terminating errors, try/catch, $?, what does it all mean when used together? 

These simple scripts exemplify error handling techniques, and record the results to a global array of objects.

## Usage

To get started, simply execute `./Start-ErrorTests.ps1` . This will run through all the scenarios and record results to the `$errorOutputInfo` variable. By default all runtime output is supressed; if you would like to see it for debugging purposes execute with the enableErrorOutput switch, e.g. `./Start-ErrorTests.ps1 -enableErrorOutput` 

## Data Collected

Each object represents one test with the following noteProperties:

* entry: The function name, which contains a description of the test
* type: The strategy for capturing errors when calling the function. Each function is tested using !$? and try/catch
* successfulTrap: Did the !$? or try/catch successfull capture the error condition from the function?
* standardOutput: We will try to return data (the error) as standard output of the function upon failure
* errorStream: All errors exactly as they're stored in $Error. It's a clone of $Error as late as we have control in a given function
* ExitCode: Exit code from the called powershell script that executes the functions
* Unhandled terminal errors will result in immediate termination and an exit code of 1. 0 represents a "graceful exit"

## Analysis

The goal of this data is to allow you to make your own decisions, but I'll voulenteer the following: 

* If you would like to return an error as standard output the only way to do it is with a custom error object with a `psCmdlet.WriteError`
* To track all errors including the caller and the errored function command, you must use:
  * custom errors/writeError captured by a `if (!$?){}`
  * using a write-error -errorAction Stop captured by a try/catch

  Note both instantiating lines are captured in the outer error, but the scope is global with the first approach wile the scope is -1 with the later. (see full error details for more)

## Closing

Hopefully this helps you determine your strategy for error handling in your more complex scripts. Remember, consistency is key to being supportable!

### Questions/Comments feel free to contribute!