---
Module Name: Brownserve.PSTools
Module Guid: 44b45ef7-6e06-4d07-901a-210b8df05b96
Download Help Link: https://github.com/Brownserve-UK/Brownserve.PSTools/tree/main/pages/reference/Brownserve.PSTools
Help Version: 0.19.2
Locale: en-US
---

# Brownserve.PSTools Module

## Description

A collection of PowerShell tools used across various Brownserve projects to aid in CI/CD deployments and provide a common, easy-to-maintain codebase.

## Brownserve.PSTools Cmdlets

### [Add-BrownserveChangelogEntry](Add-BrownserveChangelogEntry.md)

Inserts a new changelog entry into a given changelog file

### [Add-GitChanges](Add-GitChanges.md)

This cmdlet is a wrapper for the git command 'git add \<path\>'.

### [Add-GitHubReleaseAsset](Add-GitHubReleaseAsset.md)

Uploads a file to a GitHub release.

### [Add-ModuleHelp](Add-ModuleHelp.md)

Creates XML MALM help for a PowerShell module

### [Add-PullRequestComment](Add-PullRequestComment.md)

Adds a comment to a given pull request

### [Assert-Command](Assert-Command.md)

Ensures the given command exists and is available to the current PowerShell session

### [Assert-Directory](Assert-Directory.md)

Ensures that a directory is valid

### [Assert-Path](Assert-Path.md)

Ensures a given path exists.

### [Build-ModuleDocumentation](Build-ModuleDocumentation.md)

This will build markdown PowerShell module documentation using PlatyPS

### [ConvertTo-BlockComment](ConvertTo-BlockComment.md)

Converts a given text string into a block comment

### [ConvertTo-HTTPSRepoURL](ConvertTo-HTTPSRepoURL.md)

Converts a git SSH URI into the HTTPS equivalent

### [ConvertTo-SortedHashtable](ConvertTo-SortedHashtable.md)

Converts a given hashtable to an alphabetically sorted hashtable

### [Copy-GitRemoteRepository](Copy-GitRemoteRepository.md)

Clones a given git repository to the local machine

### [Format-BrownserveContent](Format-BrownserveContent.md)

Formats a given string to be compatible with the various *-BrownserveContent cmdlets.

### [Format-Markdown](Format-Markdown.md)

Formats a markdown file to ensure it follows the markdownlint rules.

### [Format-NuGetPackageVersion](Format-NuGetPackageVersion.md)

Formats a version number to ensure compatibility with NuGet and nuget.org

### [Get-BrownserveContent](Get-BrownserveContent.md)

Wrapper for Get-Content that returns the content in a format that is easier to work with.

### [Get-BrownserveRepositoryPaths](Get-BrownserveRepositoryPaths.md)

Returns a list of all paths that are managed for a given repository.

### [Get-GitBranches](Get-GitBranches.md)

Gets the current branches for the given repository

### [Get-GitChanges](Get-GitChanges.md)

Gets the git status for a given repository

### [Get-GitCurrentBranch](Get-GitCurrentBranch.md)

Gets the current branch for a given repository

### [Get-GitHubIssues](Get-GitHubIssues.md)

Gets the issues for a given GitHub repository

### [Get-GitHubPullRequests](Get-GitHubPullRequests.md)

Gets pull request information from a given GitHub repository.

### [Get-GitHubRelease](Get-GitHubRelease.md)

Gets a list of releases from a given GitHub repo

### [Get-GitHubTags](Get-GitHubTags.md)

Gets a list of tags for a given GitHub repository

### [Get-GitMerges](Get-GitMerges.md)

Returns a list of merge commits for a given GitHub repository

### [Get-GitRemoteOriginURL](Get-GitRemoteOriginURL.md)

Gets the remote origin URL for a given repository

### [Get-GitRootDirectory](Get-GitRootDirectory.md)

Returns the root directory of a git repository.

### [Get-Response](Get-Response.md)

Prompts a user for a response.

### [Get-SPDXLicenseIDs](Get-SPDXLicenseIDs.md)

Attempts to get the latest SPDX license short ID list.

### [Import-PlatyPSModule](Import-PlatyPSModule.md)

