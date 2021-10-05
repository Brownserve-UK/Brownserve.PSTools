# Building
This module is built using nuget via [Invoke-Build](https://github.com/nightroman/Invoke-Build) to build the module and [Pester](https://github.com/pester/Pester) to perform unit testing.
Build tasks are located in the [build_tasks](../.build/tasks/build_tasks.ps1) script and these are invoked by the [build script](../.build/build.ps1)

## Builds
### [build.ps1](.build/build.ps1)
This is a wrapper script that will call `Invoke-Build` to build, test and release our module.  
When calling the script you can specify the `-Build` parameter to determine what type of build to perform.

If you want to perform a release build then you will need a few things:
* A [GitHub PAT](https://github.com/settings/tokens) that has `repo` permissions and put it's value in  `$env:GitHubPAT`
* A [NuGet API key](https://www.nuget.org/account/apikeys)
* A [PSGallery API key](https://www.powershellgallery.com/account/apikeys)

## Building locally
### .devcontainer
By far the easiest way to test things locally is to use the included `.devcontainer` within VS Code, this will spin up an environment with all the prerequisite dependencies installed and relaunch VS Code connected to that container.
This allows you to test things quickly and easily and avoid the potential to pollute your local system.  

### Manually
If you don't use VSCode or want to build manually for whatever reason you will need to ensure you have:
* [dotnet](https://dotnet.microsoft.com/download) installed and available on your path
* [PowerShell Core](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7.1) installed and available on your path
* If on a *nix system you'll also need [mono](https://www.mono-project.com/download/stable/) to be able to run NuGet.exe
