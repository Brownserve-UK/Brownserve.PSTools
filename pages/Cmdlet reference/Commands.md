---
Module Name: Brownserve.PSTools
Module Guid: 44b45ef7-6e06-4d07-901a-210b8df05b96
Download Help Link: https://github.com/Brownserve-UK/Brownserve.PSTools/tree/main/pages/reference/Brownserve.PSTools
Help Version: 0.19.0
Locale: en-US
---

# Brownserve.PSTools Module

## Description

A collection of PowerShell tools used across various Brownserve projects to aid in CI/CD deployments and provide a common, easy-to-maintain codebase.

## Brownserve.PSTools Cmdlets

### [Add-BrownserveChangelogEntry](./Cmdlet reference/Add-BrownserveChangelogEntry.md)

Inserts a new changelog entry into a given changelog file

### [Add-GitChanges](./Cmdlet reference/Add-GitChanges.md)

This cmdlet is a wrapper for the git command 'git add \<path\>'.

### [Add-GitHubReleaseAsset](./Cmdlet reference/Add-GitHubReleaseAsset.md)

Uploads a file to a GitHub release.

### [Add-ModuleHelp](./Cmdlet reference/Add-ModuleHelp.md)

Creates XML MALM help for a PowerShell module

### [Add-PullRequestComment](./Cmdlet reference/Add-PullRequestComment.md)

Adds a comment to a given pull request

### [Assert-Command](./Cmdlet reference/Assert-Command.md)

Ensures the given command exists and is available to the current PowerShell session

### [Assert-Directory](./Cmdlet reference/Assert-Directory.md)

Ensures that a directory is valid

### [Assert-Path](./Cmdlet reference/Assert-Path.md)

Ensures a given path exists.

### [Build-ModuleDocumentation](./Cmdlet reference/Build-ModuleDocumentation.md)

This will build markdown PowerShell module documentation using PlatyPS

### [ConvertTo-BlockComment](./Cmdlet reference/ConvertTo-BlockComment.md)

Converts a given text string into a block comment

### [ConvertTo-HTTPSRepoURL](./Cmdlet reference/ConvertTo-HTTPSRepoURL.md)

Converts a git SSH URI into the HTTPS equivalent

### [ConvertTo-SortedHashtable](./Cmdlet reference/ConvertTo-SortedHashtable.md)

Converts a given hashtable to an alphabetically sorted hashtable

### [Copy-GitRemoteRepository](./Cmdlet reference/Copy-GitRemoteRepository.md)

Clones a given git repository to the local machine

### [Format-BrownserveContent](./Cmdlet reference/Format-BrownserveContent.md)

Formats a given string to be compatible with the various *-BrownserveContent cmdlets.

### [Format-Markdown](./Cmdlet reference/Format-Markdown.md)

Formats a markdown file to ensure it follows the markdownlint rules.

### [Format-NuGetPackageVersion](./Cmdlet reference/Format-NuGetPackageVersion.md)

Formats a version number to ensure compatibility with NuGet and nuget.org

### [Get-BrownserveContent](./Cmdlet reference/Get-BrownserveContent.md)

Wrapper for Get-Content that returns the content in a format that is easier to work with.

### [Get-BrownserveRepositoryPaths](./Cmdlet reference/Get-BrownserveRepositoryPaths.md)

Returns a list of all paths that are managed for a given repository.

### [Get-GitBranches](./Cmdlet reference/Get-GitBranches.md)

Gets the current branches for the given repository

### [Get-GitChanges](./Cmdlet reference/Get-GitChanges.md)

Gets the git status for a given repository

### [Get-GitCurrentBranch](./Cmdlet reference/Get-GitCurrentBranch.md)

Gets the current branch for a given repository

### [Get-GitHubIssues](./Cmdlet reference/Get-GitHubIssues.md)

Gets the issues for a given GitHub repository

### [Get-GitHubPullRequests](./Cmdlet reference/Get-GitHubPullRequests.md)

Gets pull request information from a given GitHub repository.

### [Get-GitHubRelease](./Cmdlet reference/Get-GitHubRelease.md)

Gets a list of releases from a given GitHub repo

### [Get-GitHubTags](./Cmdlet reference/Get-GitHubTags.md)

Gets a list of tags for a given GitHub repository

### [Get-GitMerges](./Cmdlet reference/Get-GitMerges.md)

Returns a list of merge commits for a given GitHub repository

### [Get-GitRemoteOriginURL](./Cmdlet reference/Get-GitRemoteOriginURL.md)

Gets the remote origin URL for a given repository

### [Get-GitRootDirectory](./Cmdlet reference/Get-GitRootDirectory.md)

Returns the root directory of a git repository.

### [Get-Response](./Cmdlet reference/Get-Response.md)

Prompts a user for a response.

### [Get-SPDXLicenseIDs](./Cmdlet reference/Get-SPDXLicenseIDs.md)

Attempts to get the latest SPDX license short ID list.

### [Import-PlatyPSModule](./Cmdlet reference/Import-PlatyPSModule.md)

Imports the PlatyPS module avoiding collisions with other modules.