Imports the PlatyPS module avoiding collisions with other modules.

### [Initialize-BrownserveRepository](Initialize-BrownserveRepository.md)

Prepares a repository for use for a given project

### [Install-ChocolateyPackage](Install-ChocolateyPackage.md)

Helper cmdlet for installing Chocolatey packages programmatically

### [Invoke-ConvertFromYaml](Invoke-ConvertFromYaml.md)

Wrapper cmdlet for ConvertFrom-Yaml

### [Invoke-ConvertToYaml](Invoke-ConvertToYaml.md)

Wrapper cmdlet for ConvertTo-YAML

### [Invoke-DownloadMethod](Invoke-DownloadMethod.md)

Downloads a file using the best method available depending on operating system.

### [Invoke-NativeCommand](Invoke-NativeCommand.md)

Invokes a native command while gracefully handling the output and error streams.

### [Merge-Hashtable](Merge-Hashtable.md)

Merges two hashtables together

### [New-BrownserveChangelogEntry](New-BrownserveChangelogEntry.md)

Creates a new changelog entry for a given version in the standard Brownserve format.

### [New-BrownservePowerShellModule](New-BrownservePowerShellModule.md)

Creates a new PowerShell module in the standard Brownserve format

### [New-BrownservePowerShellModuleBuild](New-BrownservePowerShellModuleBuild.md)

Adds the various requirements to build a PowerShell module to a given project/repo.

### [New-BrownserveTemporaryDirectory](New-BrownserveTemporaryDirectory.md)

Creates a temporary directory

### [New-BrownserveTemporaryFile](New-BrownserveTemporaryFile.md)

Creates a temporary file in a known good location.

### [New-GitBranch](New-GitBranch.md)

Creates a new branch in a given git repository

### [New-GitHubBranch](New-GitHubBranch.md)

Creates a new remote branch in a GitHub repository.

### [New-GitHubCommit](New-GitHubCommit.md)

Creates a commit on a GitHub repository branch via the GitHub API.

### [New-GitHubPullRequest](New-GitHubPullRequest.md)

Creates a new GitHub pull request

### [New-GitHubRelease](New-GitHubRelease.md)

Creates a release on GitHub

### [New-SPDXLicense](New-SPDXLicense.md)

Creates a new licence using the SPDX format

### [Push-GitChanges](Push-GitChanges.md)

Pushes local git changes to the remote repository.

### [Read-BrownserveChangelog](Read-BrownserveChangelog.md)

Reads in a changelog file and returns the contents as a custom object.

### [Read-ConfigurationFromFile](Read-ConfigurationFromFile.md)

Reads values from a configuration file

### [Remove-Markdown](Remove-Markdown.md)

This cmdlet removes markdown from a string.

### [Select-BrownserveContent](Select-BrownserveContent.md)

Selects text from a given file

### [Send-BuildNotification](Send-BuildNotification.md)

Sends a standard Brownserve build notification.

### [Send-SlackNotification](Send-SlackNotification.md)

Sends a notification to a given Slack webhook

### [Set-BrownserveContent](Set-BrownserveContent.md)

Writes the contents of a file to disk.

### [Set-LineEndings](Set-LineEndings.md)

Sets the line endings of a file to either CRLF or LF

### [Split-URI](Split-URI.md)

Takes a given URI and splits it into its constituent parts.

### [Submit-GitChanges](Submit-GitChanges.md)

This cmdlet is a wrapper for \<git commit\>.

### [Switch-GitBranch](Switch-GitBranch.md)

Checks out a given branch.

### [Test-Administrator](Test-Administrator.md)

A simple function for testing if a user is running with administrator/root privileges or not.

### [Test-Numeric](Test-Numeric.md)

Tests if a given object is numeric.

### [Test-OperatingSystem](Test-OperatingSystem.md)

Quick way of terminating scripts when they are running on an incompatible OS.

### [Update-BrownservePowerShellModule](Update-BrownservePowerShellModule.md)

Updates a given Brownserve PowerShell module to use the latest template.

### [Update-BrownserveRepository](Update-BrownserveRepository.md)

Updates a given repository to use the latest tooling and settings

### [Update-Version](Update-Version.md)

A simple function to increment a semantic version number.
