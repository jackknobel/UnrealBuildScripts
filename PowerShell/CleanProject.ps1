 
<# 
Script to clean a project's generated and binary files. 
Similar to the clean operation in Visual Studio but for Source engine builds won't result in a full engine rebuild, only project.
#>

 param (
    [string]$IncProjectFiles = $( Read-Host "Clean and Regenerate Visual Studio Project Files?" )
 )

 # Default Directories we want to remove
 $DefaultDirectories = "$ProjectDir/Binaries", "$ProjectDir/Intermediate/Build"

 foreach($Directory in $DefaultDirectories)
 {
    if(Test-Path $Directory)
    {
        Remove-Item -Path $Directory -Recurse -Force
    }
 }

 # Simple check will do the job
if($IncProjectFiles.Contains("y"))
{    
    # Visual Studio Directories we want to remove
    $VSProjectDirectories = "$ProjectDir/.vs", "$ProjectDir/Intermediate/ProjectFiles"

    foreach($Directory in $VSProjectDirectories)
    {
        if(Test-Path $Directory)
        {
            Remove-Item -Path $Directory -Recurse -Force
        }
    }
    .\GenerateProjectFiles.ps1
}