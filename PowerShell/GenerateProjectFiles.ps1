. .\HelperFunctions.ps1

$Command = @"
$UBT -projectfiles -project="$ProjectFile" -game -engine -progress
"@

Run-Command($Command)