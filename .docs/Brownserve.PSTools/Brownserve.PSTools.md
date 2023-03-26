---
Module Name: Brownserve.PSTools
Module Guid: 44b45ef7-6e06-4d07-901a-210b8df05b96
Download Help Link: https://github.com/Brownserve-UK/Brownserve.PSTools/tree/main/.docs/Module
Help Version: 0.1.0.0
Locale: en-US
---

# Brownserve.PSTools Module
## Description
A collection of PowerShell tools used in various projects.

## Brownserve.PSTools Cmdlets
### [Add-ChangelogEntry](./Public/Add-ChangelogEntry.md)
Inserts a new changelog entry into a given changelog file

### [Add-ModuleHelp](./Public/Add-ModuleHelp.md)
Creates XML MALM help for a PowerShell module

### [Add-PullRequestComment](./Public/Add-PullRequestComment.md)
Adds a comment to a given pull request

### [Build-ModuleDocumentation](./Public/Build-ModuleDocumentation.md)
This will build markdown PowerShell module documentation using PlatyPS

### [Format-TerraformResourceName](./Public/Format-TerraformResourceName.md)
Strips out illegal characters from Terraform resource names

### [Get-GitHubRelease](./Public/Get-GitHubRelease.md)
Gets a list of releases from a given GitHub repo

### [Get-GitHubTags](./Public/Get-GitHubTags.md)
Gets a list of tags for a given GitHub repository

### [Get-OpenPullRequests](./Public/Get-OpenPullRequests.md)
Gets the open Pull requests for a given repository

### [Get-Response](./Public/Get-Response.md)
Prompts a user for a response.

### [Get-Terraform](./Public/Get-Terraform.md)
Downloads the given version of Terraform for your OS

### [Get-TerraformResource](./Public/Get-TerraformResource.md)
Searches for and returns a given Terraform resource block.

### [Get-Vault](./Public/Get-Vault.md)
Downloads the given version of Vault for your OS

### [Get-VaultSecret](./Public/Get-VaultSecret.md)
Returns a secret from a given vault path

### [Initialize-BrownserveBuildRepo](./Public/Initialize-BrownserveBuildRepo.md)
Prepares a repo to be able to consume and use the Brownserve.PSTools PowerShell module

### [Install-ChocolateyPackage](./Public/Install-ChocolateyPackage.md)
Helper cmdlet for installing Chocolatey packages programmatically

### [Invoke-DownloadMethod](./Public/Invoke-DownloadMethod.md)
Downloads a file using the best method available depending on operating system.

### [Invoke-NativeCommand](./Public/Invoke-NativeCommand.md)
Invokes a native command while gracefully handling the output and error streams.

### [Invoke-TerraformApply](./Public/Invoke-TerraformApply.md)
Invokes 'terraform apply' with a given set of arguments

### [Invoke-TerraformInit](./Public/Invoke-TerraformInit.md)
Performs a \`terraform init\`

### [Invoke-TerraformPlan](./Public/Invoke-TerraformPlan.md)
Invokes a Terraform plan with a selection of given parameters

### [Invoke-TerraformShow](./Public/Invoke-TerraformShow.md)
Runs the `terraform show` command and converts the output into a PowerShell object.

### [Invoke-TerraformValidate](./Public/Invoke-TerraformValidate.md)
Performs a 'terraform validate'

### [New-BrownserveTemporaryFile](./Public/New-BrownserveTemporaryFile.md)
Creates a temporary file in a known good location.

### [New-GitHubRelease](./Public/New-GitHubRelease.md)
Creates a release on GitHub

### [New-NuGetPackageVersion](./Public/New-NuGetPackageVersion.md)
Obtains a NuGet package version based on the build version number and branch name.

### [New-PullRequest](./Public/New-PullRequest.md)
Creates a new pull request in GitHub

### [New-TempDirectory](./Public/New-TempDirectory.md)
Creates a new temporary directory with a random name in the systems temporary directory

### [New-TerraformResourceBlock](./Public/New-TerraformResourceBlock.md)
Creates a Terraform resource block that can easily be inserted into Terraform code.

### [Publish-TeamcityArtifact](./Public/Publish-TeamcityArtifact.md)
Tells Teamcity to export a given file/folder as an artifact.

### [Read-Changelog](./Public/Read-Changelog.md)
Retrieves version information and release notes from a CHANGELOG.md file.

### [Send-BuildNotification](./Public/Send-BuildNotification.md)
Sends a standard Brownserve build notification.

### [Send-SlackNotification](./Public/Send-SlackNotification.md)
Sends a notification to a given Slack webhook

### [Set-TeamcityBuildNumber](./Public/Set-TeamcityBuildNumber.md)
Sets the build number in Teamcity.

### [Set-TerraformLogLevel](./Public/Set-TerraformLogLevel.md)
Provides an easy way to set the Terraform log level.

### [Test-Administrator](./Public/Test-Administrator.md)
A simple function for testing if a user is running with administrator/root privileges or not.

### [Test-OperatingSystem](./Public/Test-OperatingSystem.md)
Quick way of terminating scripts when they are running on an incompatible OS.

### [Update-Changelog](./Public/Update-Changelog.md)
Updates a repo's changelog according to the semver v1.0.0 spec.

### [Write-TeamcityBuildProblem](./Public/Write-TeamcityBuildProblem.md)
Writes a Teamcity build problem to StdOut and the same message to StdErr.

### [Write-TeamcityStatus](./Public/Write-TeamcityStatus.md)
Writes a status message to StdOut

