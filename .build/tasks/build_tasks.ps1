<#
.SYNOPSIS
    This contains the build tasks for Invoke-Build to use
#>
[CmdletBinding()]
param
(
    # The name of the PowerShell module being built
    [Parameter(
        Mandatory = $true
    )]
    [string]
    $ModuleName,

    # The GUID of the module
    [Parameter(
        Mandatory = $true
    )]
    [guid]
    $ModuleGUID,

    # The description of the module
    [Parameter(
        Mandatory = $true
    )]
    [string]
    $ModuleDescription,

    # The author of the module
    [Parameter(
        Mandatory = $False
    )]
    [string]
    $ModuleAuthor = 'Brownserve UK',

    # Any tags to add to the module
    [Parameter(Mandatory = $false)]
    [string[]]
    $ModuleTags = 'brownserve-UK',

    # The type of changes that this version of the module contains
    # this is used to determine the version number
    [Parameter(
        Mandatory = $false
    )]
    [ValidateSet(
        'major',
        'minor',
        'patch',
        'republish'
    )]
    [string]
    $ReleaseType,

    # The branch this is being built from
    [Parameter(
        Mandatory = $true
    )]
    [string]
    $BranchName,

    # The default branch for this repository
    [Parameter(
        Mandatory = $true
    )]
    [string]
    $DefaultBranch,

    # The Nuget feeds to publish to
    [Parameter(
        Mandatory = $False
    )]
    [ValidateNotNullOrEmpty()]
    [ValidateSet('nuget', 'PSGallery', 'GitHub')]
    [string[]]
    $PublishTo,

    # The GitHub organisation/account to publish the release to
    [Parameter(
        Mandatory = $true
    )]
    [ValidateNotNullOrEmpty()]
    [string]
    $GitHubRepoOwner,

    # The GitHub repo to publish the release to and used to fill in release details for Nuget/PSGallery
    [Parameter(
        Mandatory = $true
    )]
    [ValidateNotNullOrEmpty()]
    [string]
    $GitHubRepoName,

    # The PAT for pushing to GitHub
    [Parameter(
        Mandatory = $False
    )]
    [ValidateNotNullOrEmpty()]
    [string]
    $GitHubPAT,

    # The API key to use when publishing to a NuGet feed
    [Parameter(
        Mandatory = $False
    )]
    [string] $NugetFeedApiKey,

    # The API key to use when publishing to the PSGallery
    [Parameter(
        Mandatory = $False
    )]
    [string]
    $PSGalleryAPIKey,

    # If set will load the working copy of the module at the start of the build
    [Parameter(
        Mandatory = $false
    )]
    [switch]
    $UseWorkingCopy
)
# Set up a bunch of variables that we'll use through the build, some of these are global as they're used in our tests too
$global:BrownserveBuiltModuleDirectory = Join-Path $global:BrownserveRepoBuildOutputDirectory $ModuleName
# Depending on how we got the branch name we may need to remove the full ref
$BranchName = $BranchName -replace 'refs\/heads\/', ''
$script:CurrentCommitHash = & git rev-parse HEAD
$script:ChangelogPath = Join-Path $Global:BrownserveRepoRootDirectory -ChildPath 'test-changelog.md' # TODO: replace this with the real changelog path
$script:NugetPackageDirectory = Join-Path $global:BrownserveRepoBuildOutputDirectory 'NuGetPackage'
$script:NuspecPath = Join-Path $script:NugetPackageDirectory "$ModuleName.nuspec"
$script:GitHubRepoURI = "https://github.com/$GitHubRepoOwner/$GitHubRepoName"
$Script:BuiltModulePath = (Join-Path $global:BrownserveBuiltModuleDirectory -ChildPath "$ModuleName.psd1")
$script:TrackedFiles = @()
$script:LineEndingFiles = @()

<#
    Work out if this is a production release depending on the branch we're building from
    We default to $true unless we detect that we're running on the default branch, as anything that is in the default
    branch should be the one to build shipped versions of the code.
    This should ensure that:
        * Main can never be used a prerelease tag
        * Feature branches cannot ever create a production release
