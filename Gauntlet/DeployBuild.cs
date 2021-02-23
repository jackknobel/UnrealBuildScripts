using AutomationTool;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnrealBuildTool;

namespace Gauntlet.Examples
{
	[Help("Uses Gauntlet classes to install a build on one or more devices")]
	[Help("project=<PathToUProjectFile>", "The path to your game's .uproject file")]
	[Help("devices=<Device1,Device2> or devices=<Devices.json>", "Devices to install on. If empty uses the default device for this machine")]
	[Help("platform=<Plat>", "Platform for these builds and devices")]
	[Help("configuration=<Config>", "Configuration to install/launch. Defaults to development")]
	[Help("build=<path>", "Path to a folder with a build, or a folder that contains platform folders with builds in (e.g. /Saved/StagedBuilds)")]
	[Help("cmdline=<AdditionalArguments>", "Additional command line arguments to pass to build for when it next launches")]
	public class DeployBuild : BuildCommand
	{
		[AutoParam("")]
		public string Project;

		[AutoParamWithNames("", "device", "devices")]
		public string Devices = "";

		[AutoParam("")]
		public string Platform;

		[AutoParam("Development")]
		public string Configuration;

		[AutoParam("")]
		public string Build;

		[AutoParamWithNames("", "cmdline", "commandline")]
		public string Commandline = "";

		public override ExitCode Execute()
		{
			Log.Level = Gauntlet.LogLevel.VeryVerbose;

			AutoParam.ApplyParamsAndDefaults(this, Environment.GetCommandLineArgs());

			// Fix up any pathing issues (some implementations don't like backslashes i.e. xbox)
			Project = Path.GetFileNameWithoutExtension(Project.Replace(@"\", "/"));
			Build	= Build.Replace(@"\", "/");

			UnrealTargetPlatform ParsedPlatform				= UnrealTargetPlatform.Parse(Platform);
			UnrealTargetConfiguration ParseConfiguration	= (UnrealTargetConfiguration)Enum.Parse(typeof(UnrealTargetConfiguration), Configuration, true);

			DevicePool.Instance.AddDevices(ParsedPlatform, Devices, false);
			
			// Find sources for this platform (note some platforms have multiple sources for staged builds, packaged builds etc)
			IEnumerable<IFolderBuildSource> BuildSources = Gauntlet.Utils.InterfaceHelpers.FindImplementations<IFolderBuildSource>().Where(BuildSource => BuildSource.CanSupportPlatform(ParsedPlatform));

			// Find first build at the specified path that match the config
			IBuild FoundBuild = null;
			foreach (IBuild Build in BuildSources.SelectMany(BuildSource => BuildSource.GetBuildsAtPath(Project, Build)))
			{
				Log.Info("Found Build for {0} with config {1}", Build.Platform, Build.Configuration.ToString());

				if(Build.Configuration == ParseConfiguration)
				{
					FoundBuild = Build;
					break;
				}
			}

			if (FoundBuild == null)
			{
				throw new AutomationException("No builds for platform {0} found at {1} matching configuration {2}", Platform, Build, ParseConfiguration);
			}

			UnrealAppConfig Config	= new UnrealAppConfig();
			Config.Build			= FoundBuild;
			Config.ProjectName		= Project;
			Config.Configuration	= ParseConfiguration;
			Config.CommandLine		= Commandline;

			List<ITargetDevice> AcquiredDevices = new List<ITargetDevice>();
			
			/* This seems redundant but it's the only way to grab the devices at this stage 
			 * Todo: This will only pass in devices that are powered on, find a way to grab off devices and power them on
			 */
			Log.Info("Enumerating Devices!");
			DevicePool.Instance.EnumerateDevices(ParsedPlatform, Device =>
			{
				if(!AcquiredDevices.Contains(Device))
				{
					AcquiredDevices.Add(Device);
				}
				return true;
			});

			if(AcquiredDevices.Count == 0)
			{
				Log.Error("Failed to find any valid devices!");
				return ExitCode.Error_AppInstallFailed;
			}

			Log.Info("Beginning Installation to {0} devices!", AcquiredDevices.Count);

			// Reserve our devices so nothing else can use them
			DevicePool.Instance.ReserveDevices(AcquiredDevices);

			foreach (ITargetDevice Device in AcquiredDevices)
			{
				if (!Device.IsAvailable)
				{
					Log.Info("{0} is not available, skipping", Device.Name);
					continue;
				}

				if (!Device.IsOn)
				{
					Log.Info("Powering on {0}", Device);
					Device.PowerOn();
				}
				else if (Globals.Params.ParseParam("reboot"))
				{
					Log.Info("Rebooting {0}", Device);
					Device.Reboot();
				}
			
				if (!Device.Connect())
				{
					Log.Warning("Failed to connect to {0}", Device.Name);
					continue;
				}

				Log.Info("Installing {0} to {1}", Config.Build.ToString(), Device.Name);
				try
				{
					Device.InstallApplication(Config);
				}
				catch(AutomationException error)
				{
					Log.Error("Failed to install to {0} due to: {1}", Device.Name, error.ToString());
				}

				Log.Info("Disconnecting from {0}", Device.Name);
				Device.Disconnect();
			}

			// Release our saved devices
			DevicePool.Instance.ReleaseDevices(AcquiredDevices);

			return ExitCode.Success;
		}

	}
}
