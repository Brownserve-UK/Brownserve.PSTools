# Changelog
**THIS CHANGELOG IS FOR TESTING CHANGES TO OUR GENERATION PROCESS AND NOT AN ACCURATE REPRESENTATION OF THE MODULE**
All notable changes to this project will be documented in this file.
Version numbering follows the [SemVer v2.0.0 spec](https://semver.org/spec/v2.0.0.html)

## Release

### [v0.15.0](https://github.com/Brownserve-UK/Brownserve.PSTools/tree/v0.15.0) (2023-08-10)

**Features**
- Add ConvertTo-BlockComment cmdlet

**Bugfixes**
N/A

**Known Issues**
N/A

### [v0.14.0](https://github.com/Brownserve-UK/Brownserve.PSTools/tree/v0.14.0) (2023-07-29)

**Features**
- "Add Invoke-ConvertFromYaml cmdlet"

**Bugfixes**
N/A

**Known Issues**
- There are still some oddities around loading/unloading powershell-yaml/platyPS that may cause the "assembly with same name already loaded" error

### [v0.13.1](https://github.com/Brownserve-UK/Brownserve.PSTools/tree/v0.13.1) (2023-07-23)

**Features**
- Fix: Invoke-ConvertToYaml fails with $null params

**Bugfixes**
- Fix: Invoke-ConvertToYaml fails with $null params
  
**Known Issues**
N/A

### [v0.13.0](https://github.com/Brownserve-UK/Brownserve.PSTools/tree/v0.13.0) (2023-07-23)

**Features**
- Better handling of PlatyPS/powershell-yaml module loading
- `Invoke-ConvertToYaml` cmdlet created to allow for using the `ConvertTo-YAML` cmdlet more reliably when PlatyPS is also in use.
- `Copy-GitRemoteRepository` cmdlet added to facilitate cloning git repos from a remote


**Bugfixes**
- Fixed bug whereby `Assert-Directory` wouldn't hard fail if the path is not a directory

**Known Issues**
- `powershell-yaml` and `PlatyPS` still cannot be used at the same time

### [v0.12.0](https://github.com/Brownserve-UK/Brownserve.PSTools/tree/v0.12.0) (2023-06-04)

**Features**
Cmdlet updates/additions:
- Various new classes for handling data types
- `Initialize-BrownserveRepository` cmdlet which replaces the previous `Initialize-BrownserveBuildRepo` cmdlet
- `New-BrownservePowerShellModuleBuild` which allows for the quick creation of builds in repos.
- `Assert-Command` ensures a command is present in the current session
- `ConvertTo-SortedHashtable` converts a hashtable to one which is ordered alphabetically
- Tweak `Invoke-NativeCommand` to return the exit code
- `Merge-Hashtable` merges two hashtables together
- `New-BrownserveTemporaryDirectory` replaces `New-BrownserveTempDirectory` to be more consistent with our naming
- `Read-ConfigurationFromFile` allows storing complex default data in `.json` files
- `Search-FileContent` searches a file and returns any text between the two indicators
- Rework our help generation cmdlets to actually work
- `ConvertTo-HTTPSRepoURL` converts a ssh git repo URI to the HTTPS equivalent
- Various cmdlets for working with `git`
- Rename `ConvertFrom-URI` to `Split-URI`
Build/Test features:
- Updates the build/test scripts to use our new standard approach
- Updates the repo to be compatible with our new automated init/update approach
- Removed private cmdlet documentation, these will now be documented in the cmdlets themselves if required


**Bugfixes**
N/A

**Known Issues**
- This release renames a lot of our previously used cmdlets
- Private cmdlet documentation has been removed

### [v0.11.0](https://github.com/Brownserve-UK/Brownserve.PSTools/tree/v0.11.0) (2023-04-19)

**Features**
- Add Get-SPDXLicenseIDs cmdlet

**Bugfixes**
N/A

**Known Issues**
N/A

### [v0.10.1](https://github.com/Brownserve-UK/Brownserve.PSTools/tree/v0.10.1) (2023-04-13)

**Features**
- Fixed bug in CI/CD release process

**Bugfixes**
- Fixed bug in CI/CD release process

**Known Issues**
N/A

### [v0.10.0](https://github.com/Brownserve-UK/Brownserve.PSTools/tree/v0.10.0) (2023-04-13)

**Features**
- "Create Update-BrownservePowerShellModule cmdlet"
- "Add cmdlets for creating PowerShell modules"

**Bugfixes**
N/A

**Known Issues**
N/A

### [v0.9.0](https://github.com/Brownserve-UK/Brownserve.PSTools/tree/v0.9.0) (2023-03-27)

**Features**
- "Fix Update-Changelog git commands"
- "Remove uses of global variables"
- "Add logic for checking OS compatibility"
- "Add cmdlets for generating PowerShell Module documentation/help"
- "Add New-BrownserveTemporaryFile cmdlet"
- "Refactor and rework the Invoke-NativeCommand cmdlet"

**Bugfixes**
- Fixes bug when using git to auto-generate updates using `Update-Changelog`

**Known Issues**
- The `Start-SilentProcess` cmdlet has now been removed, please use `Invoke-NativeCommand` instead

### [v0.8.2](https://github.com/Brownserve-UK/Brownserve.PSTools/tree/v0.8.2) (2022-02-21)

**Features**
- Better regex filtering for Terraform resource names

**Bugfixes**
- Fixes _another_ issue with Terraform string generation

**Known Issues**
N/A

### [v0.8.1](https://github.com/Brownserve-UK/Brownserve.PSTools/tree/v0.8.1) (2022-02-21)

**Features**
- Fixes an issue with Terraform string generation

**Bugfixes**
- Fixes an issue with Terraform string generation

**Known Issues**
N/A

### [v0.8.0](https://github.com/Brownserve-UK/Brownserve.PSTools/tree/v0.8.0) (2022-02-20)

**Features**
- Add [New-TerraformResourceBlock](.docs/Module/Public/New-TerraformResourceBlock.md) cmdlet

**Bugfixes**
- Fixes misnamed path in GitHub Actions Workflow

**Known Issues**
N/A

### [v0.7.0](https://github.com/Brownserve-UK/Brownserve.PSTools/tree/v0.7.0) (2021-12-07)

**Features**
- Replace command on Test-Administrator
- Replace `Start-SilentProcess` within this module
- Switch our build notifications over to the new logic

**Bugfixes**
N/A

**Known Issues**
This version replaces `Start-SilentProcess` with `Invoke-NativeCommand` while these are mostly compatible there may be some teething issues, please log any issues in the bug tracker.

### [v0.6.0](https://github.com/Brownserve-UK/Brownserve.PSTools/tree/v0.6.0) (2021-12-06)

**Features**
- Create a `Send-BuildNotification` cmdlet
- Add `$Global:RepoName` variable to generated `_init.ps1` scripts
- Port some logic over to use Invoke-NativeCommand
- Add `Invoke-NativeCommand` cmdlet

**Bugfixes**
N/A

**Known Issues**
N/A

### [v0.5.3](https://github.com/Brownserve-UK/Brownserve.PSTools/tree/v0.5.3) (2021-11-18)

**Features**
- Tweak logic of Send-SlackNotification

**Bugfixes**
- Fixes Send-SlackNotification not always sending notifications due to incompatible field combinations

**Known Issues**
N/A

### [v0.5.2](https://github.com/Brownserve-UK/Brownserve.PSTools/tree/v0.5.2) (2021-11-18)

**Features**
- Tweak logic of Send-SlackNotification

**Bugfixes**
- Fixes Send-SlackNotification not always sending notifications due to incompatible field combinations

**Known Issues**
N/A

### [v0.5.1](https://github.com/Brownserve-UK/Brownserve.PSTools/tree/v0.5.1) (2021-11-18)

**Features**
- Fix Slack messaging when over 3000 characters

**Bugfixes**
- Fixes Send-SlackNotification failing when messages are over 3000 characters

**Known Issues**
N/A

### [v0.5.0](https://github.com/Brownserve-UK/Brownserve.PSTools/tree/v0.5.0) (2021-11-17)

**Features**
- Refactor the Initialize-BrownserveBuildRepo cmdlet
- Update Send-SlackNotification cmdlet to make it more versatile

**Bugfixes**
N/A

**Known Issues**
N/A

### [v0.4.1](https://github.com/Brownserve-UK/Brownserve.PSTools/tree/v0.4.1) (2021-11-17)

**Features**
- Fix Send-SlackNotification

**Bugfixes**
- Fixes Send-SlackNotification not being able to correctly send a notification

**Known Issues**
N/A

### [v0.4.0](https://github.com/Brownserve-UK/Brownserve.PSTools/tree/v0.4.0) (2021-11-15)

**Features**
- Add Get-GitHubTags cmdlet
- Modify the release process

**Bugfixes**
Fixes #3

**Known Issues**
This fundamentally changes the way Update-Changelog auto-generates history from using branch history to using merge history since the last tagged release.

### [v0.3.0](https://github.com/Brownserve-UK/Brownserve.PSTools/tree/v0.3.0) (2021-10-13)

**Features**
- Added `New-TempDirectory` cmdlet

**Bugfixes**
N/A

**Known Issues**
N/A

### [v0.2.1](https://github.com/Brownserve-UK/Brownserve.PSTools/tree/v0.2.1) (2021-10-06)

**Features**
- Make Start-SilentProcess less verbose

**Bugfixes**
- Fixed [#7 [BUG]: Start-SilentProcess is too verbose](https://github.com/Brownserve-UK/Brownserve.PSTools/issues/7)

**Known Issues**
N/A

### [v0.2.0](https://github.com/Brownserve-UK/Brownserve.PSTools/tree/v0.2.0) (2021-10-06)

**Features**
- Correctly pack our NuGet package.
- Fixed 'compatibleOS' regex
- Added a new cmdlet for checking if the current session is root/admin

**Bugfixes**
- Fixed [#5 [Bug]: The built nuget package isn't in the correct format](https://github.com/Brownserve-UK/Brownserve.PSTools/issues/5)
- Fixed issue in _init script generated by `Initialize-BrownserveBuildRepo` whereby the `Import-Module` step would fail

**Known Issues**
N/A

### [v0.1.1](https://github.com/Brownserve-UK/Brownserve.PSTools/tree/v0.1.1) (2021-10-05)

**Features**
- Fix up incorrectly formed URL's

**Bugfixes**
- Fixes incorrect links throughout module

**Known Issues**
N/A

### [v0.1.0](https://github.com/Brownserve-UK/Brownserve.PSTools/tree/v0.1.0) (2021-10-03)

**Features**
- First release of the module!
  
**Bugfixes**
None

**Known Issues**
- `Initialize-BrownserveBuildRepo` is not widely tested, here be dragons.