#>
$PreRelease = $true
if ($DefaultBranch -eq $BranchName)
{
    $PreRelease = $false
}

# On non-windows platforms mono is required to run NuGet 🤢
$NugetCommand = 'nuget'
if (-not $isWindows)
{
    Write-Verbose 'Running on linux, will use mono when running nuget'
    $NugetCommand = 'mono'
}

# BuildTask is a variable that is set by Invoke-Build to indicate the build task that has been called
# it might be useful to have specific logic for certain tasks
switch ($BuildTask)
{
    default {}
}

<#
.SYNOPSIS
    Checks that all the required parameters have been provided to publish a release
#>
task CheckPublishingParameters {
    if ('PSGallery' -in $PublishTo)
    {
        if (!$PSGalleryAPIKey)
        {
            throw 'PSGalleryAPIKey not provided'
        }
    }

    if ('nuget' -in $PublishTo)
    {
        if (!$NugetFeedApiKey)
        {
            throw 'NugetFeedApiKey not provided'
        }
    }

    if ('GitHub' -in $PublishTo)
    {
        if (!$GitHubPAT)
        {
            throw 'GitHub PAT not provided'
        }
    }
}

<#
.SYNOPSIS
    Loads the working copy of the module from the module directory
.DESCRIPTION
    By default we pull in the latest _stable_ copy of Brownserve.PSTools via the _init.ps1 script to run this build,
    however if we make changes to any of the cmdlets used in this build we won't get the changes until a new release
    is pushed.
    This task allows us to unload the stable version and reload the copy of this module from the repo's module directory.
#>
task UseWorkingCopy {
    if ($UseWorkingCopy -eq $true)
    {
        Write-Verbose "Loading working copy of module from $Global:BrownserveModuleDirectory"
        if ((Get-Module $ModuleName))
        {
            Write-Warning "The current version of $ModuleName has been unloaded and replaced with the working copy from $Global:BrownserveModuleDirectory. `nFunctionality may be unstable"
            Remove-Module $ModuleName -Force -ErrorAction 'Stop' -Verbose:$false
        }
        Import-Module (Join-Path $Global:BrownserveModuleDirectory 'Brownserve.PSTools.psm1') -Force -ErrorAction 'Stop' -Verbose:$false
    }
}

<#
.SYNOPSIS
    Reads information about the current release from the changelog
.DESCRIPTION
    This task will read the changelog and extract the version history.
    When staging a release this will be used to determine what the next version number should be.
    When performing a release this will be used to set the release notes and version for the release.
