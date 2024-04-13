<#
.SYNOPSIS
    This contains the build tasks for Invoke-Build to use.
    Each task is documented with a synopsis and description to explain what it does.
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
        'patch'
    )]
    [string]
    $ReleaseType,

    # An optional release notice to include in the release
    [Parameter(
        Mandatory = $false
    )]
    [string]
    $ReleaseNotice,

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

    # GitHub token used during the StageRelease build, must have the following permissions:
    #   * Read/Write pull requests
    #   * Read issues
    [Parameter(
        Mandatory = $false
    )]
    [string]
    $GitHubStageReleaseToken,

    # GitHub token used during the Release build, must have the following permissions:
    #   * Read/write releases
    [Parameter(
        Mandatory = $false
    )]
    [string]
    $GitHubReleaseToken,

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
$script:ChangelogPath = Join-Path $Global:BrownserveRepoRootDirectory -ChildPath 'CHANGELOG.md'
$script:NugetPackageDirectory = Join-Path $global:BrownserveRepoBuildOutputDirectory 'NuGetPackage'
$script:NuspecPath = Join-Path $script:NugetPackageDirectory "$ModuleName.nuspec"
$script:GitHubRepoURI = "https://github.com/$GitHubRepoOwner/$GitHubRepoName"
$Script:BuiltModulePath = (Join-Path $global:BrownserveBuiltModuleDirectory -ChildPath "$ModuleName.psd1")
$script:TrackedFiles = @()

<#
    Work out if this is a production release depending on the branch we're building from
    We default to $true unless we detect that we're running on the default branch, as anything that is in the default
    branch should be the one to build shipped versions of the code.
    This should ensure that:
        * Main can never be used a prerelease tag
        * Feature branches cannot ever create a production release
    NOTE: this does not affect releases - there is different logic for that later on.
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
    Checks that all the required parameters for publishing a release have been provided.
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
        if (!$GitHubReleaseToken)
        {
            throw 'GitHubReleaseToken not provided'
        }
    }
}

<#
.SYNOPSIS
    Ensures all the parameters required to stage a release have been provided
#>
task CheckStagingParameters {
    if (!$GitHubStageReleaseToken)
    {
        throw 'GitHubStageReleaseToken must be set when performing a release'
    }
}

<#
.SYNOPSIS
    Sets up additional parameters required for staging a release
.DESCRIPTION
    This task should only be called as part of the StageRelease pipeline
#>
task SetStagingVariables {
    Write-Verbose 'Setting staging variables'
    $script:Stage = $true
}

<#
.SYNOPSIS
    Special task for setting up any release specific variables.
.DESCRIPTION
    This task should only be called as part of the release pipeline
