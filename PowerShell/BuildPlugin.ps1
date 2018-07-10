#Script used to build UE4 plugins

. .\HelperFunctions.ps1

$EngineVersion = $FileContent["EngineSettings"]["TargetEngineVersion"]

$PluginFile 	= $FileContent["PluginSettings"]["PluginUFile"]
$PluginOutDir 	= $FileContent["PluginSettings"]["OutputDir"]
$PluginName		= [System.IO.Path]::GetFileNameWithoutExtension($PluginFile)

$Command = "BuildPlugin -Plugin=""$PluginFile"" -Package=""$PluginOutDir/$EngineVersion/$PluginName/"""

Run-UE4Command ([UnrealProcessType]::UAT)  $Command