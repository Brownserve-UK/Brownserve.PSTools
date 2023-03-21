function Initialize-BrownserveBuildRepo
{
    [CmdletBinding()]
    param
    (
        # The path to the repo that should be initialized
        [Parameter(
            Mandatory = $true,
            Position = 0
        )]
        [string]
        $RepoPath, 

        # Any custom init steps that you may want to include for this repo
        [Parameter(
            Mandatory = $false
        )]
        [string]
        $CustomInitSteps,

        # If set will exclude our custom module loader
        [Parameter()]
        [switch]
        $ExcludeModuleLoader,

        # If set will skip copying our default VSCode snippets
        [Parameter()]
        [switch]
        $ExcludeSnippets,

        # If set will skip copying over the default VS code workspace settings
        [Parameter()]
        [switch]
        $ExcludeVSCodeSettings,

        # If set will include our default devcontainer
        [Parameter()]
        [switch]
        $IncludeDevcontainer,

        # Will forcefully overwrite files
        [Parameter()]
        [switch]
        $Force
    )
    Write-Host "Preparing repo $RepoPath for use with Brownserve.PSTools"
    Write-Verbose "Checking repo path is valid"
    try
    {
        if (!(Get-Item $RepoPath).PSIsContainer)
        {
            throw "$RepoPath does not appear to be a directory"
        }
    }
    catch
    {
        throw "$RepoPath does not appear to be a valid directory"
    }

    # We need dotnet to create our tool manifest and nuget.config
    try
    {
        Write-Verbose "Checking dotnet is present"
        $dotnetCheck = Get-Command 'dotnet'
    
    }
    catch
    {}    
    if (!$dotnetCheck)
    {
        throw "'dotnet' is not available on your path, have you installed it?"
    }

    <#
        Let's see if we've already got an _init file and if so extract any custom steps the user might have
        We do this check early as it's one of the one's that's more likely to fail and therefore we want to
        catch it before we've done any other set-up
    #>
    if (!$CustomInitSteps)
    {
        $CustomInitSteps = ""
    }
    $InitPath = Join-Path $RepoPath '.build' -AdditionalChildPath '_init.ps1' # TODO: probably shouldn't hardcode '.build' here...
    if ((Test-Path $InitPath))
    {
        try
        {
            $CustomInitStepsCheck = (Read-BrownserveInitFile $InitPath).CustomCode | Out-String
        }
        catch
        {
            # Only throw if we're not forcing replacement
            if (-not $Force)
            {
                throw "$($_.Exception.Message), re-run cmdlet with '-Force' to overwrite the _init.ps1 file with a new one."
            }
        }
        if ($CustomInitStepsCheck)
        {
            [string]$FinalCustomInitSteps = $CustomInitStepsCheck + "$CustomInitSteps"
        }
    }

    $PermanentPaths = @(
        [InitPath]@{
            VariableName = 'RepoBuildDirectory'
            Path         = '.build'
            Description  = 'Holds all build related configuration along with this _init script'
            LocalPath    = (Join-Path $RepoPath '.build')
        },
        [InitPath]@{
            VariableName = 'RepoCodeDirectory'
            Path         = '.build'
            ChildPaths   = 'code'
            Description  = 'Used to store any custom code/scripts/modules'
            LocalPath    = (Join-Path $RepoPath '.build' 'code')
        }
    )

    Write-Debug ($PermanentPaths | Out-String)

    $EphemeralPaths = @(
        [InitPath]@{
            VariableName = 'RepoLogDirectory'
            Path         = '.log'
            Description  = 'Used to store build logs and output from Invoke-NativeCommand'
        },
        [InitPath]@{
            VariableName = 'RepoBuildOutputDirectory'
            Path         = '.build'
            ChildPaths   = 'output'
            Description  = 'Used to store any output from builds (e.g. Terraform plans, MSBuild artifacts etc)'
        },
        [InitPath]@{
            VariableName = 'RepoBinDirectory'
            Path         = '.bin'
            Description  = 'Used to store any downloaded binaries required for builds, cmdlets like Get-Vault make use of this variable'
        },
        [InitPath]@{
            VariableName = 'RepoTempDirectory'
            Path = '.tmp'
            Description = 'Used to store temporary files created for builds/tests'
        }
    )

    Write-Debug ($EphemeralPaths | Out-String)

    # Create the permanent paths
    $PermanentPaths | ForEach-Object {
        if (!(Test-Path $_.LocalPath))
        {
            try
            {
                New-Item $_.LocalPath -ItemType Directory | Out-Null
            }
            catch
            {
                throw "Failed to created directory $($_.LocalPath).`n$($_.Exception.Message)"
            }
        }
    }

    # gitignore the ephemeral paths
    $GitIgnorePath = Join-Path $RepoPath '.gitignore'
    $GitIgnoreItems = @(
        'paket.lock',
        'packages/',
        'paket-files/',
        '.tmp/'
    )
    $EphemeralPaths | ForEach-Object {
        if ($_.ChildPaths)
        {
            $GitIgnoreItems += "$($_.Path)/$($_.ChildPaths -join '/')/"
        }
        else
        {
            $GitIgnoreItems += "$($_.Path)/"
        }
    }
    Write-Debug ".gitignore items:`n$($GitIgnoreItems -join "`n")"
    # Create out .gitignore file if it doesn't exist
    if (!(Test-Path $GitIgnorePath))
    {
        Write-Verbose "Creating new .gitignore"
        try
        {
            New-Item $GitIgnorePath -ItemType File -Value ($GitIgnoreItems | Out-String) | Out-Null
        }
        catch
        {
            throw "Failed to create .gitignore.`n$($_.Exception.Message)"
        }    
    }
    else
    {
        # Read in the gitignore and make sure that we have everything we need to ignore
        Write-Verbose "Checking contents of .gitignore"
        $GitIgnoreContent = Get-Content $GitIgnorePath
        $GitIgnoreItems | ForEach-Object {
            if ($GitIgnoreContent -notcontains $_)
            {
                Write-Verbose "Adding $_ to gitignore list"
                Add-Content $GitIgnorePath -Value "`n$_"
            }
        } 
    }

    # Create a local nuget.config
    $NugetConfigPath = Join-Path $RepoPath 'nuget.config'
    if (!(Test-Path $NugetConfigPath))
    {
        Write-Verbose "Creating new nuget.config"
        try
        {
            Invoke-NativeCommand `
                -FilePath 'dotnet' `
                -ArgumentList 'new','nugetconfig' `
                -WorkingDirectory $RepoPath `
                -SuppressOutput
        }
        catch
        {
            throw "Failed to create nuget.config.`n$($_.Exception.Message)"
        }
    }

    # Check if we already have a tools manifest and create if not
    $dotnetToolsPath = Join-Path $RepoPath '.config' 'dotnet-tools.json'
    if (!(Test-Path $dotnetToolsPath))
    {
        Write-Verbose "Creating new dotnet tool manifest"
        try
        {
            Invoke-NativeCommand `
                -FilePath 'dotnet' `
                -ArgumentList 'new', 'tool-manifest' `
                -WorkingDirectory $RepoPath `
                -SuppressOutput
        }
        catch
        {
            throw "Failed to create dotnet tool manifest.`n$($_.Exception.Message)"
        }
    }
    
    # Install/update paket
    $dotnetCommand = 'install'
    try
    {
        $PaketCheck = (Get-Content $dotnetToolsPath -Raw) -match '"paket"'
        if ($PaketCheck)
        {
            Write-Verbose "Paket already defined in manifest, will update if necessary"
            $dotnetCommand = 'update'
        }
    }
    catch
    {
        throw $_.Exception.Message
    }
    Write-Verbose "Will attempt to $dotnetCommand paket"
    try
    {
        Invoke-NativeCommand `
            -FilePath 'dotnet' `
            -ArgumentList "tool", "$dotnetCommand", "Paket" `
            -WorkingDirectory $RepoPath `
            -SuppressOutput
    }
    catch
    {
        throw "Failed to $dotnetCommand paket.`n$($_.Exception.Message)"
    }

    # Create/update paket.dependencies
    $PaketDependenciesPath = Join-Path $RepoPath 'paket.dependencies'
    $PaketSources = @('source https://api.nuget.org/v3/index.json')
    $PaketDependencies = 'nuget Brownserve.PSTools'
    if (!(Test-Path $PaketDependenciesPath))
    {
        Write-Verbose "Creating 'paket.dependencies'"
        $PaketDependenciesContent = "$($PaketSources -join "`n")`n$PaketDependencies"
        try
        {
            New-Item $PaketDependenciesPath -ItemType File -Value $PaketDependenciesContent | Out-Null
        }
        catch
        {
            throw "Failed to create paket.dependencies.`n$($_.Exception.Message)"
        }    
    }
    else
    {
        Write-Verbose "Updating 'paket.dependencies'"
        try
        {
            $PaketDependenciesContent = Get-Content $PaketDependenciesPath
            if ($PaketDependenciesContent -notcontains $PaketDependencies)
            {
                Add-Content $PaketDependenciesPath -Value $PaketDependencies
            }
            $PaketSources | ForEach-Object {
                if ($PaketDependenciesContent -notcontains $_)
                {
                    Add-Content $PaketDependenciesPath -Value $_
                }
            }
        }
        catch
        {
            throw $_.Exception.Message
        }

    }

    # Copy snippets
    if (!$ExcludeSnippets)
    {
        Write-Verbose 'Copying VSCode snippets'
        try
        {
            Copy-VSCodeFile -RepoPath $RepoPath -VSCodeFile 'brownserve-pstools.code-snippets'
        }
        catch
        {
            throw $_.Exception.Message
        }
    }

    # Copy our default workspace settings
    if (!$ExcludeVSCodeSettings)
    {
        Write-Verbose "Copying default VSCode workspace settings"
        try
        {
            Copy-VSCodeFile -RepoPath $RepoPath -VSCodeFile 'settings.json'
        }
        catch
        {
            throw $_.Exception.Message
        }
    }

    # Copy devcontainer
    if ($IncludeDevcontainer)
    {
        Write-Verbose "Copying default devcontainer"
        try
        {
            Copy-VSCodeDevcontainer `
                -RepoPath $RepoPath            
        }
        catch
        {
            throw "Failed to set-up devcontainer.`n$($_.Exception.Message)"
        }
    }

    # Create the _init script
    Write-Verbose "Creating _init.ps1"
    $InitScriptParams = @{
        PermanentPaths  = $PermanentPaths
        EphemeralPaths  = $EphemeralPaths
        CustomInitSteps = $FinalCustomInitSteps
    }
    if ($ExcludeModuleLoader -eq $false)
    {
        $InitScriptParams.Add('IncludeModuleLoader', $true)
    }
    try
    {
        $InitScriptContent = New-BrownserveInitScript @InitScriptParams
        New-Item $InitPath -Value $InitScriptContent -Force -Confirm:$false | Out-Null
    }
    catch
    {
        throw "Failed to create _init script.`n$($_.Exception.Message)"
    }
    Write-Host "$RepoPath has been successfully set-up to work with Brownserve.PSTools! 🎉" -ForegroundColor Green
}