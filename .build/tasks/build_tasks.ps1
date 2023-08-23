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

    # If set to true this will denote a pre-production release
    [Parameter(
        Mandatory = $False
    )]
    [bool]
    $PreRelease = $true,

    # The branch this is being built from
    [Parameter(
        Mandatory = $true
    )]
    [string]
    $BranchName,

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
    $GitHubOrg = $true,

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
    $PSGalleryAPIKey
)
# Depending on how we got the branch name we may need to remove the full ref
$BranchName = $BranchName -replace 'refs\/heads\/', ''
Write-Verbose @"
`nBuild parameters:
    PreRelease = $PreRelease
    BranchName = $BranchName
    PublishTo = $($PublishTo -join ', ')
"@
$script:CurrentCommitHash = & git rev-parse HEAD


$global:BrownserveBuiltModuleDirectory = Join-Path $global:BrownserveRepoBuildOutputDirectory $ModuleName # This is global as it gets used in our tests too
$script:NugetPackageDirectory = Join-Path $global:BrownserveRepoBuildOutputDirectory 'NuGetPackage'
$script:NuspecPath = Join-Path $script:NugetPackageDirectory "$ModuleName.nuspec"
$script:GitHubRepoURI = "https://github.com/$GitHubOrg/$GitHubRepoName"
$Script:BuiltModulePath = (Join-Path $global:BrownserveBuiltModuleDirectory -ChildPath "$ModuleName.psd1")
$script:TrackedFiles = @()

# On non-windows platforms mono is required to run NuGet 🤢
$NugetCommand = 'nuget'
if (-not $isWindows)
{
    Write-Verbose 'Running on linux, will use mono when running nuget'
    $NugetCommand = 'mono'
}

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
    if (!$GitHubOrg)
    {
        throw 'GitHubOrg not provided'
    }
    if (!$GitHubRepoName)
    {
        throw 'GitHubRepoName not provided'
    }
    if (!$GitHubPAT)
    {
        throw 'GitHub PAT not provided'
    }
}

# Synopsis: Generate version info from the changelog and branch name.
task GenerateVersionInfo {
    $script:Changelog = Read-Changelog -ChangelogPath (Join-Path $Global:BrownserveRepoRootDirectory -ChildPath 'CHANGELOG.md')
    $script:Version = $Changelog.CurrentVersion
    $script:ReleaseNotes = $Changelog.ReleaseNotes -replace '"', '\"' -replace '`', '' -replace '\*', '' # Filter out characters that'll break the XML and/or just generally look horrible in NuGet
    $NugetPackageVersionParams = @{
        Version    = $Version
        BranchName = $BranchName
    }
    if ($PreRelease -eq $true)
    {
        $NugetPackageVersionParams.Add('PreRelease', $true)
    }
    $global:NugetPackageVersion = New-NuGetPackageVersion @NugetPackageVersionParams
    Write-Verbose "Version: $script:Version"
    Write-Verbose "Nuget package version: $global:NugetPackageVersion"
    Write-Verbose "Release notes:`n$script:ReleaseNotes"
}

# Synopsis: Checks to make sure we don't already have this release in GitHub
task CheckPreviousRelease GenerateVersionInfo, {
    if ('GitHub' -in $PublishTo)
    {
        Write-Verbose 'Checking for previous releases'
        $CurrentReleases = Get-GitHubRelease `
            -GitHubToken $GitHubPAT `
            -RepoName $GitHubRepoName `
            -GitHubOrg $GitHubOrg
        if ($CurrentReleases.tag_name -contains "v$global:NugetPackageVersion")
        {
            throw "There already appears to be a v$global:NugetPackageVersion release!`nDid you forget to update the changelog?"
        }
    }
    # TODO: Check for previous releases in NuGet and PSGallery as well
}

# Synopsis: Copies over all the necessary files to be packaged for a release
task CopyModule {
    Write-Verbose 'Copying files to build output directory'
    # Copy the "Module" directory over to the build output directory
    Copy-Item -Path $Global:BrownserveModuleDirectory -Destination $global:BrownserveBuiltModuleDirectory -Recurse -Force
}

