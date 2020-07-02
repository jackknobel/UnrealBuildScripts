[CmdletBinding()]
param(
  # The path to the plugin
  [Parameter(Mandatory=$true)]
  [String]$PluginPath,

  #Where we should output the packaged plugin
  [Parameter(Mandatory=$true)]
  [String]$OutputDir,

  #Do we want to zip this file up
  [Switch]$Zip,

  #Optional Version String to append to the zip file
  [String]$VersionString = ""

)

$PluginExists = Test-Path $PluginPath
If(!$PluginExists)
{
    Write-Error("{0} is not a uplugin file, please pass the plugin's uplugin file and try again!" -f $PluginPath)
    exit 1
}

$PluginName = (Get-ChildItem $PluginPath).BaseName

Write-Output `n
Write-Output "========================================================================="
Write-Output("Beginning Package of Plugin {0}" -f $PluginName)
Write-Output "========================================================================"
Write-Output `n

# Check the registry for what engine versions we have installed
$EngineInstalls = Get-ChildItem -Path "Registry::HKLM\SOFTWARE\EpicGames\Unreal Engine\"
Write-Host ("Found {0} Engine Installs:" -f $EngineInstalls.Count) -ForegroundColor Yellow

# Quickly just print their name
Foreach($Install in $EngineInstalls)
{
    Write-Output ("{0}" -f $Install.PSChildName)
}

Write-Output `n

$FailedPackages = @()

# For each engine install attempt package the plugin
Foreach($Install in $EngineInstalls)
{
    $Successful = $false

    # Get our Engine directory value
    $EngineDir = $Install.GetValue("InstalledDirectory")
    If($EngineDir)
    {
        $EngineVersion = $Install.PSChildName

        Write-Output "Targeting Engine Version $EngineVersion at path $EngineDir `n"

        $AutomationToolExe =  "{0}/Engine/Binaries/DotNET/AutomationTool.exe" -f $EngineDir

        $PackageOutputPath = "$OutputDir/$EngineVersion/$PluginName"

        $process = start-process $AutomationToolExe -Wait -ArgumentList "BuildPlugin -Plugin=`"$PluginPath`" -Package=`"$PackageOutputPath`" -CreateSubFolder" -NoNewWindow -PassThru
        if($process.ExitCode -eq 0)
        {
            $Successful = $True

            If($Zip)
            {
                #Using ${<Arg>} because _ seems to break argument expansion
                $ZipName = "${PluginName}_[${EngineVersion}]"

                If($VersionString)
                {
                    $ZipName = "${VersionString}-${ZipName}"
                }

                Write-Output ("Zipping to: $OutputDir/$ZipName.zip")

                [void][Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem')
                [IO.Compression.ZipFile]::CreateFromDirectory("$PackageOutputPath", "$OutputDir/$ZipName.zip", 'Optimal', $true)
            }
        }
    }

    Write-Output `n

    if($Successful)
    {
        Write-Host(“Succesfully packaged {0} for {1}” -f $PluginName, $EngineVersion) -ForegroundColor Green
    }
    else
    {
        $FailedPackages += $Install.PSChildName
        Write-Error "Failed to package plugin for $EngineVersion"
    }

     Write-Output `n
}

# Print Summary

If($FailedPackages.Count -gt 0)
{
    Write-Warning("Failed to package plugin for:")
    Foreach($Failure in $FailedPackages)
    {
        Write-Warning("      {0}" -f $Failure)
    }

    exit $FailedPackages.Count
}
else
{
    Write-Host “Packaging of Plugin $PluginName was Successful!” -ForegroundColor Green
    exit 0
}
