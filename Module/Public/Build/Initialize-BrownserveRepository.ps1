function Initialize-BrownserveRepository
{
    [CmdletBinding()]
    param
    (
        # The path to the repository
        [Parameter(Mandatory = $true, Position = 0)]
        [string]
        $RepoPath,

        # The type of build that should be installed in this repo
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [BrownserveRepoBuildType]
        $BuildType = 'generic',

        # Forces the recreation of files even if they already exist
        [Parameter(Mandatory = $false)]
        [switch]
        $Force,

        # The config file to use for setting our .gitignore content
        [Parameter(Mandatory = $false, DontShow)]
        [string]
        $GitIgnoreConfigFile = (Join-Path $Script:BrownservePSToolsConfigDirectory 'gitignore_config.json'),

        # The config file to use for setting our .gitignore content
        [Parameter(Mandatory = $false, DontShow)]
        [string]
        $PaketDependenciesConfigFile = (Join-Path $Script:BrownservePSToolsConfigDirectory 'paket_dependencies_config.json'),

        # The config file to use for setting our .gitignore content
        [Parameter(Mandatory = $false, DontShow)]
        [string]
        $RepositoryPathsConfigFile = (Join-Path $Script:BrownservePSToolsConfigDirectory 'repository_paths_config.json')

        #TODO: Create a changelog and licence automagically?
    )
    
    begin
    {
        # Ensure that dotnet is available for us to use, we need it to instal tooling and make our nuget.config
        try
        {
            $RequiredTools = @('git', 'dotnet')
            Write-Verbose 'Checking for required tooling'
            foreach ($Tool in $RequiredTools)
            {
                $Check = $null
                $Check = Get-Command $Tool -ErrorAction 'SilentlyContinue'
                if (!$Check)
                {
                    Write-Error "'$Tool' is not available on your path. This is required to configure a Brownserve repository"
                }
            }
    
        }
        catch
        {
            throw $_.Exception.Message
        }

        # Ensure the config files are valid
        try
        {
            $GitIgnoreConfig = Get-Content $GitIgnoreConfigFile -Raw | ConvertFrom-Json
            $PaketDependenciesConfig = Get-Content $PaketDependenciesConfigFile -Raw | ConvertFrom-Json
            $RepositoryPathsConfig = Get-Content $RepositoryPathsConfigFile -Raw | ConvertFrom-Json
        }
        catch
        {
            throw "Failed to import configuration data.`n$($_.Exception.Message)"
        }
    }
    
    process
    {
        Assert-Directory $RepoPath -ErrorAction 'Stop'

        # The below paths will always need to exist and we should check for them to avoid causing any mishaps even if we are going to do this on a branch
        $BuildDirectory = Join-Path $RepoPath '.build'
        $InitPath = Join-Path $BuildDirectory '_init.ps1'
        $PaketDependenciesPath = Join-Path $RepoPath 'paket.dependencies'
        $dotnetToolsConfigPath = Join-Path $RepoPath '.config'
        $dotnetToolsPath = Join-Path $dotnetToolsConfigPath 'dotnet-tools.json'
        $NugetConfigPath = Join-Path $RepoPath 'nuget.config'
        $GitIgnorePath = Join-Path $RepoPath '.gitignore'
        $VSCodePath = Join-Path $RepoPath '.vscode'
        $VSCodeExtensionsFilePath = Join-Path $VSCodePath 'extensions.json'
        $VSCodeWorkspaceSettingsFilePath = Join-Path $VSCodePath 'settings.json'
        $DevcontainerDirectoryPath = Join-Path $RepoPath '.devcontainer'
        $DevcontainerPath = Join-Path $DevcontainerDirectoryPath 'devcontainer.json'
        $DockerfilePath = Join-Path $DevcontainerDirectoryPath 'Dockerfile'

        $PathsToTest = @($InitPath, $PaketDependenciesPath, $dotnetToolsPath, $NugetConfigPath)
        if (!$Force)
        {
            $PathsToTest | ForEach-Object {
                if ((Test-Path $_))
                {
                    throw "It looks like this project has already been at least partially initialized as the path '$_' already exists.`nPlease use 'Update-BrownserveRepository' to update the project or the '-Force' parameter to forcefully overwrite the files."
                }
            }
        }
        else
        {
            # TODO: Confirm?
            Write-Warning 'Forcing overwrite.'
        }

        # Ensure we have a directory where we can create some staging files before writing them to the repo
        try
        {
            $TempDir = New-BrownserveTemporaryDirectory
        }
        catch
        {
            throw "Failed to create temporary directory.`n$($_.Exception.Message)"
        }

        # Create our list of permanent paths that should be sync'd to git and not deleted between init's
        $DefaultPermanentPaths = $RepositoryPathsConfig.Defaults.PermanentPaths

        # And our list of ephemeral paths that are gitignored and recreated between init's
        $DefaultEphemeralPaths = $RepositoryPathsConfig.Defaults.EphemeralPaths

        <#
            There may be various recommended extensions and/or VSCode settings we want to include. There may already
            be some settings in the repo as well, we should try and preserve those as best we can.
        #>
        try
        {
            $VSCodeRecommendedExtensions = Get-VSCodeRecommendedExtensions -WorkspacePath $RepoPath -ErrorAction 'Stop'
        }
        catch [BrownserveFileNotFound]
        {
            # Repo probably doesn't have a recommended extensions file yet, so we'll create a blank one
            $VSCodeRecommendedExtensions = @()
        }
        catch
        {
            throw "Failed to get existing recommended extensions.`n$($_.Exception.Message)"
        }

        try
        {
            $VSCodeWorkspaceSettings = Get-VSCodeWorkspaceSettings -WorkspacePath $RepoPath -ErrorAction 'Stop'
        }
        catch [BrownserveFileNotFound]
        {
            # Repo probably doesn't have a settings file yet, so we'll create a blank one
            $VSCodeWorkspaceSettings = [ordered]@{}
        }
        catch
        {
            throw "Failed to get existing VSCode settings.`n$($_.Exception.Message)"
        }

        # Check what branch we are on
        try
        {
            $CurrentBranch = Get-GitCurrentBranch -RepositoryPath $RepoPath
        }
        catch
        {
            throw $_.Exception.Message
        }

        # Make sure we're running on a branch
        $TempBranchName = 'brownserve_repo_init'
        if ($CurrentBranch -ne $TempBranchName)
        {
            Write-Verbose "Current branch is: $CurrentBranch. Creating $TempBranchName"
            try
            {
                New-GitBranch `
                    -RepositoryPath $RepoPath `
                    -BranchName $TempBranchName `
                    -Checkout $true `
                    -ErrorAction 'Stop'
            }
            catch
            {
                throw "Failed to create working branch.`n$($_.Exception.Message)"
            }
        }
        
        # Build up our default list of gitignore's that we always want to use
        # TODO: Do we want to make ignoring paket.lock optional?
        $DefaultGitIgnores = $GitIgnoreConfig.Defaults

        # Set-up the paket dependency that are common to all our projects
        $DefaultPaketDependencies = $PaketDependenciesConfig.Defaults

        switch ($BuildType)
        {
            'PowerShellModule'
            {
                
                # We'll want a devcontainer for developing PowerShell modules
                $DevcontainerParams = @{
                    Dockerfile         = 'Dockerfile_PowerShell'
                    RequiredExtensions = @()
                }

                $RequiredExtensions = @('SpellCheck', 'PowerShell', 'Markdown')

                $ExtraPermanentPaths = $RepositoryPathsConfig.PowerShellModule.PermanentPaths
                $ExtraEphemeralPaths = $RepositoryPathsConfig.PowerShellModule.EphemeralPaths

                if ($ExtraPermanentPaths)
                {
                    $FinalPermanentPaths = $DefaultPermanentPaths + $ExtraPermanentPaths
                }
                else
                {
                    $FinalPermanentPaths = $DefaultPermanentPaths
                }
                if ($ExtraEphemeralPaths)
                {
                    $FinalEphemeralPaths = $DefaultEphemeralPaths + $ExtraEphemeralPaths
                }
                else
                {
                    $FinalEphemeralPaths = $DefaultEphemeralPaths
                }
                <# 
                    For a repo that houses a PowerShell module we'll want to include:
                        - The logic for loading the module as part of the _init script
                        - PlatyPS for building module documentation
                        - powershell-yaml for working with CI/CD files
                        - Invoke-Build/Pester for building and testing the module
                #>
                $InitParams = @{
                    PermanentPaths        = $FinalPermanentPaths
                    EphemeralPaths        = $FinalEphemeralPaths
                    IncludeModuleLoader   = $true
                    IncludePowerShellYaml = $true
                    IncludePlatyPS        = $true
                    IncludeBuildTestTools = $true
                }
                # We shouldn't need any special git ignores
                $GitIgnoreParams = @{
                    GitIgnores = $DefaultGitIgnores
                }

                $ExtraPaketDeps = $PaketDependenciesConfig.PowerShellModule

                $PaketParams = @{
                    PaketDependencies = ($DefaultPaketDependencies + $ExtraPaketDeps)
                }

            }
            Default
            {}
        }

        #
        if ($RequiredExtensions)
        {
            $RequiredExtensionDetails = @()
            $RequiredExtensions | ForEach-Object {
                switch ($_)
                {
                    'PowerShell'
                    { 
                        $RequiredExtensionDetails += New-VSCodePowerShellExtensionConfig
                    }
                    'Markdown'
                    {
                        $RequiredExtensionDetails += New-VSCodeMarkdownExtensionConfig
                    }
                    'SpellCheck'
                    {
                        $RequiredExtensionDetails += New-VSCodeSpellingsExtensionConfig
                    }
                    Default
                    {
                        throw "Unhandled VSCode extension '$_'"
                    }
                }
            }
            # Add the extension ID's to the list of recommended extensions (we'll clean it up later)
            $VSCodeRecommendedExtensions += $RequiredExtensionDetails.ExtensionID
            # Go through each of the settings and make sure they don't already exist
            $RequiredExtensionDetails.Settings | ForEach-Object {
                $_.GetEnumerator() | ForEach-Object {
                    if ($VSCodeWorkspaceSettings.Keys -contains $_.Key)
                    {
                        if ($Force)
                        {
                            Write-Debug "Overwriting key: $($_.Key) with value: $($_.Value)"
                            $VSCodeWorkspaceSettings.($_.Key) = $_.Value
                        }
                        else
                        {
                            throw "This repo's VSCode settings already contains configuration for '$($_.Key)' to overwrite use -Force."
                        }
                    }
                    else
                    {
                        Write-Debug "Adding key: $($_.Key) with value: $($_.Value)"
                        $VSCodeWorkspaceSettings.Add($_.Key, $_.Value)
                    }
                }
            }
        }

        # Filter out any duplicate extensions
        $VSCodeRecommendedExtensions = $VSCodeRecommendedExtensions | Select-Object -Unique

        # Create the _init script as that will always be required
        try
        {
            $InitScriptContent = New-BrownserveInitScript @InitParams -ErrorAction 'Stop'
        }
        catch
        {
            throw "Failed to generate _init.ps1 content.`n$($_.Exception.Message)"
        }

        # The .gitignore file should always be required too
        try
        {
            $GitIgnoresContent = New-GitIgnoresFile @GitIgnoreParams -ErrorAction 'Stop'
        }
        catch
        {
            throw "Failed to generate .gitignore file.`n$($_.Exception.Message)"
        }

        # Again the nuget.config file will always be needed
        try
        {
            Invoke-NativeCommand `
                -FilePath 'dotnet' `
                -ArgumentList 'new', 'nugetconfig' `
                -WorkingDirectory $TempDir `
                -SuppressOutput
            $NugetConfigTempPath = Join-Path $TempDir 'nuget.config'
            if (!(Test-Path $NugetConfigTempPath))
            {
                Write-Error 'Cannot find staging nuget.config file.'
            }
        }
        catch
        {
            throw "Failed to generate nuget.config.`n$($_.Exception.Message)"
        }

        # As will the dotnet tools manifest
        try
        {
            $dotnetToolsConfigTempPath = Join-Path $TempDir '.config'
            $dotnetToolsTempPath = Join-Path $dotnetToolsConfigTempPath 'dotnet-tools.json'
            Invoke-NativeCommand `
                -FilePath 'dotnet' `
                -ArgumentList 'new', 'tool-manifest' `
                -WorkingDirectory $TempDir `
                -SuppressOutput
            Invoke-NativeCommand `
                -FilePath 'dotnet' `
                -ArgumentList 'tool', 'install', 'Paket' `
                -WorkingDirectory $TempDir `
                -SuppressOutput
            if (!(Test-Path $dotnetToolsTempPath))
            {
                Write-Error 'Cannot find staging dotnet tools manifest.'
            }
        }
        catch
        {
            throw "Failed to generate dotnet tools manifest.`n$($_.Exception.Message)"
        }

        # Paket may or may not be required
        if ($PaketParams)
        {
            try
            {
                $PaketDependenciesContent = New-PaketDependenciesFile @PaketParams -ErrorAction 'Stop'
            }
            catch
            {
                throw "Failed to generate paket.dependencies file.`n$($_.Exception.Message)"
            }
        }

        if ($DevcontainerParams)
        {
            $DevcontainerParams.RequiredExtensions = $VSCodeRecommendedExtensions
            try
            {
                $DevcontainerConfig = New-VSCodeDevContainer @DevcontainerParams -ErrorAction 'Stop'
            }
            catch
            {
                throw "Failed to create devcontainer.`n$($_.Exception.Message)"
            }
        }

        ## Only start creating paths/files if we've been successful up to this point
        # Create all our permanent paths first, other things may need to live under them
        try
        {
            $FinalPermanentPaths.GetEnumerator() | ForEach-Object {
                <#
                    All paths should be relative to the repository root.
                    The entry may contain child paths, hopefully the user has defined them in the correct order so the parent always gets created first!
                #>
                if ($_.ChildPaths)
                {
                    $JoinPathParams = @{
                        Path = $RepoPath
                        ChildPath = $_.Path
                        AdditionalChildPath = $_.ChildPaths
                    }
                }
                else
                {
                    $JoinPathParams = @{
                        Path = $RepoPath
                        ChildPath = $_.Path
                    }
                }
                New-Item `
                    -Path @JoinPathParams `
                    -ItemType 'Directory' `
                    -Force:$Force | Out-Null # I think these should _always_ be directories, but we may need to rethink this if not!
            }
        }
        catch
        {
            throw "Failed to create permanent paths.`n$($_.Exception.Message)"
        }

        # Now we have everything we need then we can start creating files on disk!
        try
        {
            Move-Item $NugetConfigTempPath -Destination $NugetConfigPath -Force:$Force | Out-Null
        }
        catch
        {
            throw "Failed to write '$NugetConfigPath'.`n$($_.Exception.Message)"
        }
        try
        {
            New-Item $dotnetToolsConfigPath -ItemType Directory -Force:$Force | Out-Null
            Move-Item $dotnetToolsTempPath -Destination $dotnetToolsPath -Force:$Force | Out-Null
        }
        catch
        {
            throw "Failed to write '$dotnetToolsPath'.`n$($_.Exception.Message)"
        }

        try
        {
            New-Item $InitPath -Value $InitScriptContent -ItemType File -Force:$Force | Out-Null
        }
        catch
        {
            throw "Failed to write '$InitPath'.`n$($_.Exception.Message)"
        }

        try
        {
            New-Item $GitIgnorePath -ItemType File -Value $GitIgnoresContent -Force:$Force | Out-Null
        }
        catch
        {
            throw "Failed to write '$GitIgnorePath'.`n$($_.Exception.Message)"
        }

        if (!(Test-Path $VSCodePath))
        {
            try
            {
                New-Item $VSCodePath -ItemType Directory -ErrorAction 'Stop' | Out-Null
            }
            catch
            {
                throw "Failed to create VSCode directory.`n$($_.Exception.Message)"
            }
        }

        try
        {
            $VSCodeRecommendedExtensionsJSON = ConvertTo-Json @{ recommendations = $VSCodeRecommendedExtensions } -ErrorAction 'Stop'
            New-Item $VSCodeExtensionsFilePath -ItemType File -Value $VSCodeRecommendedExtensionsJSON -Force:$Force | Out-Null
        }
        catch
        {
            throw "Failed to create '$VSCodeExtensionsFilePath'.`n$($_.Exception.Message)"
        }

        try
        {
            $VSCodeWorkspaceSettingsJSON = ConvertTo-Json $VSCodeWorkspaceSettings -ErrorAction 'Stop'
            New-Item $VSCodeWorkspaceSettingsFilePath -ItemType File -Value $VSCodeWorkspaceSettingsJSON -Force:$Force | Out-Null
        }
        catch
        {
            throw "Failed to create '$VSCodeWorkspaceSettingsFilePath'.`n$($_.Exception.Message)"
        }

        if ($PaketDependenciesContent)
        {
            try
            {
                New-Item -Path $PaketDependenciesPath -ItemType File -Value $PaketDependenciesContent -Force:$Force | Out-Null
            }
            catch
            {
                throw "Failed to write '$PaketDependenciesPath'.`n$($_.Exception.Message)"
            }
        }

        if ($DevcontainerConfig)
        {
            try
            {
                New-Item $DevcontainerDirectoryPath -ItemType Directory -Force:$Force -ErrorAction 'Stop' | Out-Null
            }
            catch
            {
                throw "Failed to create '$DevcontainerDirectoryPath'"
            }

            try
            {
                New-Item $DevcontainerPath -ItemType File -Value $DevcontainerConfig.Devcontainer -ErrorAction 'Stop' -Force:$Force | Out-Null
            }
            catch
            {
                throw "Failed to create '$DevcontainerPath'.`n$($_.Exception.Message)"
            }

            try
            {
                New-Item $DockerfilePath -ItemType File -Value $DevcontainerConfig.Dockerfile -ErrorAction 'Stop' -Force:$Force | Out-Null
            }
            catch
            {
                throw "Failed to create '$DockerfilePath'.`n$($_.Exception.Message)"
            }
        }
    }
    
    end
    {
        
    }
}