#>
task GetReleaseHistory {
    Write-Verbose 'Getting release history'
    # Store the changelog object - we'll use it when updating the changelog later on
    $script:Changelog = Read-BrownserveChangelog `
        -ChangelogPath $script:ChangelogPath
    <#
        There may be times where our last release was a pre-release but we don't want to select this as our "latest" version.
        For example, say 1.0.0 is our current stable version, but we last released 2.0.0-rc1 so it's at the top of our changelog.
        If we select 2.0.0-rc1 then when we try to promote 2.0.0 to a stable release the version number would get incremented.
        automatically as part of the build (so for example 2.0.0-rc1 -> 2.0.1)
        Also if we had to do an emergency release of the latest stable version (e.g 1.0.0 -> 1.1.0) to patch a security
        issue then we wouldn't want to select our 2.0.0-rc1 pre-release version to base the new patch release off of.
        Therefore we select the last "stable" release which should always be what we want to work with
    #>
    $script:LastRelease = $script:Changelog.VersionHistory |
        Where-Object { $_.PreRelease -eq $false } |
            Select-Object -First 1
}
<#
.SYNOPSIS
    Sets the correct version number for a release
.DESCRIPTION
    This is done by looking at the last release and determining the next version number based on the type of release
    we're doing.
    We use the changelog as that _should_ be the greatest source of truth for determining the currently released version.
    There are some fail-safes later on in the build to ensure we don't accidentally release a version that already exists.
#>
task SetVersion GetReleaseHistory, {
    Write-Verbose 'Setting version information'
    $CurrentVersion = $script:LastRelease |
        Select-Object -ExpandProperty Version
    if (!$CurrentVersion)
    {
        throw 'Unable to determine current version from changelog'
    }
    <#
        Occasionally we may want to republish a version that we've already released.
        For example if we add another release endpoint or if we failed to release to one of our current endpoints 
        due to an api key issue etc.
    #>
    if ($ReleaseType -eq 'republish')
    {
        Write-Verbose "Republishing $CurrentVersion"
        $script:NewVersion = $CurrentVersion
    }
    else
    {
        $UpdateVersionParams = @{
            Version     = $CurrentVersion
            ReleaseType = $ReleaseType
        }
        if ($PreRelease)
        {
            $UpdateVersionParams.Add('PreReleaseString', $BranchName)
        }
        # TODO: Add build number support
        $script:NewVersion = Update-Version @UpdateVersionParams -ErrorAction 'Stop'
    }
    <#
        NuGet has a very specific version format that we need to adhere to.
    #>
    $NugetPackageVersionParams = @{
        Version         = $script:NewVersion
        # We use SemVer 1.0.0 as while NuGet has supported SemVer 2.0.0 since 4.3.0 we want to ensure we're compatible with older versions (for now)
        SemanticVersion = '1.0.0'
    }
    $NugetPackageVersion = Format-NuGetPackageVersion @NugetPackageVersionParams
    <#
        We use the NugetPackageVersion for our release version as currently this is the most restrictive in terms
        of supported format.
        This should mean everything stays consistent.
    #>
    $global:VersionToRelease = $NugetPackageVersion
    # For GitHub releases and the changelog we prefix the version with a 'v'
    $script:PrefixedVersion = "v$($global:VersionToRelease)"
    Write-Debug @"
Version Information:
    CurrentVersion: $CurrentVersion
    NewVersion: $script:NewVersion
    NugetPackageVersion: $NugetPackageVersion
    VersionToRelease: $global:VersionToRelease
"@
}

<#
.SYNOPSIS
    Creates a new changelog entry.
.DESCRIPTION
    This task creates a new changelog entry for the current release.
    It will check for:
        * Merged PRs since the last release
        * Issues closed since the last release
        * Issues opened since the last release
#>
task CreateChangelogEntry SetVersion, {
    Write-Verbose "Creating new changelog entry for $script:NewVersion"
    $NewChangelogEntryParams = @{
        Version         = $script:NewVersion
        RepositoryOwner = $GitHubRepoOwner
        RepositoryName  = $GitHubRepoName
        Changelog       = $script:Changelog
    }
    if ($GitHubPAT)
    {
        $NewChangelogEntryParams.Add('Auto', $true)
        $NewChangelogEntryParams.Add('GitHubToken', $GitHubPAT)
    }
    else
    {
        # TODO: in future it might be nice to have a provision for providing manual release notes
        throw 'GitHub token not provided, cannot generate release notes'
    }
    try
    {
        $script:NewReleaseNotes = New-BrownserveChangelogEntry @NewChangelogEntryParams
    }
    catch
    {
        throw "Failed to update changelog. `n$($_.Exception.Message)"
    }
}

<#
.SYNOPSIS
    Updates the changelog with the new release notes.
.DESCRIPTION
    This task should only be run as part of the StageRelease task.
#>
task UpdateChangelog CreateChangelogEntry, {
    Write-Verbose 'Updating changelog'
    try
    {
        $script:Changelog | Add-BrownserveChangelogEntry `
            -NewContent $script:NewReleaseNotes `
            -ErrorAction 'Stop'
    }
    catch
    {
        throw "Failed to update changelog. `n$($_.Exception.Message)"
    }
    $script:LineEndingFiles += $script:ChangelogPath
    $script:TrackedFiles += ($script:ChangelogPath | Convert-Path)
}

<#
.SYNOPSIS
    Removes characters from the release notes that may make things sad
.DESCRIPTION
    A previous run of the StageRelease task will have generated the release notes and stored them in the changelog which
    we will have read in to the $script:LastRelease.ReleaseNotes variable at the beginning of the build.
    This task will remove any characters that may cause issues when we try to use the release notes in our NuGet package.