### [Initialize-BrownserveRepository](./Cmdlet reference/Initialize-BrownserveRepository.md)

Prepares a repository for use for a given project

### [Install-ChocolateyPackage](./Cmdlet reference/Install-ChocolateyPackage.md)

Helper cmdlet for installing Chocolatey packages programmatically

### [Invoke-ConvertFromYaml](./Cmdlet reference/Invoke-ConvertFromYaml.md)

Wrapper cmdlet for ConvertFrom-Yaml

### [Invoke-ConvertToYaml](./Cmdlet reference/Invoke-ConvertToYaml.md)

Wrapper cmdlet for ConvertTo-YAML

### [Invoke-DownloadMethod](./Cmdlet reference/Invoke-DownloadMethod.md)

Downloads a file using the best method available depending on operating system.

### [Invoke-NativeCommand](./Cmdlet reference/Invoke-NativeCommand.md)

Invokes a native command while gracefully handling the output and error streams.

### [Merge-Hashtable](./Cmdlet reference/Merge-Hashtable.md)

Merges two hashtables together

### [New-BrownserveChangelogEntry](./Cmdlet reference/New-BrownserveChangelogEntry.md)

Creates a new changelog entry for a given version in the standard Brownserve format.

### [New-BrownservePowerShellModule](./Cmdlet reference/New-BrownservePowerShellModule.md)

Creates a new PowerShell module in the standard Brownserve format

### [New-BrownservePowerShellModuleBuild](./Cmdlet reference/New-BrownservePowerShellModuleBuild.md)

Adds the various requirements to build a PowerShell module to a given project/repo.

### [New-BrownserveTemporaryDirectory](./Cmdlet reference/New-BrownserveTemporaryDirectory.md)

Creates a temporary directory

### [New-BrownserveTemporaryFile](./Cmdlet reference/New-BrownserveTemporaryFile.md)

Creates a temporary file in a known good location.

### [New-GitBranch](./Cmdlet reference/New-GitBranch.md)

Creates a new branch in a given git repository

### [New-GitHubBranch](./Cmdlet reference/New-GitHubBranch.md)

Creates a new remote branch in a GitHub repository.

### [New-GitHubCommit](./Cmdlet reference/New-GitHubCommit.md)

Creates a commit on a GitHub repository branch via the GitHub API.

### [New-GitHubPullRequest](./Cmdlet reference/New-GitHubPullRequest.md)

Creates a new GitHub pull request

### [New-GitHubRelease](./Cmdlet reference/New-GitHubRelease.md)

Creates a release on GitHub

### [New-SPDXLicense](./Cmdlet reference/New-SPDXLicense.md)

Creates a new licence using the SPDX format

### [Push-GitChanges](./Cmdlet reference/Push-GitChanges.md)

Pushes local git changes to the remote repository.

### [Read-BrownserveChangelog](./Cmdlet reference/Read-BrownserveChangelog.md)

Reads in a changelog file and returns the contents as a custom object.

### [Read-ConfigurationFromFile](./Cmdlet reference/Read-ConfigurationFromFile.md)

Reads values from a configuration file

### [Remove-Markdown](./Cmdlet reference/Remove-Markdown.md)

This cmdlet removes markdown from a string.

### [Select-BrownserveContent](./Cmdlet reference/Select-BrownserveContent.md)

Selects text from a given file

### [Send-BuildNotification](./Cmdlet reference/Send-BuildNotification.md)

Sends a standard Brownserve build notification.

### [Send-SlackNotification](./Cmdlet reference/Send-SlackNotification.md)

Sends a notification to a given Slack webhook

### [Set-BrownserveContent](./Cmdlet reference/Set-BrownserveContent.md)

Writes the contents of a file to disk.

### [Set-LineEndings](./Cmdlet reference/Set-LineEndings.md)

Sets the line endings of a file to either CRLF or LF

### [Split-URI](./Cmdlet reference/Split-URI.md)

Takes a given URI and splits it into its constituent parts.

### [Submit-GitChanges](./Cmdlet reference/Submit-GitChanges.md)

This cmdlet is a wrapper for \<git commit\>.

### [Switch-GitBranch](./Cmdlet reference/Switch-GitBranch.md)

Checks out a given branch.

### [Test-Administrator](./Cmdlet reference/Test-Administrator.md)

A simple function for testing if a user is running with administrator/root privileges or not.

### [Test-Numeric](./Cmdlet reference/Test-Numeric.md)

Tests if a given object is numeric.

### [Test-OperatingSystem](./Cmdlet reference/Test-OperatingSystem.md)

Quick way of terminating scripts when they are running on an incompatible OS.

### [Update-BrownservePowerShellModule](./Cmdlet reference/Update-BrownservePowerShellModule.md)

Updates a given Brownserve PowerShell module to use the latest template.

### [Update-BrownserveRepository](./Cmdlet reference/Update-BrownserveRepository.md)

Updates a given repository to use the latest tooling and settings

### [Update-Version](./Cmdlet reference/Update-Version.md)

A simple function to increment a semantic version number.
