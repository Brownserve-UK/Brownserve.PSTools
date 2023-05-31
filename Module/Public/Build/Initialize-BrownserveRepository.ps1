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

        # The config file to use that stores our permanent/ephemeral path configuration
        [Parameter(Mandatory = $false, DontShow)]
        [string]
        $RepositoryPathsConfigFile = (Join-Path $Script:BrownservePSToolsConfigDirectory 'repository_paths_config.json'),

        # The config file that stores devcontainer configurations
        [Parameter(Mandatory = $false, DontShow)]
        [string]
        $DevcontainerConfigFile = (Join-Path $Script:BrownservePSToolsConfigDirectory 'devcontainer_config.json'),

        # The config file that stores VS Code extension configuration
        [Parameter(Mandatory = $false, DontShow)]
        [string]
        $VSCodeExtensionsConfigFile = (Join-Path $Script:BrownservePSToolsConfigDirectory 'repository_vscode_extensions.json')

        #TODO: Create a changelog and licence automagically?
    )
    
    begin
    {
        # Ensure that dotnet is available for us to use, we need it to instal tooling and make our nuget.config
        try
        {
            $RequiredTools = @('git', 'dotnet')
            Write-Verbose 'Checking for required tooling'
            Assert-Command $RequiredTools
        }
        catch
        {
            throw "$($_.Exception.Message)`nThese tools are required to configure a Brownserve repository."
        }

        # Ensure the config files are valid
        try
        {
            $GitIgnoreConfig = Read-ConfigurationFromFile $GitIgnoreConfigFile
            $PaketDependenciesConfig = Read-ConfigurationFromFile $PaketDependenciesConfigFile
            $RepositoryPathsConfig = Read-ConfigurationFromFile $RepositoryPathsConfigFile
            $DevcontainerConfig = Read-ConfigurationFromFile $DevcontainerConfigFile
            $VSCodeExtensionsConfig = Read-ConfigurationFromFile $VSCodeExtensionsConfigFile -AsHashtable
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

        # 
        $PathsToTest = @($InitPath, $GitIgnorePath, $PaketDependenciesPath, $dotnetToolsPath, $NugetConfigPath)
        if (!$Force)
        {
            $FailedPaths = @()
            $PathsToTest | ForEach-Object {
                if ((Test-Path $_))
                {
                    $FailedPaths += $_
                }
            }
            if ($FailedPaths.Count -gt 0)
            {
                $ErrorMessage = @"
The following files have been detected within the repository:
 * $($FailedPaths -join "`n * ")
This may mean that the repository has previously been initialized by this cmdlet, if so please use 'Update-BrownserveRepository' to update the project.
If this is not the case and these files have been created manually or by some other means then please use the '-Force' parameter to continue initializing this project.
However please note this will overwrite the files listed above!
"@
                Write-Error $ErrorMessage -ErrorAction 'Stop'
            }
        }
        else
        {
            # TODO: Confirm?
            Write-Warning 'Forcing overwrite.'
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

        # Make sure we're running on a branch and do that before looking at or touching any files on disk
        $TempBranchName = 'brownserve_repo_init'
        if ($CurrentBranch -ne $TempBranchName)
        {
            Write-Debug "Current branch: $CurrentBranch"
            # Check to see if we've already got the branch available to use
            try
            {
                $LocalBranches = Get-GitBranches `
                    -RepositoryPath $RepoPath `
                    -ErrorAction 'Stop'
            }
            catch
            {
                # Let this silently fail and just try and create the branch anyways
                Write-Debug "Get-GitBranches has failed with $($_.Exception.Message).`nIgnoring"
            }
            if ($LocalBranches -contains $TempBranchName)
            {
                Write-Verbose "'$TempBranchName' already exists, attempting to checkout"
                try
                {
                    Switch-GitBranch `
                        -RepositoryPath $RepoPath `
                        -BranchName $TempBranchName `
                        -ErrorAction 'Stop'
                }
                catch
                {
                    throw "The branch '$TempBranchName' already exists but git was unable to checkout this branch.`n$($_.Exception.Message)"
                }
            }
            else
            {
                Write-Verbose "Creating new branch '$TempBranchName'"
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
            We often recommend the use of various VS Code extensions with our projects. There may already
            be some settings in the repo as well, we should try and preserve those as best we can.
        #>
        try
        {
            $VSCodeWorkspaceExtensionIDs = Get-VSCodeWorkspaceExtensions -WorkspacePath $RepoPath -ErrorAction 'Stop'
        }
        catch [BrownserveFileNotFound]
        {
            # Repo probably doesn't have the extensions.json file yet, so we'll create an empty array for storing the extension ID's we need
            $VSCodeWorkspaceExtensionIDs = @()
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
            Write-Verbose 'No VS Code settings.json file found, creating an empty list'
            # Repo probably doesn't have the settings.json file yet, so we'll create an empty hashtable
            $VSCodeWorkspaceSettings = [ordered]@{}
        }
        catch
        {
            throw "Failed to get existing VSCode settings.`n$($_.Exception.Message)"
        }

        <# 
            We may already have a .gitignore in the repo it's unlikely to be in the format we expect it to be in.
            We'll try to read it anyways and just in case.
        #>
        if (Test-Path $GitIgnorePath)
        {
            try
            {
                $ManualGitIgnores = Search-FileContent `
                    -FilePath $GitIgnorePath `
                    -StartStringPattern '\#\# Manually defined ignores\: \#\#' `
                    -AsString `
                    -ErrorAction 'Stop'
            }
            catch
            {
                $ErrorMessage = "Failed to search '$GitIgnorePath' for manual entries.`n$($_.Exception.Message)"
                if (!$Force)
                {
                    throw $ErrorMessage
                }
                else
                {
                    # Do nothing, we'll overwrite
                    # Write-Warning $ErrorMessage
                }
            }
        }
        
        # Similarly for paket packages
        if (Test-Path $PaketDependenciesPath)
        {
            try
            {
                $ManualPaketEntries = Search-FileContent `
                    -FilePath $PaketDependenciesPath `
                    -StartStringPattern '\#\# Manually defined dependencies\: \#\#' `
                    -AsString `
                    -ErrorAction 'Stop'
            }
            catch
            {
                $ErrorMessage = "Failed to search '$PaketDependenciesPath' for manual entries.`n$($_.Exception.Message)"
                if (!$Force)
                {
                    throw $ErrorMessage
                }
                else
                {
                    # Do noting
                    # Write-Warning $ErrorMessage
                }
                 
            }
        }
        
        # And for any custom _init.ps1 steps
        if (Test-Path $InitPath)
        {
            try
            {
                $CustomInitSteps = Search-FileContent `
                    -FilePath $InitPath `
                    -StartStringPattern '\#\#\# Start user defined _init steps' `
                    -StopStringPattern '\#\#\# End user defined _init steps' `
                    -AsString `
                    -ErrorAction 'Stop'
            }
            catch
            {
                $ErrorMessage = "Failed to search '$InitPath' for custom init steps.`n$($_.Exception.Message)"
                if (!$Force)
                {
                throw $ErrorMessage
                }
                else
                {
                    # Do nothing
                    # Write-Warning $ErrorMessage
                }
            }
        }
        
        # Build up our default list of gitignore's that we always want to use
        # TODO: Do we want to make ignoring paket.lock optional?
        $DefaultGitIgnores = $GitIgnoreConfig.Defaults

        # Set-up the paket dependency that are common to all our projects
        $DefaultPaketDependencies = $PaketDependenciesConfig.Defaults

        # Careful -AsHashtable makes key names case sensitive when converted from JSON! (defaults != Defaults)
        $DefaultVSCodeExtensions = $VSCodeExtensionsConfig.Defaults

        switch ($BuildType)
        {
            'PowerShellModule'
            {
                Write-Debug 'PowerShell Module selected'
                # Check our configuration files for any special logic when working with PowerShell module repos
                $DockerfileName = $DevcontainerConfig.PowerShellModule.Dockerfile
                $ExtraPermanentPaths = $RepositoryPathsConfig.PowerShellModule.PermanentPaths
                $ExtraEphemeralPaths = $RepositoryPathsConfig.PowerShellModule.EphemeralPaths
                $ExtraPaketDeps = $PaketDependenciesConfig.PowerShellModule
                $ExtraGitIgnores = $GitIgnoreConfig.PowerShellModule
                $ExtraVSCodeExtensions = $VSCodeExtensionsConfig.PowerShellModule
                <# 
                    For a repo that houses a PowerShell module we'll want to include:
                        - The logic for loading the module as part of the _init script
                        - PlatyPS for building module documentation
                        - powershell-yaml for working with CI/CD files
                        - Invoke-Build/Pester for building and testing the module
                #>
                $InitParams = @{
                    IncludeModuleLoader   = $true
                    IncludePowerShellYaml = $true
                    IncludePlatyPS        = $true
                    IncludeBuildTestTools = $true
                }
            }
            Default
            {}
        }

        if ($DockerfileName)
        {
            $DevcontainerParams = @{
                Dockerfile         = $DockerfileName
                RequiredExtensions = @()
            }
        }

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

        $InitParams.Add('PermanentPaths', $FinalPermanentPaths)
        $InitParams.Add('EphemeralPaths', $FinalEphemeralPaths)

        if ($ExtraGitIgnores)
        {
            $FinalGitIgnores = $DefaultGitIgnores + $ExtraGitIgnores
        }
        else
        {
            $FinalGitIgnores = $DefaultGitIgnores
        }

        $GitIgnoreParams = @{
            GitIgnores = $FinalGitIgnores
        }
        if ($ManualGitIgnores)
        {
            $GitIgnoreParams.Add('ManualGitIgnores', $ManualGitIgnores)
        }

        if ($ExtraPaketDeps)
        {
            $FinalPaketDependencies = $DefaultPaketDependencies + $ExtraPaketDeps
        }
        else
        {
            $FinalPaketDependencies = $DefaultPaketDependencies
        }
        $PaketParams = @{
            PaketDependencies = $FinalPaketDependencies
        }
        if ($ManualPaketEntries)
        {
            $PaketParams.Add('ManualDependencies', $ManualPaketEntries)
        }

        if ($CustomInitSteps)
        {
            $InitParams.Add('CustomInitSteps', $CustomInitSteps)
        }

        if ($ExtraVSCodeExtensions)
        {
            $VSCodeExtensions = $DefaultVSCodeExtensions + $ExtraVSCodeExtensions
        }
        else
        {
            $VSCodeExtensions = $DefaultVSCodeExtensions
        }
        
        if ($VSCodeExtensions.Count -gt 0)
        {
            # Extract the list of extension ID's we want to install in this repo and clean up any duplicates
            $VSCodeWorkspaceExtensionIDs += $VSCodeExtensions.ExtensionID
            $VSCodeWorkspaceExtensionIDs = $VSCodeWorkspaceExtensionIDs | Select-Object -Unique

            <#
                Due to the way we store the VS Code settings in our config file, they end up clumping together in an array
                when we expand the object property.
                We need a single hash to be able to create the settings.json file correctly.
                By far the easiest method is to pass our array of Hashtable's to the Merge-Hashtable cmdlet with a blank hashtable
                We specify -Deep as we can specify the same extension settings multiple times (e.g. spellings)
            #>
            try
            {
                $VSCodeExtensionSettings = Merge-Hashtable `
                    -BaseObject @{} `
                    -InputObject $VSCodeExtensions.CustomSettings `
                    -Deep `
                    -ErrorAction 'Stop'
            }
            catch
            {
                throw "Failed to convert VS Code extension settings to hashtable.`n$($_.Exception.Message)"
            } 
            <#
                Check to see if the repository already has any VS Code settings - it affects the order of the hash merge
                Our Merge-Hashtable cmdlet will overwrite the keys of the base object with the input object if there is a clash
                if -Force has been passed then the user is happy to overwrite any settings that already exist in the repo.
                If not we should try and preserve them by using the repo settings as the input object
            #>
            if ($VSCodeWorkspaceSettings.Count -gt 0)
            {
                $MergeParams = @{
                    BaseObject  = $VSCodeWorkspaceSettings
                    InputObject = $VSCodeExtensionSettings
                }
                if (!$Force)
                {
                    $MergeParams = @{
                        BaseObject  = $VSCodeExtensionSettings
                        InputObject = $VSCodeWorkspaceSettings
                    }
                }
                try
                {
                    $VSCodeWorkspaceSettings = Merge-Hashtable `
                        @MergeParams `
                        -Deep `
                        -ErrorAction 'Stop'
                }
                catch
                {
                    throw "Failed to merge repository VS code settings.`n$($_.Exception.Message)"
                }
            }
            else
            {
                $VSCodeWorkspaceSettings = $VSCodeExtensionSettings
            }
            # Order the resulting settings hashtable, it makes it easier to find settings if they are grouped together.
            $VSCodeWorkspaceSettings = ConvertTo-SortedHashtable $VSCodeWorkspaceSettings
        }

        

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
            $DevcontainerParams.RequiredExtensions = $VSCodeWorkspaceExtensionIDs
            try
            {
                $Devcontainer = New-VSCodeDevContainer @DevcontainerParams -ErrorAction 'Stop'
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
                        Path                = $RepoPath
                        ChildPath           = $_.Path
                        AdditionalChildPath = $_.ChildPaths
                    }
                }
                else
                {
                    $JoinPathParams = @{
                        Path      = $RepoPath
                        ChildPath = $_.Path
                    }
                }
                New-Item `
                    -Path (Join-Path @JoinPathParams) `
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
            New-Item `
                -Path $InitPath `
                -Value $InitScriptContent `
                -ItemType File `
                -Force:$Force | Out-Null
        }
        catch
        {
            throw "Failed to write '$InitPath'.`n$($_.Exception.Message)"
        }

        try
        {
            New-Item `
                -Path $GitIgnorePath `
                -ItemType File `
                -Value $GitIgnoresContent `
                -Force:$Force | Out-Null
        }
        catch
        {
            throw "Failed to write '$GitIgnorePath'.`n$($_.Exception.Message)"
        }

        if (!(Test-Path $VSCodePath))
        {
            try
            {
                New-Item `
                    -Path $VSCodePath `
                    -ItemType Directory `
                    -ErrorAction 'Stop' | Out-Null
            }
            catch
            {
                throw "Failed to create VSCode directory.`n$($_.Exception.Message)"
            }
        }

        try
        {
            $VSCodeWorkspaceExtensionIDsJSON = ConvertTo-Json `
                -InputObject @{ recommendations = $VSCodeWorkspaceExtensionIDs } `
                -Depth 100 `
                -ErrorAction 'Stop'
            New-Item `
                -Path $VSCodeExtensionsFilePath `
                -ItemType File `
                -Value $VSCodeWorkspaceExtensionIDsJSON `
                -Force:$Force | Out-Null
        }
        catch
        {
            throw "Failed to create '$VSCodeExtensionsFilePath'.`n$($_.Exception.Message)"
        }

        try
        {
            $VSCodeWorkspaceSettingsJSON = ConvertTo-Json `
                -InputObject $VSCodeWorkspaceSettings `
                -Depth 100 `
                -ErrorAction 'Stop'
            New-Item `
                -Path $VSCodeWorkspaceSettingsFilePath `
                -ItemType File `
                -Value $VSCodeWorkspaceSettingsJSON `
                -Force:$Force | Out-Null
        }
        catch
        {
            throw "Failed to create '$VSCodeWorkspaceSettingsFilePath'.`n$($_.Exception.Message)"
        }

        if ($PaketDependenciesContent)
        {
            try
            {
                New-Item `
                    -Path $PaketDependenciesPath `
                    -ItemType File `
                    -Value $PaketDependenciesContent `
                    -Force:$Force | Out-Null
            }
            catch
            {
                throw "Failed to write '$PaketDependenciesPath'.`n$($_.Exception.Message)"
            }
        }

        if ($Devcontainer)
        {
            try
            {
                New-Item `
                    -Path $DevcontainerDirectoryPath `
                    -ItemType Directory `
                    -Force:$Force `
                    -ErrorAction 'Stop' | Out-Null
            }
            catch
            {
                throw "Failed to create '$DevcontainerDirectoryPath'"
            }

            try
            {
                New-Item `
                    -Path $DevcontainerPath `
                    -ItemType File `
                    -Value $Devcontainer.Devcontainer `
                    -ErrorAction 'Stop' `
                    -Force:$Force | Out-Null
            }
            catch
            {
                throw "Failed to create '$DevcontainerPath'.`n$($_.Exception.Message)"
            }

            try
            {
                New-Item `
                    -Path $DockerfilePath `
                    -ItemType File `
                    -Value $Devcontainer.Dockerfile `
                    -ErrorAction 'Stop' `
                    -Force:$Force | Out-Null
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