#>
task FormatReleaseNotes SetVersion, {
    Write-Verbose 'Formatting release notes.'
    $script:ReleaseNotes = $script:LastRelease.ReleaseNotes
    if (!$script:ReleaseNotes)
    {
        throw 'Release notes missing'
    }
    try
    {
        # $script:CleanReleaseNotes = Remove-Markdown -String $script:ReleaseNotes -ErrorAction 'Stop'
        $script:CleanReleaseNotes = $script:ReleaseNotes | Out-String # TODO: restore this in future
    }
    catch
    {
        throw "Failed to remove markdown from release notes. `n$($_.Exception.Message)"
    }
    # Filter out characters that'll break the XML and/or just generally look horrible in NuGet
    $script:CleanReleaseNotes = $script:CleanReleaseNotes -replace '"', '\"' -replace '`', '' -replace '\*', ''
    Write-Verbose "Release notes for $global:VersionToRelease:`n$script:CleanReleaseNotes"
}

<#
.SYNOPSIS
    Checks for previous releases to ensure we're not trying to release a version that already exists
.DESCRIPTION
    This task will check for previous releases in GitHub, the PSGallery and NuGet.
    If a release is found with the same version number as the one we're trying to release then the build will fail.
    Even if only one of the endpoints has a release with the same version number the build will fail.
    We should be consistent across all endpoints.
#>
task CheckPreviousReleases SetVersion, {
    Write-Verbose 'Checking for previous releases'
    if ('GitHub' -in $PublishTo)
    {
        Write-Verbose 'Checking for previous releases in GitHub'
        $CurrentReleases = Get-GitHubRelease `
            -GitHubToken $GitHubPAT `
            -RepoName $GitHubRepoName `
            -GitHubOrg $GitHubRepoOwner
        if ($CurrentReleases.tag_name -contains "$script:PrefixedVersion")
        {
            throw "There already appears to be a $script:PrefixedVersion release!"
        }
    }
    if ('PSGallery' -in $PublishTo)
    {
        Write-Verbose 'Checking for previous releases to PSGallery'
        $CurrentReleases = Find-Module `
            -Name $ModuleName `
            -Repository PSGallery `
            -AllVersions `
            -AllowPrerelease `
            -ErrorAction SilentlyContinue # We don't care if this fails, we'll just assume there's no previous release
        if ($CurrentReleases.Version -contains $global:VersionToRelease)
        {
            throw "There already appears to be a $global:VersionToRelease release!"
        }
    }
    if ('nuget' -in $PublishTo)
    {
        Write-Verbose 'Checking for previous releases to NuGet'
        $CurrentReleases = Find-Package `
            -Name $ModuleName `
            -Source 'https://nuget.org/api/v2' `
            -AllVersions `
            -AllowPrereleaseVersions `
            -ErrorAction SilentlyContinue # We don't care if this fails, we'll just assume there's no previous release
        if ($CurrentReleases.Version -contains $global:VersionToRelease)
        {
            throw "There already appears to be a $global:VersionToRelease release!"
        }
    }
}

# Synopsis: Copies over all the necessary files to be packaged for a release
task CopyModule {
    Write-Verbose 'Copying files to build output directory'
    # Copy the "Module" directory over to the build output directory
    Copy-Item -Path $Global:BrownserveModuleDirectory -Destination $global:BrownserveBuiltModuleDirectory -Recurse -Force
}

# Synopsis: Generates the module manifest
task CreateModuleManifest SetVersion, FormatReleaseNotes, CopyModule, {
    Write-Verbose 'Creating PowerShell module manifest'
    # Get a list of Public cmdlets so we can mark them for export.
    $PublicScripts = Get-ChildItem (Join-Path $global:BrownserveBuiltModuleDirectory 'Public') -Filter '*.ps1' -Recurse
    $PublicFunctions = $PublicScripts | ForEach-Object {
        $_.Name -replace '.ps1', ''
    }
    $ModuleManifest = @{
        Path              = $Script:BuiltModulePath
        Guid              = $ModuleGUID
        Author            = $ModuleAuthor
        Copyright         = "$(Get-Date -Format yyyy) $ModuleAuthor"
        CompanyName       = 'Brownserve UK'
        RootModule        = "$ModuleName.psm1"
        ModuleVersion     = $script:NewVersion
        Description       = $ModuleDescription
        PowerShellVersion = '6.0'
        ReleaseNotes      = $script:CleanReleaseNotes
        LicenseUri        = "$script:GitHubRepoURI/blob/main/LICENSE"
        ProjectUri        = "$script:GitHubRepoURI"
        FunctionsToExport = $PublicFunctions
    }
    if ($ModuleTags)
    {
        $ModuleManifest.add('Tags', $ModuleTags)
    }
    # If this is not a production release then update the fields accordingly
    if ($PreRelease -eq $true)
    {
        $ModuleManifest.add('Prerelease', (([semver]$global:VersionToRelease).PreReleaseLabel))
    }
    New-ModuleManifest @ModuleManifest -ErrorAction 'Stop'
}

<#
.SYNOPSIS
    Now we've built the module we need to import the freshly built version before we can test it.
#>
task ImportModule CreateModuleManifest, {
    Write-Verbose 'Importing built module'
    if ((Get-Module $ModuleName))
    {
        $WarningMessage = @"
The PowerShell module '$ModuleName' has been reloaded using the version built by this script.
This may mean that functionality has changed.
You may wish to run _init.ps1 again to reload the current stable version of this module.
"@
        Write-Warning $WarningMessage
        Remove-Module $ModuleName -Force -Confirm:$false -Verbose:$false
    }
    Import-Module $Script:BuiltModulePath -Force -Verbose:$false
}

<#
.SYNOPSIS
    Uses PlatyPS to generate the markdown documentation for the module
.DESCRIPTION
    We store our modules help information in markdown files in the docs directory of the repo.
    This task will generate those docs using PlatyPS.
#>
task UpdateModuleDocumentation ImportModule, {
    Write-Verbose 'Updating markdown documentation'
    $DocsParams = @{
        ModuleName        = $ModuleName
        ModulePath        = $Script:BuiltModulePath
        DocumentationPath = $Global:BrownserveRepoDocsDirectory
        ModuleGUID        = $ModuleGUID
    }
    Build-ModuleDocumentation @DocsParams | Out-Null
    <#
        Store this in a script variable as we'll potentially use it later on.
        We do this _after_ we've generated the docs as the module page might not exist before which will cause
        Resolve-Path to fail.
    #>
    $Script:ModulePagePath = Join-Path $Global:BrownserveRepoDocsDirectory 'Brownserve.PSTools.md' | Resolve-Path
    $script:LineEndingFiles += (Get-ChildItem `
            -Path (Join-Path $Global:BrownserveRepoDocsDirectory -ChildPath 'Brownserve.PSTools')  `
            -Filter *.md `
            -Recurse | Select-Object -ExpandProperty 'FullName')
    $script:LineEndingFiles += (Get-Item -Path $Script:ModulePagePath)
}

