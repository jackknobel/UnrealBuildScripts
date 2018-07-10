Function Get-IniContent 
{  
    <#  
    .Synopsis  
        Gets the content of an INI file  
          
    .Description  
        Gets the content of an INI file and returns it as a hashtable  
          
    .Notes  
        Author        : Oliver Lipkau <oliver@lipkau.net>  
        Blog        : http://oliver.lipkau.net/blog/  
        Source        : https://github.com/lipkau/PsIni 
                      http://gallery.technet.microsoft.com/scriptcenter/ea40c1ef-c856-434b-b8fb-ebd7a76e8d91 
        Version        : 1.0 - 2010/03/12 - Initial release  
                      1.1 - 2014/12/11 - Typo (Thx SLDR) 
                                         Typo (Thx Dave Stiff) 
          
        #Requires -Version 2.0  
          
    .Inputs  
        System.String  
          
    .Outputs  
        System.Collections.Hashtable  
          
    .Parameter FilePath  
        Specifies the path to the input file.  
          
    .Example  
        $FileContent = Get-IniContent "C:\myinifile.ini"  
        -----------  
        Description  
        Saves the content of the c:\myinifile.ini in a hashtable called $FileContent  
      
    .Example  
        $inifilepath | $FileContent = Get-IniContent  
        -----------  
        Description  
        Gets the content of the ini file passed through the pipe into a hashtable called $FileContent  
      
    .Example  
        C:\PS>$FileContent = Get-IniContent "c:\settings.ini"  
        C:\PS>$FileContent["Section"]["Key"]  
        -----------  
        Description  
        Returns the key "Key" of the section "Section" from the C:\settings.ini file  
          
    .Link  
        Out-IniFile  
    #>  
      
    [CmdletBinding()]  
    Param(  
        [ValidateNotNullOrEmpty()]  
        [ValidateScript({(Test-Path $_) -and ((Get-Item $_).Extension -eq ".ini")})]  
        [Parameter(ValueFromPipeline=$True,Mandatory=$True)]  
        [string]$FilePath  
    )  
      
    Begin  
        {Write-Verbose "$($MyInvocation.MyCommand.Name):: Function started"}  
          
    Process  
    {  
        Write-Verbose "$($MyInvocation.MyCommand.Name):: Processing file: $Filepath"  
              
        $ini = @{}  
        switch -regex -file $FilePath  
        {  
            "^\[(.+)\]$" # Section  
            {  
                $section = $matches[1]  
                $ini[$section] = @{}  
                $CommentCount = 0  
            }  
            "^(;.*)$" # Comment  
            {  
                if (!($section))  
                {  
                    $section = "No-Section"  
                    $ini[$section] = @{}  
                }  
                $value = $matches[1]  
                $CommentCount = $CommentCount + 1  
                $name = "Comment" + $CommentCount  
                $ini[$section][$name] = $value  
            }   
            "(.+?)\s*=\s*(.*)" # Key  
            {  
                if (!($section))  
                {  
                    $section = "No-Section"  
                    $ini[$section] = @{}  
                }  
                $name,$value = $matches[1..2]  
                $ini[$section][$name] = $value  
            }  
        }  
        Write-Verbose "$($MyInvocation.MyCommand.Name):: Finished Processing file: $FilePath"  
        Return $ini  
    }  
          
    End  
        {Write-Verbose "$($MyInvocation.MyCommand.Name):: Function ended"}  
}

#================================================================================================================================================

enum UnrealProcessType
{
    UAT
    UBT
    CMD
}

$FileContent = Get-IniContent ".\ScriptConfig.ini"
if($FileContent)
{
	$ScriptSettings = $FileContent["ScriptSettings"]
	if($ScriptSettings)
	{
		$Debug = $ScriptSettings["Debug"]
	}

	$WorkspaceRoot = Split-Path -Path $PSScriptRoot
	
	$EngineSettings = $FileContent["EngineSettings"]
	if($EngineSettings)
	{
		if($Debug -eq "true")
		{
			 Write-Warning "Successfully Loaded Engine Settings"
		}

        $EngineDirectory = $EngineSettings["EngineLocation"]

        $EngineVersion = $EngineSettings["TargetEngineVersion"]

        if(-Not([string]::IsNullOrEmpty($EngineVersion)))
        {
            $EngineDirectory = Join-Path $EngineDirectory UE_$EngineVersion -Resolve
        }

        # If the path isn't relative
		if(-Not [System.IO.Path]::IsPathRooted($EngineDirectory))
		{
			 $EngineDirectory = Join-Path $WorkspaceRoot $EngineDirectory -Resolve
		}
	}

    $UATDir = "Engine/Build/BatchFiles/RunUAT.bat"
    $UBTDir = "Engine/Binaries/DotNET/UnrealBuildTool.exe"
    $UE4EditorCMDDir = "Engine/Binaries/Win64/UE4Editor-Cmd.exe"
    $BuildGraphDir = "Engine/Build/Graph/"
	
	$ProjectSettings = $FileContent["ProjectSettings"]
	if($ProjectSettings)
	{
		if($Debug -eq "true")
		{
			 Write-Warning "Successfully Loaded Project Settings"
		}
	
		# The project's uproject file
		$ProjectFile	= Join-Path $WorkspaceRoot $ProjectSettings["ProjectUFile"] -Resolve
		$ProjectName    = [System.IO.Path]::GetFileNameWithoutExtension($ProjectFile)
		$BuildConfig    = $ProjectSettings["BuildConfig"]
		$ProjectDir 	= [System.IO.Path]::GetDirectoryName($ProjectFile)
	}
}
else
{
	Write-Error "Failed to Load ini config file"
}


Function Run-UE4Command
{
     <#  
      .Synopsis  
        Runs a UE4 Command

      .Parameter UnrealProcessType  
        The process type we want to launch, UAT, UBT or UE4CMD

      .Parameter SpecifiedCommand
        The command we want to run under the given UE4 process

      .Parameter CloseAfterExecution
        Do we want to close the script after running         
    #>
     
    Param
    (
        [parameter(Mandatory)]
        [UnrealProcessType]
        $ProcessToUse,

        [parameter(Mandatory)]
        [String]
        $SpecifiedCommand,
    
        [bool]
        $CloseAfterExecution
    )

    # UE4 Build Tool Path Setup, we resolve these here so it gives a chance for the user to modify the engine directory prior to running a command
    switch($ProcessToUse)
    {
        UAT
        {
            $UnrealProcess =  $UATDir
            continue
        }
        UBT
        {
            $UnrealProcess = $UBTDir
            continue
        }
        CMD
        {
            $UnrealProcess = $UE4EditorCMDDir
            continue
        }
    }
    $UnrealProcessPath = Join-Path $EngineDirectory $UnrealProcess -Resolve
    $Command = """$UnrealProcessPath"" $SpecifiedCommand"
	
	if($Debug -eq "true")
	{
		 Write-Warning "Running Command $Command"
	}
	
    try
    {
        cmd.exe /c $Command
        if(-Not $CloseAfterExecution)
        {
            pause
        }
    }
    catch
    {
    	Write-Error "Failed to run command $SpecifiedCommand"
    	Read-Host -Prompt "Press Enter to exit"
    }
}


Function Run-BuildGraphScript
{
     <#  
      .Synopsis  
        Runs a BuildGraph Script

      .Parameter Script  
        The BuildGraph Script we want to run
     #>

  Param
    (
        [parameter(Mandatory)]
        [String]
        $Script
    )
	
	$Argument = "BuildGraph $Script"

	Run-Command ([UnrealProcessType]::UAT) $Argument
}