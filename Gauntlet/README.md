# Gauntlet Scripts
Before running these scripts it's important you have created an Automation Project for your game, as these scripts will belong in there. You can follow a guide on how to do that here:
<https://docs.unrealengine.com/en-US/Programming/BuildTools/AutomationTool/HowTo/AddingAutomationProjects/index.html>



#### Deploy Build

	Call by:
	RunUAT DeployBuild
	
	With Arguments:
	-project: The path to your game's .uproject file
	-devices: Devices to install on; <Device1,Device2> or devices=<Devices.json>
	-platform: Platform for these builds and devices
	-configuration: Configuration to install/launch. Defaults to development
	-path: Path to a folder with a build, or a folder that contains platform folders with builds in (e.g. /Saved/StagedBuilds)
	-cmdline: Additional command line arguments to pass to build for when it next launches


#### Devices.json File

Example devices.json file that can be used with gauntlet to declare a bunch of devices rather then having to manually pass them over the commandline.