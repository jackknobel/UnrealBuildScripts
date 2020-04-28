# Unreal Build Scripts
Scripts I've found useful when developing in UE4



## Build Graph

[BuildGraph](https://docs.unrealengine.com/latest/INT/Programming/Development/BuildGraph/) scripts used for testing and building a UE4 project. If you are a familiar with BuildGraph then these should be pretty straightforward to use. If you are not, I would recommend taking a geeze (look) through the documentation or read the article I have written [here](http://jackknobel.com/How-To/BuildGraph).

Example Usage to Package for Win64

`RunUAT.bat BuildGraph -script="<ScriptPath>\BuildProject.xml" -target="Package Game Win64" -set:ProjectName=<ProjectName>-Set:ProjectDir="<FolderContainingUProjectFile>" -Set:BuildConfig=Development -Set:OutputDir="<MyBuildDir>"`

Additionally you can use the ProjectVariables.xml to set some defaults instead of having to explicitly pass them.

## Jenkins

Jenkins library used to make invoking UE4 compilation and packaging easier e.g. 
`UE4.CompileProject(params.BuildConfig as unreal.BuildConfiguration)`

See readme in sub folder for more info.



## Perforce

Perforce scripts to help with some more obtuse perforce issues like reapplying a typemap to existing files or setting local perforce variables.