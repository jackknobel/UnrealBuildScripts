. .\HelperFunctions.ps1

$Script = @"
-Script="$BuildProjectScript" -target="Test Project" -ClearHistory -set:ProjectName="$ProjectName" -set:ProjectDir=$ProjectDir -set:BuildConfig="$BuildConfig"
"@

Run-BuildGraphScript($Script)