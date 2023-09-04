---
Module Name: Brownserve.PSTools
Module Guid: 44b45ef7-6e06-4d07-901a-210b8df05b96
Download Help Link: https://github.com/Brownserve-UK/Brownserve.PSTools/tree/main/.docs/Brownserve.PSTools
Help Version: 0.16.0-changelogchanges
Locale: en-US
---

# Brownserve.PSTools Module
## Description
A collection of PowerShell tools used in various projects.

## Brownserve.PSTools Cmdlets
### [Add-BrownserveChangelogEntry](./Brownserve.PSTools/Add-BrownserveChangelogEntry.md)
Inserts a new changelog entry into a given changelog file

### [Add-ChangelogEntry](./Brownserve.PSTools/Add-ChangelogEntry.md)
**This cmdlet is deprecated. Please use Add-BrownserveChangelogEntry instead.**
Inserts a new changelog entry into a given changelog file

### [Add-GitChanges](./Brownserve.PSTools/Add-GitChanges.md)
This cmdlet is a wrapper for the git command 'git add \<path\>'.

### [Add-ModuleHelp](./Brownserve.PSTools/Add-ModuleHelp.md)
Creates XML MALM help for a PowerShell module

### [Add-PullRequestComment](./Brownserve.PSTools/Add-PullRequestComment.md)
Adds a comment to a given pull request

### [Assert-Command](./Brownserve.PSTools/Assert-Command.md)
Ensures the given command exists and is available to the current PowerShell session

### [Assert-Directory](./Brownserve.PSTools/Assert-Directory.md)
Ensures that a directory is valid

### [Build-ModuleDocumentation](./Brownserve.PSTools/Build-ModuleDocumentation.md)
This will build markdown PowerShell module documentation using PlatyPS

### [ConvertTo-BlockComment](./Brownserve.PSTools/ConvertTo-BlockComment.md)
Converts a given text string into a block comment

### [ConvertTo-HTTPSRepoURL](./Brownserve.PSTools/ConvertTo-HTTPSRepoURL.md)
Converts a git SSH URI into the HTTPS equivalent

### [ConvertTo-SortedHashtable](./Brownserve.PSTools/ConvertTo-SortedHashtable.md)
Converts a given hashtable to an alphabetically sorted hashtable

### [Copy-GitRemoteRepository](./Brownserve.PSTools/Copy-GitRemoteRepository.md)
Clones a given git repository to the local machine

### [Format-NuGetPackageVersion](./Brownserve.PSTools/Format-NuGetPackageVersion.md)
Formats a version number to ensure compatibility with NuGet and nuget.org

### [Format-TerraformResourceName](./Brownserve.PSTools/Format-TerraformResourceName.md)
Strips out illegal characters from Terraform resource names

### [Get-GitBranches](./Brownserve.PSTools/Get-GitBranches.md)
Gets the current branches for the given repository

### [Get-GitChanges](./Brownserve.PSTools/Get-GitChanges.md)
Gets the git status for a given repository

### [Get-GitCurrentBranch](./Brownserve.PSTools/Get-GitCurrentBranch.md)
Gets the current branch for a given repository

### [Get-GitHubIssues](./Brownserve.PSTools/Get-GitHubIssues.md)
Gets the issues for a given GitHub repository

### [Get-GitHubPullRequests](./Brownserve.PSTools/Get-GitHubPullRequests.md)
Gets pull request information from a given GitHub repository.

### [Get-GitHubRelease](./Brownserve.PSTools/Get-GitHubRelease.md)
Gets a list of releases from a given GitHub repo

### [Get-GitHubTags](./Brownserve.PSTools/Get-GitHubTags.md)
Gets a list of tags for a given GitHub repository

### [Get-GitMerges](./Brownserve.PSTools/Get-GitMerges.md)
Returns a list of merge commits for a given GitHub repository

### [Get-GitRemoteOriginURL](./Brownserve.PSTools/Get-GitRemoteOriginURL.md)
Gets the remote origin URL for a given repository

### [Get-OpenPullRequests](./Brownserve.PSTools/Get-OpenPullRequests.md)
*This cmdlet is deprecated. Please use Get-GitHubOpenPullRequests instead*
Gets the open Pull requests for a given repository

### [Get-Response](./Brownserve.PSTools/Get-Response.md)
Prompts a user for a response.

