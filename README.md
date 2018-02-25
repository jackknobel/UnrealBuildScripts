# UnrealBuildScripts
Scripts I have found useful when developing in UE4



## Build Graph

[BuildGraph](https://docs.unrealengine.com/latest/INT/Programming/Development/BuildGraph/) scripts used for testing and building a UE4 project. If you are a familiar with BuildGraph then these should be pretty straightforward to use, if you are not, I would recommend taking a geeze at the documentation and of running the check project powershell script.

The scripts don't contain all of the logic we use in house but should be a good reference point for developers wanting to learn how to use the build graph system.



## Jenkins

Jenkinsfile used in the production of Kieru. This script in particular was invoked every time a developer pushed to perforce. I have omitted some of the content in the script for NDA reasons but all code should still be relevant.



## Powershell

Data driven set of scripts used to compile, test and generate project files for a UE4 project/plugin.

All scripts are driven through the ScriptConfig.ini file and should be placed in the same directory as the HelperFunctions.ps1 file.

It is recommended to commit the ScriptConfig.ini file with all defaults so each developer is only changing configurations they intend to change locally (As each developer may have a different engine location or configuration for testing).



#### HelperFunctions.ps1

HelperFunction.ps1is just a shared script file for all other scripts to read from. Contains a function for reading ini files and then sets up shared properties for use among the other scripts. For building projects it is recommend to place the script file somewhere that's relative to the owning project's folder. 



#### Check Project

Check Project invokes an aggregate build graph command is similar to what is invoked by Jenkins. Be sure to set the correct settings in ScriptConfig.ini.



#### Generate Project Files

This script runs the exact same command as right clicking on your uproject file and selecting generate project files, however unlike the former method, stays active if the generation fails.



#### Build Plugin

BuildPlugin is useful when building plugins for distribution. Configuration, as with everything above, is done via the ScriptConfig file. However unlike the other scripts it uses git to detect which engine to compile with based on the branch name. Requires your git to be setup like so:

```sh
Master (4.17)
-> 4.18
-> 4.19

Each branch name indicating what engine version we want to be using
```

The engine version is then read from the branch name with UE_ appended in front (Which is the default naming scheme by Epic Games Launcher at the time of writing). What this allowed me to do was change branch and invoke this script without having to change configuration settings each time and, more importantly, have this process automated on Jenkins' end. 