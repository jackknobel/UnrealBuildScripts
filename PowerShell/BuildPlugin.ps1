. .\HelperFunctions.ps1

#Script used to build UE4 plugins

# Assumes the user is using git and has branches marked as Master, 4.18, 4,19 etc. (With Master branch corresponding to the version marked in ScriptConfig::PluginSettings::BaseVersion
$Branch = git rev-parse --symbolic-full-name --abbrev-ref HEAD

if($Branch -eq "Master")
{
	Set-Variable -Name "Branch" -Value  $FileContent["PluginSettings"]["BaseVersion"]
}

# Change our UBT Directory because we "auto discover" the appropriate engine based on branch
Set-Variable -Name "UBT" -Value @"
"$EngineDirectory/UE_$Branch/Engine/Build/BatchFiles/RunUAT.bat"
"@

$PluginUFile = $FileContent["PluginSettings"]["PluginUFile"]
$PluginOutDir = $FileContent["PluginSettings"]["OutputDir"]

$Command = @"
$UBT BuildPlugin -Plugin="$PluginUFile" -Package="$PluginOutDir/$Branch/"
"@

Run-Command($Command)