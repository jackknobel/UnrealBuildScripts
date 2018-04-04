. .\HelperFunctions.ps1

$Command = "-projectfiles -project=""$ProjectFile"" -game -engine -progress"

 Run-UE4Command ([UnrealProcessType]::UBT) $Command