<#
.SYNOPSIS
    Update the module page help version to match the version we're releasing
.DESCRIPTION
    This task should only be run as part of the StageRelease task.
#>
task UpdateModulePageHelpVersion SetVersion, UpdateModuleDocumentation, {
    Write-Verbose 'Updating module page help version'
    Update-PlatyPSModulePageHelpVersion `
        -HelpVersion $global:VersionToRelease `
        -ModulePagePath $Script:ModulePagePath `
        -ErrorAction 'Stop'
    $script:TrackedFiles += $Script:ModulePagePath
}

<#
.SYNOPSIS
    Updates the modules MALM help
.DESCRIPTION
    PlatyPS will read in the markdown files in the docs directory and generate a MALM help file for the module.
    This needs to be shipped with the module so that PowerShell can display help for the module, therefore we copy it
    over to the built module directory.
#>
task CreateModuleHelp UpdateModuleDocumentation, {
    Write-Verbose 'Updating module help'
    New-Item (Join-Path $global:BrownserveBuiltModuleDirectory 'en-US') -ItemType Directory | Out-Null
    $HelpParams = @{
        ModuleDirectory   = $global:BrownserveBuiltModuleDirectory
        DocumentationPath = (Join-Path $global:BrownserveRepoDocsDirectory 'Brownserve.PSTools')
    }
    Add-ModuleHelp @HelpParams | Out-Null
}

<#
.SYNOPSIS
    Ensures line endings for tracked files are set to 'LF'
.DESCRIPTION
    PowerShell seems to insist on doing inconsistent things with line endings when running on different OSes.
    This results in constant line ending change diffs in git which fails the build.
    Therefore some files that are created as part of the build need to have their line endings set to 'LF' to ensure
    consistency.

    This task has no dependencies as it should be run after all other tasks that may modify tracked files so be
    careful with where you place it in the build.
#>
task SetLineEndings {
    if ($script:LineEndingFiles.Count -gt 0)
    {
        Write-Verbose 'Ensuring line endings are consistent'
        Set-LineEndings `
            -Path $script:LineEndingFiles `
            -LineEnding 'LF' `
            -ErrorAction 'Stop'
    }
    else
    {
        Write-Warning 'No tracked files were specified for line ending checks'
    }
}

