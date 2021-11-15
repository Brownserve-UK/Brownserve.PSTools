function Update-Changelog
{
    [CmdletBinding()]
    param
    (
        # The path to the changelog file
        [Parameter(Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [string]
        $ChangelogPath,

        # The type of release (major, minor, patch)
        [Parameter(
            Mandatory = $false
        )]
        [ValidateSet('major', 'minor', 'patch')]
        [string]
        $ReleaseType,

        # The feature list for this release
        [Parameter(
            Mandatory = $false
        )]
        [array]
        $Features,

        # Any bugfixes in this release
        [Parameter(
            Mandatory = $false
        )]
        [array]
        $Bugfixes,

        # Any known issues in this release
        [Parameter(
            Mandatory = $false
        )]
        [array]
        $KnownIssues,

        # The URL of the repo that the changelog belongs to
        # If none is provided the cmdlet will attempt to work it out from the current changelog and prompt if needed
        [Parameter(
            Mandatory = $false
        )]
        [string]
        $RepoUrl,

        # If set will attempt to auto-generate features from the commit history (ignored if $Features are passed into the cmdlet)
        [Parameter(
            Mandatory = $false
        )]
        [switch]
        $AutoGenerateFeatures,

        # Skip optional prompts
        [Parameter(
            Mandatory = $false
        )]
        [switch]
        $SkipOptionalPrompts
    )

    Write-Verbose "Checking changelog path is valid"
    if (!(Test-Path $ChangelogPath))
    {
        throw "$ChangelogPath does not appear to be a valid path to a changelog"
    }

    # Read current changelog information
    try
    {
        $CurrentChangelogInfo = Read-Changelog -ChangelogPath $ChangelogPath
    }
    catch
    {
        throw "Failed to get current changelog information.`n$($_.Exception.Message)"
    }

    # If we don't have a URL already then try to extract it from the changelog
    if (!$RepoUrl)
    {
        $RepoURL = $CurrentChangelogInfo.RepoURL
    }

    # Start by getting mandatory information
    Write-Verbose "Checking all required information is present"

    # Find out what type of release we are doing
    # We re-cast ReleaseType to a new variable as PowerShell does something special with cmdlet parameters when they are set-up
    # Meaning we can get some weird errors if we try to re-use them
    $ReleaseTypeCheck = $ReleaseType
    $ValidReleaseTypes = @('major', 'minor', 'patch')
    while ($ReleaseTypeCheck -notin $ValidReleaseTypes)
    {
        $ReleaseTypeCheck = Get-Response `
            -Prompt "What kind of release is this? (major/minor/patch)`n
    Major (Breaking changes from previous version)`n
    Minor (Backwards compatible changes from previous version)`n
    Patch (Minor backwards compatible bug fixes from previous version)" `
            -ResponseType 'string' `
            -Mandatory
    }

    # Increment our version number based on what kind of release we're doing
    switch ($ReleaseTypeCheck)
    {
        'major'
        {
            $Version = [version]::New("$($CurrentChangelogInfo.CurrentVersion.Major + 1).0.0")
        }
        'minor'
        {
            $Version = [version]::New("$($CurrentChangelogInfo.CurrentVersion.Major).$($CurrentChangelogInfo.CurrentVersion.Minor + 1).0")
        }
        'patch'
        {
            $Version = [version]::New("$($CurrentChangelogInfo.CurrentVersion.Major).$($CurrentChangelogInfo.CurrentVersion.Minor).$($CurrentChangelogInfo.CurrentVersion.Build + 1)")
        }
    }
    Write-Verbose "Version is now $($Version.ToString())"

    if (!$Features)
    {
        Write-Verbose "Prompting for features"
        # Offer to auto generate a list of release features from the git commit history for this branch (if we haven't already specified it in the params above)
        if (!$AutoGenerateFeatures)
        {
            $AutoGenerateFeatures = Get-Response `
                -Prompt "Would you like to generate a list of new features for this release from this branches commit history?" `
                -ResponseType 'bool'
        }
        if ($AutoGenerateFeatures)
        {
            Write-Verbose "Auto-generating a list of features based off of commit history"
            try
            {
                # First get the current branch
                $CurrentBranch = Start-SilentProcess `
                    -FilePath 'git' `
                    -Arguments 'rev-parse --abbrev-ref HEAD' `
                    -PassThru | Select-Object -ExpandProperty OutputContent
                Write-Verbose "CurrentBranch detected as $CurrentBranch"

                # Create a git log search filter that will list all commits between the previous tag and the current HEAD
                $CommitSearcher = "v$($CurrentChangelogInfo.CurrentVersion.ToString())..HEAD"

                # Query the git log for all changes on this branch excluding those that came from our default branch
                # Output only the message string (%s) and dump the result into an array
                $Features = (Start-SilentProcess `
                        -FilePath 'git' `
                        -Arguments "log $CommitSearcher  --pretty=`"%s`"" `
                        -PassThru | Select-Object -ExpandProperty OutputContent) -split "`n"
                
                if (!$Features)
                {
                    Write-Error "Failed to automatically get a list of commits"
                }
            }
            catch
            {
                throw $_.Exception.Message
            }
        }
        else
        {
            $Features = Get-Response `
                -Prompt "What are the new features that this release brings?" `
                -ResponseType 'array' `
                -Mandatory
        }
    }

    # If we haven't got the URL by now then prompt for it
    if (!$RepoUrl)
    {
        $RepoUrl = Get-Response `
            -Prompt "What is the URL of the repo that the changelog belongs to?" `
            -ResponseType 'string' `
            -Mandatory
    }

    # Get any optional params
    if (-not $SkipOptionalPrompts)
    {
        Write-Verbose "Prompting for optional information"
        # We use '-notin $PSBoundParameters.Keys' instead of '-not' or '!' as this ensures we get the correct result each time...trust me
        if ('BugFixes' -notin $PSBoundParameters.Keys)
        {
            $Bugfixes = Get-Response `
                -Prompt "What Bugfixes does this release bring?" `
                -ResponseType 'array'
        }

        if ('KnownIssues' -notin $PSBoundParameters.Keys)
        {
            $KnownIssues = Get-response `
                -Prompt 'What known issues are present in this release?' `
                -ResponseType 'array'
        }
    }

    # Generate the new changelog block
    $ChangelogBlockParams = @{
        Version  = $Version
        RepoUrl  = $RepoUrl
        Features = $Features
    }
    if ($Bugfixes)
    {
        $ChangelogBlockParams.Add('Bugfixes', $Bugfixes)
    }
    if ($KnownIssues)
    {
        $ChangelogBlockParams.Add('KnownIssues', $KnownIssues)
    }

    Write-Verbose "Generating new changelog block"
    try
    {
        $ChangelogBlock = New-ChangelogBlock @ChangelogBlockParams
    }
    catch
    {
        throw $_.Exception.Message
    }
    Write-Debug $ChangelogBlock

    # All being good lets update our changelog!
    try
    {
        $CurrentChangelogInfo | Add-ChangelogEntry -NewContent $ChangelogBlock
    }
    catch
    {
        Write-Error "Failed to update changelog.$($_.Exception.Message)"
    }
}