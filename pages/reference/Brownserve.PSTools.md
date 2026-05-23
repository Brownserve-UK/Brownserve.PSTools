---
Module Name: Brownserve.PSTools
Module Guid: 44b45ef7-6e06-4d07-901a-210b8df05b96
Download Help Link: https://github.com/Brownserve-UK/Brownserve.PSTools/tree/main/pages/reference/Brownserve.PSTools
Help Version: 0.19.1
Locale: en-US
---

# Brownserve.PSTools Module

## Description

A collection of PowerShell tools used across various Brownserve projects to aid in CI/CD deployments and provide a common, easy-to-maintain codebase.

## Brownserve.PSTools Cmdlets

### [Add-BrownserveChangelogEntry](./Brownserve.PSTools/Add-BrownserveChangelogEntry.md)

Inserts a new changelog entry into a given changelog file

### [Add-GitChanges](./Brownserve.PSTools/Add-GitChanges.md)

This cmdlet is a wrapper for the git command 'git add \<path\>'.

### [Add-GitHubReleaseAsset](./Brownserve.PSTools/Add-GitHubReleaseAsset.md)

Uploads a file to a GitHub release.

### [Add-ModuleHelp](./Brownserve.PSTools/Add-ModuleHelp.md)

Creates XML MALM help for a PowerShell module

### [Add-PullRequestComment](./Brownserve.PSTools/Add-PullRequestComment.md)

Adds a comment to a given pull request

### [Assert-Command](./Brownserve.PSTools/Assert-Command.md)

Ensures the given command exists and is available to the current PowerShell session

### [Assert-Directory](./Brownserve.PSTools/Assert-Directory.md)

Ensures that a directory is valid

### [Assert-Path](./Brownserve.PSTools/Assert-Path.md)

Ensures a given path exists.

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

### [Format-BrownserveContent](./Brownserve.PSTools/Format-BrownserveContent.md)

Formats a given string to be compatible with the various *-BrownserveContent cmdlets.

### [Format-Markdown](./Brownserve.PSTools/Format-Markdown.md)

Formats a markdown file to ensure it follows the markdownlint rules.

### [Format-NuGetPackageVersion](./Brownserve.PSTools/Format-NuGetPackageVersion.md)

Formats a version number to ensure compatibility with NuGet and nuget.org

### [Get-BrownserveContent](./Brownserve.PSTools/Get-BrownserveContent.md)

Wrapper for Get-Content that returns the content in a format that is easier to work with.

### [Get-BrownserveRepositoryPaths](./Brownserve.PSTools/Get-BrownserveRepositoryPaths.md)

Returns a list of all paths that are managed for a given repository.

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

### [Get-GitRootDirectory](./Brownserve.PSTools/Get-GitRootDirectory.md)

Returns the root directory of a git repository.

### [Get-Response](./Brownserve.PSTools/Get-Response.md)

Prompts a user for a response.

### [Get-SPDXLicenseIDs](./Brownserve.PSTools/Get-SPDXLicenseIDs.md)

Attempts to get the latest SPDX license short ID list.

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

### [Merge-Hashtable](./Brownserve.PSTools/Merge-Hashtable.md)

Merges two hashtables together

### [New-BrownserveChangelogEntry](./Brownserve.PSTools/New-BrownserveChangelogEntry.md)

Creates a new changelog entry for a given version in the standard Brownserve format.

### [New-BrownservePowerShellModule](./Brownserve.PSTools/New-BrownservePowerShellModule.md)

Creates a new PowerShell module in the standard Brownserve format

### [New-BrownservePowerShellModuleBuild](./Brownserve.PSTools/New-BrownservePowerShellModuleBuild.md)

Adds the various requirements to build a PowerShell module to a given project/repo.

### [New-BrownserveTemporaryDirectory](./Brownserve.PSTools/New-BrownserveTemporaryDirectory.md)

Creates a temporary directory

### [New-BrownserveTemporaryFile](./Brownserve.PSTools/New-BrownserveTemporaryFile.md)

Creates a temporary file in a known good location.

### [New-GitBranch](./Brownserve.PSTools/New-GitBranch.md)

Creates a new branch in a given git repository

### [New-GitHubBranch](./Brownserve.PSTools/New-GitHubBranch.md)

Creates a new remote branch in a GitHub repository.

### [New-GitHubCommit](./Brownserve.PSTools/New-GitHubCommit.md)

Creates a commit on a GitHub repository branch via the GitHub API.

### [New-GitHubPullRequest](./Brownserve.PSTools/New-GitHubPullRequest.md)

Creates a new GitHub pull request

### [New-GitHubRelease](./Brownserve.PSTools/New-GitHubRelease.md)

Creates a release on GitHub

### [New-SPDXLicense](./Brownserve.PSTools/New-SPDXLicense.md)

Creates a new licence using the SPDX format

### [Push-GitChanges](./Brownserve.PSTools/Push-GitChanges.md)

Pushes local git changes to the remote repository.

### [Read-BrownserveChangelog](./Brownserve.PSTools/Read-BrownserveChangelog.md)

Reads in a changelog file and returns the contents as a custom object.

### [Read-ConfigurationFromFile](./Brownserve.PSTools/Read-ConfigurationFromFile.md)

Reads values from a configuration file

### [Remove-Markdown](./Brownserve.PSTools/Remove-Markdown.md)

This cmdlet removes markdown from a string.

### [Select-BrownserveContent](./Brownserve.PSTools/Select-BrownserveContent.md)

Selects text from a given file

### [Send-BuildNotification](./Brownserve.PSTools/Send-BuildNotification.md)

Sends a standard Brownserve build notification.

### [Send-SlackNotification](./Brownserve.PSTools/Send-SlackNotification.md)

Sends a notification to a given Slack webhook

### [Set-BrownserveContent](./Brownserve.PSTools/Set-BrownserveContent.md)

Writes the contents of a file to disk.

### [Set-LineEndings](./Brownserve.PSTools/Set-LineEndings.md)

Sets the line endings of a file to either CRLF or LF

### [Split-URI](./Brownserve.PSTools/Split-URI.md)

Takes a given URI and splits it into its constituent parts.

### [Submit-GitChanges](./Brownserve.PSTools/Submit-GitChanges.md)

This cmdlet is a wrapper for \<git commit\>.

### [Switch-GitBranch](./Brownserve.PSTools/Switch-GitBranch.md)

Checks out a given branch.

### [Test-Administrator](./Brownserve.PSTools/Test-Administrator.md)

A simple function for testing if a user is running with administrator/root privileges or not.

### [Test-Numeric](./Brownserve.PSTools/Test-Numeric.md)

Tests if a given object is numeric.

### [Test-OperatingSystem](./Brownserve.PSTools/Test-OperatingSystem.md)

Quick way of terminating scripts when they are running on an incompatible OS.

### [Update-BrownservePowerShellModule](./Brownserve.PSTools/Update-BrownservePowerShellModule.md)

Updates a given Brownserve PowerShell module to use the latest template.

### [Update-BrownserveRepository](./Brownserve.PSTools/Update-BrownserveRepository.md)

Updates a given repository to use the latest tooling and settings

### [Update-Version](./Brownserve.PSTools/Update-Version.md)

A simple function to increment a semantic version number.
