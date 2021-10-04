---
Module Name: Brownserve.PSTools
Module Guid: 44b45ef7-6e06-4d07-901a-210b8df05b96
Download Help Link: https://github.com/Brownserve-UK/Brownserve.PSTools/.docs/Module
Help Version: 0.1.0.0
Locale: en-US
---

# Brownserve.PSTools Module
## Description
A collection of PowerShell tools used in various projects.

## Brownserve.PSTools Cmdlets
### [Add-ChangelogEntry](Add-ChangelogEntry.md)
Inserts a new changelog entry into a given changelog file

### [Add-PullRequestComment](Add-PullRequestComment.md)
Adds a comment to a given pull request

### [Format-TerraformResourceName](Format-TerraformResourceName.md)
Strips out illegal characters from Terraform resource names

### [Get-GitHubRelease](Get-GitHubRelease.md)
Gets a list of releases from a given GitHub repo

### [Get-OpenPullRequests](Get-OpenPullRequests.md)
Gets the open Pull requests for a given repository

### [Get-Response](Get-Response.md)
Prompts a user for a response.

### [Get-Terraform](Get-Terraform.md)
Downloads the given version of Terraform for your OS

### [Get-TerraformResource](Get-TerraformResource.md)
Searches for and returns a given Terraform resource block.

### [Get-Vault](Get-Vault.md)
Downloads the given version of Vault for your OS

### [Get-VaultSecret](Get-VaultSecret.md)
Returns a secret from a given vault path

### [Initialize-BrownserveBuildRepo](Initialize-BrownserveBuildRepo.md)
Prepares a repo to be able to consume and use the Brownserve.PSTools module

### [Install-ChocolateyPackage](Install-ChocolateyPackage.md)
Helper cmdlet for installing Chocolatey packages programmatically

### [Invoke-DownloadMethod](Invoke-DownloadMethod.md)
Downloads a file using the best method available depending on operating system.

### [Invoke-TerraformApply](Invoke-TerraformApply.md)
Invokes 'terraform apply' with a given set of arguments

### [Invoke-TerraformInit](Invoke-TerraformInit.md)
Performs a \`terraform init\`

### [Invoke-TerraformPlan](Invoke-TerraformPlan.md)
Invokes a Terraform plan with a selection of given parameters

### [Invoke-TerraformShow](Invoke-TerraformShow.md)
Runs the `terraform show` command and converts the output into a PowerShell object.

### [Invoke-TerraformValidate](Invoke-TerraformValidate.md)
Performs a 'terraform validate'

### [New-GitHubRelease](New-GitHubRelease.md)
Creates a release on GitHub

### [New-NuGetPackageVersion](New-NuGetPackageVersion.md)
Obtains a NuGet package version based on the build version number and branch name.

### [New-PullRequest](New-PullRequest.md)
Creates a new pull request in GitHub

### [Publish-TeamcityArtifact](Publish-TeamcityArtifact.md)
Tells Teamcity to export a given file/folder as an artifact.

### [Read-Changelog](Read-Changelog.md)
Retrieves version information and release notes from a CHANGELOG.md file.

### [Send-SlackNotification](Send-SlackNotification.md)
Sends a notification to a given Slack webhook

### [Set-TeamcityBuildNumber](Set-TeamcityBuildNumber.md)
Sets the build number in Teamcity.

### [Set-TerraformLogLevel](Set-TerraformLogLevel.md)
Provides an easy way to set the Terraform log level.

### [Start-SilentProcess](Start-SilentProcess.md)
Starts a process that redirects stdout and stderr to log files

### [Update-Changelog](Update-Changelog.md)
Updates a repo's changelog according to the semver v1.0.0 spec.

### [Write-TeamcityBuildProblem](Write-TeamcityBuildProblem.md)
Writes a Teamcity build problem to StdOut and the same message to StdErr.

### [Write-TeamcityStatus](Write-TeamcityStatus.md)
Writes a status message to StdOut