<#
.SYNOPSIS
    Creates a new branch for staging the release
.DESCRIPTION
    Before we perform a release we need to ensure the changelog and help files are updated.
    As we can't push to the main branch we need to create a new branch to stage the release and submit a PR.
    This is helpful as we can review everything before we actually release it.
    The branch name is determined by the version number.
    For example if we're releasing version 1.0.0 then the branch name will be 'release/1.0.0'
#>
task CreateStagingBranch SetVersion, {
    $Script:StagingBranchName = "release/$script:PrefixedVersion"
    Write-Verbose "Creating branch: $Script:StagingBranchName"
    try
    {
        New-GitBranch `
            -RepositoryPath $Global:BrownserveRepoRootDirectory `
            -BranchName $Script:StagingBranchName `
            -Checkout $true `
            -ErrorAction 'Stop'
    }
    catch
    {
        throw "Failed to create git branch $Blah.`n$($_.Exception.Message)"
    }
}

<#
.SYNOPSIS
    Commits any (expected) changes made during the build
.DESCRIPTION
    Sometimes we expect some files to get modified during certain builds.
    For example when we update the changelog or module documentation before a release.
    We want to commit those changes so they get included in the release. (and don't fail the build later on)
#>
task CommitTrackedChanges UpdateChangelog, UpdateModuleDocumentation, CreateStagingBranch, SetLineEndings, {
    $CommitMessage = "auto: Prepare for $script:PrefixedVersion`n`nThis commit was automatically generated."
    if ($script:TrackedFiles.Count -gt 0)
    {
        Write-Verbose 'Committing tracked changes'
        try
        {
            $script:TrackedFiles | Add-GitChanges -RepositoryPath $Global:BrownserveRepoRootDirectory
            Submit-GitChanges `
                -RepositoryPath $Global:BrownserveRepoRootDirectory `
                -Message $CommitMessage
        }
        catch
        {
            throw $_.Exception.Message
        }
    }
    else
    {
        Write-Verbose 'No tracked files to commit.'
    }
}

<#
.SYNOPSIS
    Pushes the current branch to the remote repository
#>
task PushBranch CreateStagingBranch, CommitTrackedChanges, {
    Write-Verbose 'Pushing branch to remote repository'
    try
    {
        Push-GitChanges `
            -BranchName $script:StagingBranchName `
            -RepositoryPath $Global:BrownserveRepoRootDirectory `
            -ErrorAction 'Stop'
    }
    catch
    {
        throw "Failed to push branch to remote repository.`n$($_.Exception.Message)"
    }
}

<#
.Synopsis
    Checks for uncommitted changes and fails the build if any are found
.DESCRIPTION
    This check is especially handy for catching any documentation changes that may have been made during but not committed.
#>
task CheckForUncommittedChanges UpdateModuleDocumentation, UpdateChangelog, SetLineEndings, CommitTrackedChanges, {
    Write-Verbose 'Checking for uncommitted changes'
    $Status = Get-GitChanges
    if ($Status)
    {
        throw "The build has resulted in uncommitted changes being produced: `n$($Status.Source -join "`n")"
    }
}

<#
.SYNOPSIS
    Creates a PR for merging the staging release branch into the default branch
#>
task CreatePullRequest PushBranch, CheckForUncommittedChanges, {
    Write-Verbose 'Creating pull request'
    try
    {
        $Body = @'
This PR was automatically generated.
Please review the changes and merge if they look good.
'@
        $PullRequestParams = @{
            BaseBranch      = $DefaultBranch
            HeadBranch      = $script:StagingBranchName
            Title           = "Prepare for $script:PrefixedVersion"
            Body            = $Body
            GitHubToken     = $GitHubPAT
            RepositoryName  = $GitHubRepoName
            RepositoryOwner = $GitHubRepoOwner
        }
        $PRDetails = New-GitHubPullRequest @PullRequestParams
        Write-Verbose "Pull request created: $($PRDetails.html_url)"
    }
    catch
    {
        throw "Failed to create pull request.`n$($_.Exception.Message)"
    }
}

<#
.SYNOPSIS
    Performs tests on the module
.DESCRIPTION
    We use Pester to perform unit testing on the module.
    This task will run all the tests in the "tests" directory and fail the build if any of them fail.
#>
task Tests ImportModule, UpdateModuleDocumentation, {
    Write-Verbose 'Performing unit testing, this may take a while...'
    $Results = Invoke-Pester -Path $Global:BrownserveRepoTestsDirectory -PassThru
    assert ($results.FailedCount -eq 0) "$($results.FailedCount) test(s) failed."
}

<#
.SYNOPSIS
    Creates a NuGet package for the module
#>
task PrepareNuGetPackage SetVersion, CreateModuleManifest, FormatReleaseNotes, CreateModuleHelp, {
    if ('nuget' -in $PublishTo)
    {
        # We'll copy our build module to the nuget package and rename it to 'tools'
        Write-Verbose "Copying built module to $script:NugetPackageDirectory"
        Copy-Item $global:BrownserveBuiltModuleDirectory -Destination (Join-Path $script:NugetPackageDirectory 'tools') -Recurse
        # Copy each of the necessary files over to the build output directory
        $ItemsToCopy = @(
        (Join-Path $Global:BrownserveRepoRootDirectory 'CHANGELOG.md'),
        (Join-Path $Global:BrownserveRepoRootDirectory 'LICENSE'),
        (Join-Path $Global:BrownserveRepoRootDirectory README.md)
        )
        Copy-Item $ItemsToCopy -Destination $script:NugetPackageDirectory -Force
        # Now we'll generate a nuspec file and pop it in the root of NuGet package
        Write-Verbose 'Creating nuspec file'
        $Nuspec = @"
<?xml version="1.0" encoding="utf-8"?>
<package xmlns="http://schemas.microsoft.com/packaging/2011/08/nuspec.xsd">
  <metadata>
    <id>$ModuleName</id>
    <version>$global:VersionToRelease</version>
    <authors>$ModuleAuthor</authors>
    <owners>Brownserve UK</owners>
    <requireLicenseAcceptance>false</requireLicenseAcceptance>
    <summary>$ModuleDescription</summary>
    <description>$ModuleDescription</description>
    <projectUrl>$script:GitHubRepoURI</projectUrl>
    <releaseNotes>$script:CleanReleaseNotes</releaseNotes>
    <readme>README.md</readme>
    <copyright>Copyright $(Get-Date -Format yyyy) Brownserve UK.</copyright>
    <tags>$($ModuleTags -join ' ')</tags>
    <dependencies />
  </metadata>
</package>
"@
        New-Item $script:NuspecPath -Value $Nuspec -Force | Out-Null
        $script:NuspecPath = $script:NuspecPath | Convert-Path
    }
    else
    {
        Write-Verbose 'Nuget not targeted, skipping...'
    }
}

# Synopsis: Packs the nuget package ready for shipping off to nuget.org (or a private feed)
task PackNuGetPackage PrepareNuGetPackage, {
    if ('nuget' -in $PublishTo)
    {
        Write-Verbose 'Creating NuGet package'
        exec {
            # Note: the paths must be a separate index to the switch in the array
            $NugetArguments = @(
                'pack',
                "$script:NuspecPath",
                '-NoPackageAnalysis',
                '-Version',
                "$global:VersionToRelease",
                '-OutputDirectory',
                "$Global:BrownserveRepoBuildOutputDirectory"
            )
            # On *nix we need to use mono to invoke nuget, so fudge the arguments a bit
            if (-not $isWindows)
            {
                # Mono won't have access to our NuGet PowerShell alias, so set the path using our env var
                $NugetArguments = @($Global:BrownserveNugetPath) + $NugetArguments
                Write-Verbose "Calling Nuget with:`n$NugetArguments"
            }
            & $NugetCommand $NugetArguments
        }
        $script:nupkgPath = Join-Path $Global:BrownserveRepoBuildOutputDirectory "$ModuleName.$global:NugetPackageVersion.nupkg" | Convert-Path
    }
    else
    {
        Write-Verbose 'Nuget not targeted, skipping...'
    }
}

<#
.SYNOPSIS
    Publishes the new release to the various endpoints
#>
task PublishRelease CheckPreviousReleases, Tests, PackNuGetPackage, CheckForUncommittedChanges, {
    # Only push to nuget if we want to
    if ('nuget' -in $PublishTo)
    {
        $NugetArguments = @(
            'push',
            $script:nupkgPath,
            '-Source',
            'nuget',
            '-ApiKey',
            $NugetFeedApiKey
        )
        if (-not $isWindows)
        {
            $NugetArguments = @($Global:BrownserveNugetPath) + $NugetArguments
        }
        Write-Verbose 'Pushing to nuget'
        # Be careful - Invoke-BuildExec requires curly braces to be on the same line!
        exec {
            & $NugetCommand $NugetArguments
        }
    }
    else
    {
        Write-Verbose 'nuget not targetted, skipping...'
    }

    if ('PSGallery' -in $PublishTo)
    {
        Write-Verbose 'Pushing to PSGallery'
        # For PSGallery the module needs to be in a directory named after itself... -_- (PowerShellGet is awful)
        $PSGalleryParams = @{
            Path        = $global:BrownserveBuiltModuleDirectory
            NuGetAPIKey = $PSGalleryAPIKey
        }
        Publish-Module @PSGalleryParams
    }
    else
    {
        Write-Verbose 'PSGallery not targeted, skipping...'
    }

    if ('GitHub' -in $PublishTo)
    {
        Write-Verbose "Creating GitHub release for $global:VersionToRelease"
        $ReleaseParams = @{
            Name        = "v$global:VersionToRelease"
            Tag         = "v$global:VersionToRelease"
            Description = $script:ReleaseNotes
            GitHubToken = $GitHubPAT
            RepoName    = $GitHubRepoName
            GitHubOrg   = $GitHubRepoOwner
        }
        if ($PreRelease -eq $true)
        {
            $ReleaseParams.Add('Prerelease', $true)
            $ReleaseParams.Add('TargetCommit', $script:CurrentCommitHash)
        }
        New-GitHubRelease @ReleaseParams | Out-Null
    }
    else
    {
        Write-Verbose 'GitHub not targetted, skipping...'
    }
}

<#
.SYNOPSIS
    Meta task for building the module.
.DESCRIPTION
    This task will run all the tasks required to build the module.
    #TODO: review use of SetLineEndings here
#>
task Build UseWorkingCopy, CreateModuleManifest, UpdateModuleDocumentation, CreateModuleHelp, SetLineEndings, {
    Write-Build Green 'Build complete'
}

<#
.SYNOPSIS
    Meta task for building and testing the module.
.DESCRIPTION
    This task will build the module and perform unit tests on it.
#>
task BuildAndTest Build, Tests, {
    Write-Build Green 'Build and test complete'
}

<#
.SYNOPSIS
    Meta task for building and testing the module, then finally confirming there are no uncommitted changes.
.DESCRIPTION
    This task will build the module, perform unit tests on it and then ensure there are no uncommitted changes
    resulting from the build.
    This is the build we use for our pull request CI pipeline.
#>
task BuildTestAndCheck BuildAndTest, CheckForUncommittedChanges, {
    Write-Build Green 'Build, test and check complete'
}