# Synopsis: Generates the module manifest
task GenerateModuleManifest CopyModule, GenerateVersionInfo, {
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
        ModuleVersion     = "$script:Version"
        Description       = $ModuleDescription
        PowerShellVersion = '6.0'
        ReleaseNotes      = $script:ReleaseNotes
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
        $ModuleManifest.add('Prerelease', ($BranchName -replace '[^a-zA-Z0-9]', ''))
    }
    New-ModuleManifest @ModuleManifest -ErrorAction 'Stop'
}

<# 
.SYNOPSIS
    Now we've built the module we need to import the freshly built version before we can test it.
#>
task ImportModule GenerateModuleManifest, {
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

# Synopsis: Generates the markdown documentation for the module
task GenerateDocs ImportModule, {
    Write-Verbose 'Generating markdown documentation'
    $DocsParams = @{
        ModuleName        = $ModuleName
        ModulePath        = $Script:BuiltModulePath
        DocumentationPath = $Global:BrownserveRepoDocsDirectory
    }
    #TODO: main should not be hardcoded and we should have provision for dev too (can we make use of PreRelease?)
    if ($BranchName -eq 'main')
    {
        $DocsParams.Add('HelpVersion', $global:NugetPackageVersion)
        $DocsParams.Add('ModuleGUID', $ModuleGUID)
    }
    Build-ModuleDocumentation @DocsParams

    $script:TrackedFiles += (Get-ChildItem `
            -Path (Join-Path $Global:BrownserveRepoDocsDirectory -ChildPath 'Brownserve.PSTools')  `
            -Filter *.md `
            -Recurse | Select-Object -ExpandProperty 'FullName')
    $script:TrackedFiles += (Get-Item `
            -Path (Join-Path $Global:BrownserveRepoDocsDirectory -ChildPath 'Brownserve.PSTools.md'))
}

# Synopsis: Updates the module help
task UpdateModuleHelp GenerateDocs, {
    Write-Verbose 'Updating module help'
    $HelpParams = @{
        ModuleDirectory   = $Global:BrownserveModuleDirectory
        DocumentationPath = (Join-Path $global:BrownserveRepoDocsDirectory 'Brownserve.PSTools')
    }
    Add-ModuleHelp @HelpParams
    $script:TrackedFiles += (Join-Path $Global:BrownserveModuleDirectory -ChildPath 'en-US' -AdditionalChildPath 'Brownserve.PSTools-help.xml')
}

# Synopsis: Updates the changelog
task UpdateChangelog {
    # TODO: how do we handle changelogs for dev branch?
    # Possibly anytime we're doing a release we make sure the changelog gets updated? (e.g 0.1.0-dev)
    Write-Verbose 'Updating changelog'
}

<#
.SYNOPSIS
    Ensures line endings for tracked files are set to 'LF'
.DESCRIPTION
    PowerShell seems to insist on doing inconsistent things with line endings when running on different OSes.
    This results in constant line ending change diffs in git which fails the build.
    Therefore any (tracked) files that are files created as part of the build have their line endings explicitly set
#>
task SetLineEndings {
    if ($script:TrackedFiles.Count -gt 0)
    {
        Write-Verbose 'Ensuring line endings are consistent'
        Set-LineEndings `
            -Path $script:TrackedFiles `
            -LineEnding 'LF' `
            -ErrorAction 'Stop'
    }
    else
    {
        Write-Warning 'No tracked files were specified for line ending checks'
    }
}

# Synopsis: Checks for uncommitted changes, this should run after we've updated the documentation and changelog
task CheckForUncommittedChanges GenerateDocs, UpdateChangelog, SetLineEndings, {
    Write-Verbose 'Checking for uncommitted changes'
    $Status = Get-GitChanges
    if ($Status)
    {
        # TODO: Ignore changes to the changelog and documentation module page
        # TODO: special error for documentation changes
        throw "The build has resulted in uncommitted changes being produced: `n$($Status.Source -join "`n")"
    }
}

# Synopsis: Performs some testing on the module
task Tests ImportModule, {
    Write-Verbose 'Performing unit testing, this may take a while...'
    $Results = Invoke-Pester -Path $Global:BrownserveRepoTestsDirectory -PassThru
    assert ($results.FailedCount -eq 0) "$($results.FailedCount) test(s) failed."
}

# Synopsis: Creates our NuGet package
task CreateNugetPackage GenerateVersionInfo, GenerateModuleManifest, CopyModule, {
    # We'll copy our build module to the nuget package and rename it to 'tools'
    Write-Verbose 'Copying built module into NuGet package'
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
    <version>$global:NugetPackageVersion</version>
    <authors>$ModuleAuthor</authors>
    <owners>Brownserve UK</owners>
    <requireLicenseAcceptance>false</requireLicenseAcceptance>
    <summary>$ModuleDescription</summary>
    <description>$ModuleDescription</description>
    <projectUrl>$script:GitHubRepoURI</projectUrl>
    <releaseNotes>$script:ReleaseNotes</releaseNotes>
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

# Synopsis: Packs the nuget package ready for shipping off to nuget.org (or a private feed)
task Pack CreateNugetPackage, GenerateModuleManifest, {
    Write-Verbose 'Creating NuGet package'
    exec {
        # Note: the paths must be a separate index to the switch in the array
        $NugetArguments = @(
            'pack',
            "$script:NuspecPath",
            '-NoPackageAnalysis',
            '-Version',
            "$NugetPackageVersion",
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

# Synopsis: Push the package up to nuget
task PushNuget CheckPreviousRelease, Tests, Pack, CheckForUncommittedChanges, {
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
}

# Synopsis: Push the module to PSGallery too
task PushPSGallery CheckPreviousRelease, Tests, CheckForUncommittedChanges, {
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
}

# Synopsis: Creates a GitHub release for this version, we only do this once we've had a successful NuGet push
task GitHubRelease PushNuget, PushPSGallery, CheckForUncommittedChanges, {
    if ('GitHub' -in $PublishTo)
    {
        Write-Verbose "Creating GitHub release for $global:NugetPackageVersion"
        $ReleaseParams = @{
            Name        = "v$global:NugetPackageVersion"
            Tag         = "v$global:NugetPackageVersion"
            Description = $script:ReleaseNotes
            GitHubToken = $GitHubPAT
            RepoName    = $GitHubRepoName
            GitHubOrg   = $GitHubOrg
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
    This meta task will perform all the steps required to build the PowerShell module, but will not import the module
    nor build a NuGet packaged version of the module or perform any unit testing.
    This is useful to quickly test changes to module metadata and the like
#>
task Build GenerateModuleManifest, {}

<# 
.SYNOPSIS 
    This meta task will perform all the steps required to build the module and then import it into the current PowerShell session.
    This will not build the nuget packaged version of the module.
    This is useful to either test new functions/code locally or to ensure the module still loads after making changes
#>
task BuildImport ImportModule, {}

<#
.SYNOPSIS
    This meta task will perform all the steps required to build the PowerShell module, import it into the current PowerShell session
    and then build the Markdown documentation for the module.
    This ensures that there is an easy way to create documentation for the module.
#>
task BuildImportGenerateDocs GenerateDocs, SetLineEndings, {}

#TODO: Look at below and see when we need to insert GenerateDocs
<#
.SYNOPSIS
    This meta task will build the module and create a NuGet package of the built module.
    The module is not imported or tested.
    This is useful to test changes to the NuGet metadata.
#>
task BuildPack Pack, {}

<#
.SYNOPSIS
    This meta task will build the PowerShell module, import it and perform our unit tests
    This is useful when you want to check your changes are valid.
#>
task BuildImportTest Tests, {}

<#
.SYNOPSIS
    This meta task will build the PowerShell module, import it, generate the Markdown documentation ,perform our unit tests
    and ensure no uncommitted changes are present.
    This helps to ensure any pull requests are valid and good to merge.
#>
task BuildImportGenerateDocsTest UpdateModuleHelp, CheckForUncommittedChanges, Tests, {}

<#
.SYNOPSIS
    This meta task will build the PowerShell module, create a NuGet package, import the module and perform our unit tests.
    This is useful to test the complete pipeline as it is one stop short of a release.
#>
task BuildPackTest Tests, Pack, {}

<#
.SYNOPSIS
    This meta task builds, imports and tests the PowerShell module while also creating a NuGet packaged version of it.
    This is then pushed to the various platforms that house our module.
#>
task Release GitHubRelease, {}