### [Get-SPDXLicenseIDs](./Brownserve.PSTools/Get-SPDXLicenseIDs.md)
Attempts to get the latest SPDX license short ID list.

### [Get-Terraform](./Brownserve.PSTools/Get-Terraform.md)
Downloads the given version of Terraform for your OS

### [Get-TerraformResource](./Brownserve.PSTools/Get-TerraformResource.md)
Searches for and returns a given Terraform resource block.

### [Get-Vault](./Brownserve.PSTools/Get-Vault.md)
Downloads the given version of Vault for your OS

### [Get-VaultSecret](./Brownserve.PSTools/Get-VaultSecret.md)
Returns a secret from a given vault path

### [Import-PlatyPSModule](./Brownserve.PSTools/Import-PlatyPSModule.md)
Imports the PlatyPS module avoiding collisions with other modules.

### [Initialize-BrownserveRepository](./Brownserve.PSTools/Initialize-BrownserveRepository.md)
Prepares a repository for use for a given project

### [Install-ChocolateyPackage](./Brownserve.PSTools/Install-ChocolateyPackage.md)
Helper cmdlet for installing Chocolatey packages programmatically

### [Invoke-ConvertFromYaml](./Brownserve.PSTools/Invoke-ConvertFromYaml.md)
Wrapper cmdlet for ConvertFrom-Yaml

### [Invoke-ConvertToYaml](./Brownserve.PSTools/Invoke-ConvertToYaml.md)
Wrapper cmdlet for ConvertTo-YAML

### [Invoke-DownloadMethod](./Brownserve.PSTools/Invoke-DownloadMethod.md)
Downloads a file using the best method available depending on operating system.

### [Invoke-NativeCommand](./Brownserve.PSTools/Invoke-NativeCommand.md)
Invokes a native command while gracefully handling the output and error streams.

### [Invoke-TerraformApply](./Brownserve.PSTools/Invoke-TerraformApply.md)
Invokes 'terraform apply' with a given set of arguments

