# Misc Scripts
Random stuff I've written to help various workflows



#### BuildPlugin (Powershell)

Will find all installed versions of UE4, package a given plugin and has an option to zip the result.

	Call by:
	.\<PathToScript>\BuildPlugin.ps1
	
	With Arguments:
	[Required] -PluginPath: The path to your plugin's .uplugin file
	[Required] -OutputDir: The directory we want to output this plugin too (Note the *Actual* output will be OutputDir/EngineVersion/PluginName) for easier identification and drag + dropping.
	-Zip: Do we want to zip up the result (will output to the $OutputDir)
	-VersionString: Version String to append to the front of the zip file