#>
task SetReleaseVariables {
    Write-Verbose 'Setting release variables'
    $script:Release = $true
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
        Write-Build White "Loading working copy of module from $Global:BrownserveModuleDirectory"
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
    Write-Build White 'Getting release history'
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
        Therefore we select the last "stable" release which should always be what we want to work with.
        The exception to this is when we're performing a release, in which case we want to use the latest version regardless
    #>
    if ($script:Release -ne $true)
    {
        $script:LastRelease = $script:Changelog.VersionHistory |
            Where-Object { $_.PreRelease -eq $false } |
                Select-Object -First 1
    }
    else
    {
        $script:LastRelease = $script:Changelog.VersionHistory |
            Select-Object -First 1
    }
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
    Write-Build White 'Setting version information'
    $script:CurrentVersion = $script:LastRelease |
        Select-Object -ExpandProperty Version
    if (!$script:CurrentVersion)
    {
        throw 'Unable to determine current version from changelog'
    }
    <#
        When we're performing a release we don't actually want to update the version number as with our workflows
        the version is set in the changelog prior to the build and we'll want to use that version number for the release.
        Also occasionally we may want to republish a version that we've already released.
        For example if we add another release endpoint or if we failed to release to one of our current endpoints
        due to an api key issue etc.
    #>
    if ($script:Release -eq $true)
    {
        Write-Verbose 'Release flag set, skipping updating version number'
        $script:NewVersion = $script:CurrentVersion
        $NugetPackageVersion = $script:CurrentVersion
        <#
            When performing releases we always do so from the main branch so the $PreRelease flag will always be false.
            However we do want to ensure that if we're releasing a pre-release version that we set the $PreRelease flag
            so we check for the pre-release label and set the flag accordingly.
        #>
        if ($script:NewVersion.PreReleaseLabel)
        {
            $script:PreRelease = $true
        }
    }
    else
    {
        # The ReleaseType parameter is technically optional but we do need it to determine the new version number
        if (!$ReleaseType)
        {
            throw '-ReleaseType not provided'
        }
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

        <#
            NuGet has a very specific version format that we need to adhere to.
        #>
        $NugetPackageVersionParams = @{
            Version         = $script:NewVersion
            # We use SemVer 1.0.0 as while NuGet has supported SemVer 2.0.0 since 4.3.0 we want to ensure we're compatible with older versions (for now)
            SemanticVersion = '1.0.0'
        }
        $NugetPackageVersion = Format-NuGetPackageVersion @NugetPackageVersionParams
        Write-Debug "NugetPackageVersion: $NugetPackageVersion"
    }
    <#
        We use the NugetPackageVersion for our release version as currently this is the most restrictive in terms
        of supported format.
        This should mean everything stays consistent.
    #>
    $Global:BuildVersion = $NugetPackageVersion
    # For GitHub releases and the changelog we prefix the version with a 'v'
    $script:PrefixedVersion = "v$($Global:BuildVersion)"
    Write-Build Magenta "Building version $script:PrefixedVersion of $ModuleName"
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
    # In theory we should never be able to get here but just in case...
    if ($script:CurrentVersion -eq $script:NewVersion)
    {
        throw 'Current version and new version are the same, cannot create changelog entry'
    }
    Write-Build White "Creating new changelog entry for '$script:NewVersion'"
    $NewChangelogEntryParams = @{
        Version         = $script:NewVersion
        RepositoryOwner = $GitHubRepoOwner
        RepositoryName  = $GitHubRepoName
        ChangelogObject = $script:Changelog
    }
    if ($ReleaseNotice)
    {
        $NewChangelogEntryParams.Add('Notice', $ReleaseNotice)
    }
    if ($GitHubStageReleaseToken)
    {
        $NewChangelogEntryParams.Add('Auto', $true)
        $NewChangelogEntryParams.Add('GitHubToken', $GitHubStageReleaseToken)
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
    Write-Build White 'Updating changelog'
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
    $script:TrackedFiles += ($script:ChangelogPath | Convert-Path)
}

<#
.SYNOPSIS
    Removes characters from the release notes that may make things sad
.DESCRIPTION
    A previous run of the StageRelease task will have generated the release notes and stored them in the changelog which
    we will have read in to the $script:LastRelease.ReleaseNotes variable at the beginning of the build.
    This task will remove any characters that may cause issues with our various endpoints.
#>
task FormatReleaseNotes SetVersion, {
    Write-Build White 'Formatting release notes.'
    $script:ReleaseNotes = $script:LastRelease.ReleaseNotes | Out-String
    if (!$script:ReleaseNotes)
    {
        throw 'Release notes missing'
    }
    try
    {
        $script:CleanReleaseNotes = Remove-Markdown -String $script:ReleaseNotes -ErrorAction 'Stop'
    }
    catch
    {
        throw "Failed to remove markdown from release notes. `n$($_.Exception.Message)"
    }
    # Filter out characters that'll break the XML and/or just generally look horrible in NuGet
    $script:CleanReleaseNotes = $script:CleanReleaseNotes -replace '"', '\"' -replace '`', '' -replace '\*', ''
    Write-Debug "Release notes for $($Global:BuildVersion):`n$script:CleanReleaseNotes"
}

<#
.SYNOPSIS
    Checks for previous releases to ensure we're not trying to release a version that already exists
.DESCRIPTION
    This task will check for previous releases in GitHub, the PSGallery and NuGet.
    If a release is found with the same version number as the one we're trying to release then the build will fail.
    Even if only one of the endpoints has a release with the same version number the build will fail.
    We should be consistent across all endpoints.
    Checks are performed only against the endpoints defined in $PublishTo so if a new endpoint is added or you want to
    publish to an endpoint that previously failed simply exclude the others.
#>
task CheckPreviousReleases SetVersion, {
    Write-Build White 'Checking for previous releases'
    if ('GitHub' -in $PublishTo)
    {
        Write-Verbose 'Checking for previous releases in GitHub'
        $CurrentReleases = Get-GitHubRelease `
            -GitHubToken $GitHubReleaseToken `
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
        if ($CurrentReleases.Version -contains $Global:BuildVersion)
        {
            throw "There already appears to be a $Global:BuildVersion release!"
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
        if ($CurrentReleases.Version -contains $Global:BuildVersion)
        {
            throw "There already appears to be a $Global:BuildVersion release!"
        }
    }
}

<#
.SYNOPSIS
    Copies the module files over to the build directory
.DESCRIPTION
    We copy the base module files over to the build directory so they can be compiled into a proper PowerShell module.
#>
task CopyModule {
    Write-Build White 'Copying files to build output directory'
    # Copy the "Module" directory over to the build output directory
    Copy-Item -Path $Global:BrownserveModuleDirectory -Destination $global:BrownserveBuiltModuleDirectory -Recurse -Force
}

<#
.SYNOPSIS
    Creates the PowerShell module manifest
.DESCRIPTION
    We create the module manifest as part of every build rather than storing it permanently.
    This is due to the fact that at the time of writing Update-ModuleManifest is somewhat limited so overwriting/updating
    options later on is a chore.
    Also it seems to be common practice with several other modules.
#>
task CreateModuleManifest SetVersion, FormatReleaseNotes, CopyModule, {
    Write-Build White 'Creating PowerShell module manifest'
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
        $ModuleManifest.add('Prerelease', (([semver]$Global:BuildVersion).PreReleaseLabel))
    }
    New-ModuleManifest @ModuleManifest -ErrorAction 'Stop'
}

<#
.SYNOPSIS
    Imports the module after building it
.DESCRIPTION
    Once the module has been built we import it, this is needed for the tests to be able to run and to perform local
    development.
    We make the concious decision to overwrite the module if it is already loaded in the users current session however
    we do warn the user if this has been performed.
#>
task ImportModule CreateModuleManifest, {
    Write-Build White 'Importing built module'
    if ((Get-Module $ModuleName))
    {
        # Only warn if we're in an interactive session.
        if (!$env:CI)
        {
            $WarningMessage = @"
The PowerShell module '$ModuleName' has been reloaded using the version built by this script.
This may mean that functionality has changed.
You may wish to run _init.ps1 again to reload the current stable version of this module.
"@
            Write-Warning $WarningMessage
        }
        Remove-Module $ModuleName -Force -Confirm:$false -Verbose:$false
    }
    Import-Module $Script:BuiltModulePath -Force -Verbose:$false
}

<#
.SYNOPSIS
    Uses PlatyPS to generate the markdown documentation for the module
.DESCRIPTION
    We store our modules help information in markdown files in the "Docs" directory of the repo.
    This task will generate those files using PlatyPS.
#>
task UpdateModuleDocumentation ImportModule, {
    Write-Build White 'Updating markdown documentation'
    $DocsParams = @{
        ModuleName        = $ModuleName
        ModulePath        = $Script:BuiltModulePath
        DocumentationPath = $Global:BrownserveRepoDocsDirectory
        ModuleGUID        = $ModuleGUID
    }
    # When we're preparing to release a new version then we should update the help version in the module page
    if ($script:Stage -eq $true)
    {
        $DocsParams.Add('HelpVersion', $script:NewVersion)
    }
    Build-ModuleDocumentation @DocsParams | Out-Null
    <#
        Store this in a script variable as in certain builds we use it later on. (e.g. setting help version etc)
        We do this _after_ we've generated the docs as the module page might not exist before which will cause
        Resolve-Path to fail.
    #>
    $Script:ModulePagePath = Join-Path $Global:BrownserveRepoDocsDirectory "$ModuleName.md" | Resolve-Path
}

<#
.SYNOPSIS
    Updates the modules MALM help
.DESCRIPTION
    PlatyPS will read in the markdown files in the 'Docs' directory and generate a MALM help file for the module.
    This needs to be shipped with the module so that PowerShell can display help for the module, therefore we create it
    in the built module directory.
#>
task CreateModuleHelp UpdateModuleDocumentation, {
    Write-Build White 'Creating module MALM help'
    New-Item (Join-Path $global:BrownserveBuiltModuleDirectory 'en-US') -ItemType Directory | Out-Null
    $HelpParams = @{
        ModuleDirectory   = $global:BrownserveBuiltModuleDirectory
        DocumentationPath = (Join-Path $global:BrownserveRepoDocsDirectory $ModuleName)
    }
    Add-ModuleHelp @HelpParams | Out-Null
}

<#
.SYNOPSIS
    Compress the module so it can be uploaded to GitHub
.DESCRIPTION
    We don't use Compress-Archive as it doesn't behave consistently across platforms.
    On Linux it will ignore "hidden" dot files and on Windows it will include them.
    See (https://stackoverflow.com/q/53551418/10843454)
#>
task CompressModule CreateModuleHelp, {
    if ('GitHub' -in $PublishTo)
    {
        $script:CompressedModule = Join-Path $global:BrownserveRepoBuildOutputDirectory "Brownserve.PSTools-$($Global:BuildVersion).tgz"
        Write-Build White 'Compressing PowerShell module'
        try
        {
            [System.IO.Compression.ZipFile]::CreateFromDirectory($global:BrownserveBuiltModuleDirectory, $script:CompressedModule)
        }
        catch
        {
            throw "Failed to compress module.`n$($_.Exception.Message)"
        }
    }
    else
    {
        Write-Verbose 'GitHub not targetted, skipping creation of compressed module asset'
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
    Write-Build White "Creating branch: $Script:StagingBranchName"
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
task CommitTrackedChanges UpdateChangelog, UpdateModuleDocumentation, CreateStagingBranch, {
    $CommitMessage = "docs: Prepare for $script:PrefixedVersion`n`nThis commit was automatically generated."
    if ($script:TrackedFiles.Count -gt 0)
    {
        Write-Build White 'Committing tracked changes'
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
.DESCRIPTION
    On the StageRelease build we create some changes that are committed on a branch.
    We need to push that branch to the repository
#>
task PushBranch CreateStagingBranch, CommitTrackedChanges, {
    Write-Build White 'Pushing branch to remote repository'
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
    As part of the build process we create/modify several files, including the module documentation.
    We want to make sure that we don't end up with any of these files ending up not being committed to the
    repository, so we check for them.
    !! WARNING this task doesn't have any dependencies as it would potentially trigger running tasks on builds
    !! where they should not be running, therefore placement of this task in the pipeline needs to be carefully considered
#>
task CheckForUncommittedChanges {
    Write-Build White 'Checking for uncommitted changes'
    $Status = Get-GitChanges
    if ($Status)
    {
        throw "The build has resulted in uncommitted changes being produced: `n$($Status.Source -join "`n")"
    }
}

<#
.SYNOPSIS
    Creates a PR for merging the staging release branch into the default branch
.DESCRIPTION
    When staging a release we'll need to create a pull request with our staged changelog/documentation changes to bring
    them into main ready for release.
#>
task CreatePullRequest PushBranch, CheckForUncommittedChanges, {
    Write-Build White 'Creating pull request'
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
            GitHubToken     = $GitHubStageReleaseToken
            RepositoryName  = $GitHubRepoName
            RepositoryOwner = $GitHubRepoOwner
        }
        $PRDetails = New-GitHubPullRequest @PullRequestParams
        $script:PRLink = $PRDetails.html_url
        Write-Debug "PRLink: $script:PRLink"
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
    Write-Build Yellow 'Performing unit testing, this may take a while...'
    $Results = Invoke-Pester -Path $Global:BrownserveRepoTestsDirectory -PassThru
    assert ($results.FailedCount -eq 0) "$($results.FailedCount) test(s) failed."
}

<#
.SYNOPSIS
    Creates a NuGet package for the module
.DESCRIPTION
    This prepares all the files required to ship a NuGet package.
    Because we upload a NuGet package to both nuget.org _and_ GitHub we need to ensure we run this task if either of
    those endpoints are targetted.
#>
task PrepareNuGetPackage SetVersion, CreateModuleManifest, FormatReleaseNotes, CreateModuleHelp, {
    if (('nuget' -in $PublishTo) -or ('GitHub' -in $PublishTo))
    {
        # We'll copy our build module to the nuget package and rename it to 'tools' 
        # as that seems to be the right way to do things
        Write-Build White "Copying built module to $script:NugetPackageDirectory"
        Copy-Item $global:BrownserveBuiltModuleDirectory -Destination (Join-Path $script:NugetPackageDirectory 'tools') -Recurse
        # Copy each of the necessary files over to the build output directory
        $ItemsToCopy = @(
        (Join-Path $Global:BrownserveRepoRootDirectory 'CHANGELOG.md'),
        (Join-Path $Global:BrownserveRepoRootDirectory 'LICENSE'),
        (Join-Path $Global:BrownserveRepoRootDirectory README.md)
        )
        Copy-Item $ItemsToCopy -Destination $script:NugetPackageDirectory -Force
        # Now we'll generate a nuspec file and pop it in the root of NuGet package
        # TODO: Create an object and ConvertTo-XML
        $Nuspec = @"
<?xml version="1.0" encoding="utf-8"?>
<package xmlns="http://schemas.microsoft.com/packaging/2011/08/nuspec.xsd">
  <metadata>
    <id>$ModuleName</id>
    <version>$Global:BuildVersion</version>
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

<# 
.SYNOPSIS
    Packs the nuget package ready for shipping off to nuget.org (or a private feed)
.DESCRIPTION
    Runs `nuget pack` to create a NuGet package of the module.
    We upload this to both nuget.org _and_ GitHub as a release asset so we need to make sure we do this if either is
    targetted
#>
task PackNuGetPackage PrepareNuGetPackage, {
    if (('nuget' -in $PublishTo) -or ('GitHub' -in $PublishTo))
    {
        Write-Build White 'Creating NuGet package'
        exec {
            # Note: the paths must be a separate index to the switch in the array
            $NugetArguments = @(
                'pack',
                "$script:NuspecPath",
                '-NoPackageAnalysis',
                '-Version',
                "$Global:BuildVersion",
                '-OutputDirectory',
                "$Global:BrownserveRepoBuildOutputDirectory"
            )
            # On *nix we need to use mono to invoke nuget, so fudge the arguments a bit
            if (-not $isWindows)
            {
                # Mono won't have access to our NuGet PowerShell alias, so set the path using our env var
                $NugetArguments = @($Global:BrownserveNugetPath) + $NugetArguments
            }
            & $NugetCommand $NugetArguments
        }
        $script:nupkgPath = Join-Path $Global:BrownserveRepoBuildOutputDirectory "$ModuleName-$global:BuildVersion.nupkg" | Convert-Path
    }
    else
    {
        Write-Verbose 'Nuget and GitHub not targeted, skipping...'
    }
}

<#
.SYNOPSIS
    Publishes the new release to the various endpoints
.DESCRIPTION
    This task pushes the release up to the various endpoints we target.
    Endpoints can be configured in the $PublishTo parameter
#>
task PublishRelease CheckPreviousReleases, CompressModule, Tests, PackNuGetPackage, CheckForUncommittedChanges, {
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
        Write-Build White 'Pushing to nuget'
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
        Write-Build White 'Pushing to PSGallery'
        <#
            For PSGallery the module needs to be in a directory named after itself... -_- (PowerShellGet is awful)
            2023-09-09: It gets EVEN MORE awful!
            It looks like PowerShellGet will automatically tag EVERY cmdlet which takes you over the 4000 NuGet character limit!!!
        #>
        $PSGalleryParams = @{
            Path              = $global:BrownserveBuiltModuleDirectory
            NuGetAPIKey       = $PSGalleryAPIKey
            SkipAutomaticTags = $true
        }
        Publish-Module @PSGalleryParams
    }
    else
    {
        Write-Verbose 'PSGallery not targeted, skipping...'
    }

    if ('GitHub' -in $PublishTo)
    {
        Write-Build White "Creating GitHub release for $Global:BuildVersion"
        $ReleaseParams = @{
            Name        = $script:PrefixedVersion
            Tag         = $script:PrefixedVersion
            Description = $script:ReleaseNotes
            GitHubToken = $GitHubReleaseToken
            RepoName    = $GitHubRepoName
            GitHubOrg   = $GitHubRepoOwner
        }
        if ($PreRelease -eq $true)
        {
            $ReleaseParams.Add('Prerelease', $true)
            $ReleaseParams.Add('TargetCommit', $script:CurrentCommitHash)
        }
        $ReleaseResponse = New-GitHubRelease @ReleaseParams

        if ($script:CompressedModule)
        {
            Write-Build White 'Uploading compressed module as release asset'
            Add-GitHubReleaseAsset `
                -UploadURL = $ReleaseResponse.upload_url `
                -Token $GitHubReleaseToken `
                -FilePath $script:CompressedModule `
                -ErrorAction 'Stop'
        }
        if ($script:nupkgPath)
        {
            Write-Build White 'Uploading nupkg as release asset'
            Add-GitHubReleaseAsset `
                -UploadURL = $ReleaseResponse.upload_url `
                -Token $GitHubReleaseToken `
                -FilePath $script:nupkgPath `
                -ErrorAction 'Stop'
        }
    }
    else
    {
        Write-Verbose 'GitHub not targetted, skipping...'
    }
}

<#
    Below are the meta tasks that we use to build the module.
    These are the tasks that we'll actually call run this script via Invoke-Build.
    Dependent tasks will be run in the order they're defined.
    !! BE VERY CAREFUL WITH THE ORDERING !!
#>

<#
.SYNOPSIS
    Meta task for building the module.
.DESCRIPTION
    This task will run all the tasks required to build just the module.
    It doesn't build the documentation, NuGet package or perform any tests.
    This task is mostly here just to serve as a base for other tasks.
#>
task Build UseWorkingCopy, CreateModuleManifest, {}

<#
.SYNOPSIS
    Meta task for building the module and importing it.
.DESCRIPTION
    This task will run all the tasks required to build the module and import it.
    It does not build the documentation, NuGet package or perform any tests as these can take some time to complete.
    This task is best used when developing new features locally as it allows you to quickly test your changes
    interactively.
#>
task BuildAndImport Build, ImportModule, {}

<#
.SYNOPSIS
    Meta task for building the module along with the documentation.
.DESCRIPTION
    This task will run all the tasks required to build the module and generate the documentation.
    The documentation can take some time to generate, especially as it currently requires us to run a separate process
    to replace the line endings and format the markdown.
    This task is best ran after any local changes have largely been finalised as it will generate any documentation
    required.
#>
task BuildWithDocs BuildAndImport, CreateModuleHelp, {}

<#
.SYNOPSIS
    Meta task for building and testing the module.
.DESCRIPTION
    This task performs the same actions as the previous tasks but also performs unit tests on the module.
    This task is best used to thoroughly test any changes before committing them.
#>
task BuildAndTest BuildWithDocs, Tests, {}

<#
.SYNOPSIS
    Meta task for building and testing the module, then finally confirming there are no uncommitted changes.
.DESCRIPTION
    This task will build the module, perform unit tests on it and then ensure there are no uncommitted changes
    resulting from the build.
    This is the build we use for our pull_request CI pipeline and as such must pass before we can merge any changes.
#>
task BuildTestAndCheck BuildAndTest, CheckForUncommittedChanges, {}

<#
.SYNOPSIS
    Meta task that prepares the module for release.
.DESCRIPTION
    This task will update the changelog and module documentation with the new version, commit those changes to a
    new branch and then create a pull request for merging the changes into the default branch.
    This allows us to review the changes and make any adjustments before we actually release them.
    We use this task in the stage_release CI pipeline.
#>
task StageRelease CheckStagingParameters, SetStagingVariables, UseWorkingCopy, CreateChangelogEntry, UpdateChangelog, UpdateModuleDocumentation, UpdateModulePageHelpVersion, CreatePullRequest, {
    $BuildMessage = @"
The release has been successfully staged and a pull request has been created.
Please review the changes at $script:PRLink and merge if they look good.
If you need to make any changes please do so on the $script:StagingBranchName branch.
"@
    Write-Build Green $BuildMessage
}

<#
.SYNOPSIS
    Meta task that performs a release of the module.
.DESCRIPTION
    For a release the module is built, tested and then published to the various endpoints.
    Unlike other tasks the version number is not updated as part of the build as we expect it to already be set in the
    changelog.
    We use this task in the release CI pipeline.
#>
task Release CheckPublishingParameters, SetReleaseVariables, BuildAndTest, PublishRelease, {}