### [Invoke-TerraformInit](./Brownserve.PSTools/Invoke-TerraformInit.md)
Performs a \`terraform init\`

### [Invoke-TerraformPlan](./Brownserve.PSTools/Invoke-TerraformPlan.md)
Invokes a Terraform plan with a selection of given parameters

### [Invoke-TerraformShow](./Brownserve.PSTools/Invoke-TerraformShow.md)
Runs the `terraform show` command and converts the output into a PowerShell object.

### [Invoke-TerraformValidate](./Brownserve.PSTools/Invoke-TerraformValidate.md)
Performs a 'terraform validate'

### [Merge-Hashtable](./Brownserve.PSTools/Merge-Hashtable.md)
Merges two hashtables together

### [New-BrownserveChangelogEntry](./Brownserve.PSTools/New-BrownserveChangelogEntry.md)
Creates a new changelog entry for a given version in the standard Brownserve format.

### [New-BrownservePowerShellModule](./Brownserve.PSTools/New-BrownservePowerShellModule.md)
Creates a new PowerShell module using the standard Brownserve format

### [New-BrownservePowerShellModuleBuild](./Brownserve.PSTools/New-BrownservePowerShellModuleBuild.md)
Adds the various requirements to build a PowerShell module to a given project/repo.

### [New-BrownserveTemporaryDirectory](./Brownserve.PSTools/New-BrownserveTemporaryDirectory.md)
Creates a temporary directory

### [New-BrownserveTemporaryFile](./Brownserve.PSTools/New-BrownserveTemporaryFile.md)
Creates a temporary file in a known good location.

### [New-GitBranch](./Brownserve.PSTools/New-GitBranch.md)
Creates a new branch in a given git repository

### [New-GitHubPullRequest](./Brownserve.PSTools/New-GitHubPullRequest.md)
Creates a new GitHub pull request

### [New-GitHubRelease](./Brownserve.PSTools/New-GitHubRelease.md)
Creates a release on GitHub

### [New-NuGetPackageVersion](./Brownserve.PSTools/New-NuGetPackageVersion.md)
*This cmdlet has been deprecated and will be removed in a future release, please use Format-NuGetPackageVersion instead*
Obtains a NuGet package version based on the build version number and branch name.

### [New-PullRequest](./Brownserve.PSTools/New-PullRequest.md)
**This cmdlet is deprecated. Please use New-GitHubPullRequest instead.**
Creates a new pull request in GitHub

### [New-TerraformResourceBlock](./Brownserve.PSTools/New-TerraformResourceBlock.md)
Creates a Terraform resource block that can easily be inserted into Terraform code.

### [Publish-TeamcityArtifact](./Brownserve.PSTools/Publish-TeamcityArtifact.md)
Tells Teamcity to export a given file/folder as an artifact.

### [Push-GitChanges](./Brownserve.PSTools/Push-GitChanges.md)
Pushes local git changes to the remote repository.

### [Read-BrownserveChangelog](./Brownserve.PSTools/Read-BrownserveChangelog.md)
Reads in a changelog file and returns the contents as a custom object.

### [Read-Changelog](./Brownserve.PSTools/Read-Changelog.md)
**This cmdlet is deprecated and will be removed in a future release, please use Read-BrownserveChangelog instead.**
Retrieves version information and release notes from a CHANGELOG.md file.

### [Read-ConfigurationFromFile](./Brownserve.PSTools/Read-ConfigurationFromFile.md)
Reads values from a configuration file

### [Remove-Markdown](./Brownserve.PSTools/Remove-Markdown.md)
This cmdlet removes markdown from a string.

### [Search-FileContent](./Brownserve.PSTools/Search-FileContent.md)
Searches a file for a given set of regex and returns any text between them.

### [Send-BuildNotification](./Brownserve.PSTools/Send-BuildNotification.md)
Sends a standard Brownserve build notification.

### [Send-SlackNotification](./Brownserve.PSTools/Send-SlackNotification.md)
Sends a notification to a given Slack webhook

### [Set-LineEndings](./Brownserve.PSTools/Set-LineEndings.md)
Sets the line endings of a file to either CRLF or LF

### [Set-TeamcityBuildNumber](./Brownserve.PSTools/Set-TeamcityBuildNumber.md)
Sets the build number in Teamcity.

### [Set-TerraformLogLevel](./Brownserve.PSTools/Set-TerraformLogLevel.md)
Provides an easy way to set the Terraform log level.

### [Split-URI](./Brownserve.PSTools/Split-URI.md)
Takes a given URI and splits it into its constituent parts.

### [Submit-GitChanges](./Brownserve.PSTools/Submit-GitChanges.md)
This cmdlet is a wrapper for \<git commit\>.

### [Switch-GitBranch](./Brownserve.PSTools/Switch-GitBranch.md)
Checks out a given branch.

### [Test-Administrator](./Brownserve.PSTools/Test-Administrator.md)
A simple function for testing if a user is running with administrator/root privileges or not.

### [Test-OperatingSystem](./Brownserve.PSTools/Test-OperatingSystem.md)
Quick way of terminating scripts when they are running on an incompatible OS.

### [Update-BrownservePowerShellModule](./Brownserve.PSTools/Update-BrownservePowerShellModule.md)
Updates a given Brownserve PowerShell module to use the latest template.

### [Update-BrownserveRepository](./Brownserve.PSTools/Update-BrownserveRepository.md)
Updates a given repository to use the latest tooling and settings

### [Update-Changelog](./Brownserve.PSTools/Update-Changelog.md)
Updates a repo's changelog according to the semver v1.0.0 spec.

### [Update-PlatyPSModulePageDescription](./Brownserve.PSTools/Update-PlatyPSModulePageDescription.md)
Updates the PlatyPS module page module description field.

### [Update-PlatyPSModulePageGUID](./Brownserve.PSTools/Update-PlatyPSModulePageGUID.md)
Updates the module GUID in the PlatyPS module page.

### [Update-PlatyPSModulePageHelpVersion](./Brownserve.PSTools/Update-PlatyPSModulePageHelpVersion.md)
Updates the help version in the PlatyPS module page.

### [Update-PlatyPSModulePageLinks](./Brownserve.PSTools/Update-PlatyPSModulePageLinks.md)
Updates the links to cmdlet documentation in the PlatyPS module page.

### [Update-Version](./Brownserve.PSTools/Update-Version.md)
A simple function to increment a semantic version number.

### [Write-TeamcityBuildProblem](./Brownserve.PSTools/Write-TeamcityBuildProblem.md)
Writes a Teamcity build problem to StdOut and the same message to StdErr.

### [Write-TeamcityStatus](./Brownserve.PSTools/Write-TeamcityStatus.md)
Writes a status message to StdOut

