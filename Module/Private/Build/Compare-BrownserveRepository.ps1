<#
.SYNOPSIS
    Checks the current state of a repository to see if it is initialised correctly.
#>
function Compare-BrownserveRepository
{
    [CmdletBinding()]
    param
    (
        # The path to the repository
        [Parameter(Mandatory = $false, Position = 0)]
        [string]
        $RepoPath = (Get-Location),

        # The type of build that should be installed in this repo
        # TODO: Rename to RepositoryType
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [BrownserveRepoProjectType]
        $ProjectType = 'generic',

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
        $VSCodeExtensionsConfigFile = (Join-Path $Script:BrownservePSToolsConfigDirectory 'repository_vscode_extensions.json'),

        # The config file that stores any package aliases we'd like to create
        [Parameter(Mandatory = $false, DontShow)]
        [string]
        $PackageAliasConfigFile = (Join-Path $Script:BrownservePSToolsConfigDirectory 'package_aliases_config.json'),

        # The config file that stores any editorconfig settings we'd like to create
        [Parameter(Mandatory = $false, DontShow)]
        [string]
        $EditorConfigConfigFile = (Join-Path $Script:BrownservePSToolsConfigDirectory 'editorconfig_config.json')
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
            $PackageAliasConfig = Read-ConfigurationFromFile $PackageAliasConfigFile
            # Load VS code extensions as a hashtable so we can easily merge things later on
            $VSCodeExtensionsConfig = Read-ConfigurationFromFile $VSCodeExtensionsConfigFile -AsHashtable
            # Load EditorConfig as a hashtable as our [EditorConfigSection] type cannot process psobject's
            $EditorConfigConfig = Read-ConfigurationFromFile $EditorConfigConfigFile -AsHashtable
        }
        catch
        {
            throw "Failed to import configuration data.`n$($_.Exception.Message)"
        }
    }
    process
    {
        # Ensure we have a valid repository path
        Assert-Directory $RepoPath -ErrorAction 'Stop'

        <#
            The point of this cmdlet is to check the state of a given repository and ensure it's configured correctly.
            Therefore we can end up in a few different states:
                - The repository is already configured correctly
                - The repository is missing some files
                - Some managed files exist but require updating/changing
                - Some managed files already exist but are in a format we can't parse (likely manually created or modified)
        #>
        $UnParsableFiles = @()
        $MissingFiles = @()
        $ChangedFiles = @()
        $MissingDirectories = @()

        <#
            The below paths will always be required regardless of the type of repository we're working with.
        #>
        $ManifestPath = Join-Path $RepoPath '.brownserve_repository_manifest'
        $BuildDirectory = Join-Path $RepoPath '.build'
        $InitPath = Join-Path $BuildDirectory '_init.ps1'
        $PaketDependenciesPath = Join-Path $RepoPath 'paket.dependencies'
        $dotnetToolsConfigPath = Join-Path $RepoPath '.config'
        $dotnetToolsPath = Join-Path $dotnetToolsConfigPath 'dotnet-tools.json'
        $NugetConfigPath = Join-Path $RepoPath 'nuget.config'
        $GitIgnorePath = Join-Path $RepoPath '.gitignore'

        # These paths may or may not be required depending on the type of repository we're working with
        $VSCodePath = Join-Path $RepoPath '.vscode'
        $VSCodeExtensionsFilePath = Join-Path $VSCodePath 'extensions.json'
        $VSCodeWorkspaceSettingsFilePath = Join-Path $VSCodePath 'settings.json'
        $DevcontainerDirectoryPath = Join-Path $RepoPath '.devcontainer'
        $DevcontainerPath = Join-Path $DevcontainerDirectoryPath 'devcontainer.json'
        $DockerfilePath = Join-Path $DevcontainerDirectoryPath 'Dockerfile'
        $EditorConfigPath = Join-Path $RepoPath '.editorconfig'

        <#
            To help with consistency we store a special manifest file in the repository that contains some basic information
            about the repository. (Right now we just use it to store the type of repository we're working with.)
        #>
        if ((Test-Path $ManifestPath))
        {
            try
            {
                $CurrentManifest = Get-Content -Path $ManifestPath -ErrorAction 'Stop' | ConvertFrom-Json -Depth 100
            }
            catch
            {
                throw "Failed to read repository manifest file.`n$($_.Exception.Message)"
            }

            # Check to see if the repository type is the same as the one we're trying to configure, if it's not
            # then fail unless -Force has been passed.
            if ($CurrentManifest.RepositoryType -ne $ProjectType -and !$Force)
            {
                throw "Repository type mismatch. Expected '$ProjectType' but found '$($CurrentManifest.RepositoryType)'"
            }
            # Fail if the repository type is not present in the manifest file
            if (!$CurrentManifest.RepositoryType)
            {
                throw "Repository type not found in manifest file."
            }
        }


        <#
            Because we don't want to make any changes to the repository until we're sure we can do so safely,
            we'll create a temporary directory to stage all our files in.
        #>
        try
        {
            $TempDir = New-BrownserveTemporaryDirectory
        }
        catch
        {
            throw "Failed to create temporary directory.`n$($_.Exception.Message)"
        }
        <#
            Our config file contains a list of permanent paths that should always be created in a repository.
            They survive between init's and are not gitignored.
        #>
        $DefaultPermanentPaths = $RepositoryPathsConfig.Defaults.PermanentPaths
        Write-Debug "DefaultPermanentPaths: $($DefaultPermanentPaths | Out-String)"

        <#
            Our config file may contain a list of ephemeral paths that get created when the _init script is run.
            They are deleted between init's and are commonly gitignored.
        #>
        $DefaultEphemeralPaths = $RepositoryPathsConfig.Defaults.EphemeralPaths
        Write-Debug "DefaultEphemeralPaths: $($DefaultEphemeralPaths | Out-String)"

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
            <#
                Repo probably doesn't have the extensions.json file yet
                so we'll create an empty array for storing any extension ID's we might need later.
            #>
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
            <#
                Repo probably doesn't have the settings.json file yet, so we'll create an empty hashtable
                that we can add any VS Code settings to later.
            #>
            $VSCodeWorkspaceSettings = [ordered]@{}
        }
        catch
        {
            throw "Failed to get existing VS Code settings.`n$($_.Exception.Message)"
        }

        <#
            Check for the presence of any managed files in the repo, they may already exist if this repo has been configured before.
            They may contain manual entries that we should try and preserve.
            However it's also entirely possible that these files were created before we started using this cmdlet and
            they may not be in a format we can parse, if this is the case we'll add them to the list of unparsable files.
        #>
        if (Test-Path $GitIgnorePath)
        {
            Write-Verbose 'Parsing existing .gitignore file.'
            try
            {
                $CurrentGitIgnores = Get-BrownserveContent -Path $GitIgnorePath -ErrorAction 'Stop'
                $ManualGitIgnores = $CurrentGitIgnores |
                    Select-BrownserveContent -After '## Manually defined ignores: ##' -FailIfNotFound
            }
            catch
            {
                $UnParsableFiles += $GitIgnorePath
            }
        }
        # Similarly for paket packages
        if (Test-Path $PaketDependenciesPath)
        {
            Write-Verbose 'Parsing existing paket.dependencies file.'
            try
            {
                $ManualPaketEntries = Get-BrownserveContent -Path $PaketDependenciesPath |
                    Select-BrownserveContent -After '## Manually defined dependencies: ##' -FailIfNotFound
            }
            catch
            {
                $UnParsableFiles += $PaketDependenciesPath
            }
        }
        # And for any custom _init.ps1 steps
        if (Test-Path $InitPath)
        {
            Write-Verbose 'Parsing existing _init.ps1 file.'
            try
            {
                $CurrentInitContent = Get-BrownserveContent -Path $InitPath -ErrorAction 'Stop'
                $CustomInitSteps = $CurrentInitContent |
                    Select-BrownserveContent `
                        -After '### Start user defined _init steps' `
                        -Before '### End user defined _init steps' `
                        -FailIfNotFound
            }
            catch
            {
                $UnParsableFiles += $InitPath
            }
        }

        # Build up our default list of gitignore's that we always want to use
        # TODO: Do we want to make ignoring paket.lock optional?
        $DefaultGitIgnores = $GitIgnoreConfig.Defaults

        # Set-up the paket dependency that are common to all our projects
        $DefaultPaketDependencies = $PaketDependenciesConfig.Defaults

        # Careful -AsHashtable makes key names case sensitive when converted from JSON! (defaults != Defaults)
        $DefaultVSCodeExtensions = $VSCodeExtensionsConfig.Defaults

        $DefaultPackageAliases = $PackageAliasConfig.Defaults

        $DefaultEditorConfig = $EditorConfigConfig.Defaults

        # We don't use a config file to create the manifest file as it's a simple object
        $NewManifest = @{
            RepositoryType = $ProjectType
            ManifestVersion = '1.0.0'
        }

        switch ($ProjectType)
        {
            <#
                For a repo that houses a PowerShell module we'll want to include:
                    - The logic for loading the module as part of the _init script
                    - PlatyPS for building module documentation
                    - powershell-yaml for working with CI/CD files
                    - Invoke-Build/Pester for building and testing the module
            #>
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
                $ExtraPackageAliases = $PackageAliasConfig.PowerShellModule
                $ExtraEditorConfig = $EditorConfigConfig.PowerShellModule
                $InitParams = @{
                    IncludeModuleLoader   = $true
                    IncludePowerShellYaml = $true
                    IncludePlatyPS        = $true
                    IncludeBuildTestTools = $true
                }
            }
            <#
                For the repo that houses this very PowerShell module we want to do things a little differently.
                We avoid loading the Brownserve.PSTools module locally in _init.ps1 and use nuget as normal to get a stable version (this ensures that we can still get notified of failed builds)
                We can use our build to load the local version of the module.
            #>
            'BrownservePSTools'
            {
                Write-Debug 'BrownservePSTools selected'
                # For now we use the same basic config as all our other PowerShell modules except in the params below
                $DockerfileName = $DevcontainerConfig.PowerShellModule.Dockerfile
                $ExtraPermanentPaths = $RepositoryPathsConfig.PowerShellModule.PermanentPaths
                $ExtraEphemeralPaths = $RepositoryPathsConfig.PowerShellModule.EphemeralPaths
                $ExtraPaketDeps = $PaketDependenciesConfig.PowerShellModule
                $ExtraGitIgnores = $GitIgnoreConfig.PowerShellModule
                $ExtraVSCodeExtensions = $VSCodeExtensionsConfig.PowerShellModule
                $ExtraPackageAliases = $PackageAliasConfig.PowerShellModule
                $ExtraEditorConfig = $EditorConfigConfig.PowerShellModule
                $InitParams = @{
                    IncludeModuleLoader   = $false # we don't want to load the module locally, we want the stable version from nuget
                    IncludePowerShellYaml = $true
                    IncludePlatyPS        = $true
                    IncludeBuildTestTools = $true
                }
            }
            Default
            {
                Write-Debug 'Generic project type selected'
                # We always need the $InitParams hashtable otherwise we'll get a null-valued expression error
                $InitParams = @{
                    IncludeModuleLoader   = $false
                    IncludePowerShellYaml = $false
                    IncludePlatyPS        = $false
                    IncludeBuildTestTools = $false
                }
            }
        }

        if ($UnParsableFiles.Count -gt 0 -and !$Force)
        {
            {
                <#
                    Throw here, this allows us to give the user a list of files that need to be manually checked.
                    Then the user can either modify the files themselves or pass -Force to this cmdlet to overwrite them.
                #>
                throw "The following files already exist in the repository but are in a format that can't be parsed:`n$($UnParsableFiles -join "`n")"
            }
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
        if ($ExtraEphemeralPaths.Count -gt 0)
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
        if ($ExtraPackageAliases)
        {
            $FinalPackageAliases = $DefaultPackageAliases + $ExtraPackageAliases
        }
        else
        {
            $FinalPackageAliases = $DefaultPackageAliases
        }
        if ($FinalPackageAliases)
        {
            $InitParams.Add('PackageAliases', $FinalPackageAliases)
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

        if ($ExtraEditorConfig)
        {
            $FinalEditorConfig = $DefaultEditorConfig + $ExtraEditorConfig
        }
        else
        {
            $FinalEditorConfig = $DefaultEditorConfig
        }
        $EditorConfigParams = @{
            IncludeRoot = $true
            Section     = $FinalEditorConfig
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
                Due to the way we store the VS Code settings in our config file, they end up getting read out as an array
                when we expand the object property.
                However the cmdlet that creates the settings file expects a hashtable.
                By far the easiest method to convert this to a hashtable is to pass our array of Hashtable's to the
                Merge-Hashtable cmdlet as the InputObject with a blank hashtable as the BaseObject.
                This results in a hashtable being returned with the correct key/value pairs.
                We specify the -Deep parameter so a deep merge is performed, this ensures that any settings that already
                exist in the repo are preserved.
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
            <#
                Once we've merged the settings we like to ensure that they are sorted alphabetically.
                This ensures that the settings file is easier to read and also makes it easier to spot any discrepancies.
            #>
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

        if ($EditorConfigParams)
        {
            # Try to preserve any manual changes that may have been made to the editorconfig file
            if (Test-Path $EditorConfigPath)
            {
                try
                {
                    $ManualEditorConfig = Read-BrownserveEditorConfig -Path $EditorConfigPath -ErrorAction 'Stop'
                }
                catch
                {
                    # Let this silently fail and just try and create the editorconfig anyways
                    # (If we've got here then -Force has been passed so we should overwrite any existing editorconfig file)
                }
            }
            if ($ManualEditorConfig)
            {
                $EditorConfigParams.Add('ManualSection', $ManualEditorConfig)
            }
            try
            {
                $EditorConfigContent = New-BrownserveEditorConfig @EditorConfigParams -ErrorAction 'Stop'
            }
            catch
            {
                throw "Failed to create .editorconfig file content.`n$($_.Exception.Message)"
            }
        }
        $FinalPermanentPaths.GetEnumerator() | ForEach-Object {
            <#
                All paths should be relative to the repository root.
                The entry may contain child paths, hopefully the user has defined them in the correct order so that the parent
                always gets created first!
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
            $PathToCheck = Join-Path @JoinPathParams
            if (!(Test-Path $PathToCheck))
            {
                $MissingDirectories += [pscustomobject]@{
                    Path = $PathToCheck
                }
            }
        }

        <#
            Now that we've generated all the files for the repository we will compare them
            to any existing files in the repo.
            If the content matches then we don't need to do anything.
            If there's a difference then we'll add the file to the list of changed files.
            If the files don't exist at all then we'll add them to the list of missing files.

            We set the SyncWindow to 1 to try and make the comparison more readable.
            This should ensure that adding a new line to the template file would result in a single addition
            being reported against the DifferenceObject rather than an addition against the
            DifferenceObject and a removal against the ReferenceObject.
            Similarly if a line is removed from the template file we should only see a single removal
            against the ReferenceObject rather than a removal against the ReferenceObject and an addition
            against the DifferenceObject.

            Unfortunately there is no way to detect unexpected changes to any files already in the repo as there's no way to tell
            if the changes are the result of the template changing or if they were made manually.

            But any manual changes should be picked up by the user in the VCS diff.
        #>

        try
        {
            if (($CurrentManifest))
            {
                $ManifestCompare = Compare-Object `
                    -ReferenceObject $CurrentManifest `
                    -DifferenceObject $NewManifest `
                    -SyncWindow 1 `
                    -ErrorAction 'Stop'
                if ($ManifestCompare)
                {
                    $ChangedFiles += [pscustomobject]@{
                        Path       = $ManifestPath
                        Content    = $NewManifest
                        Comparison = $ManifestCompare
                    }
                }
            }
            else
            {
                $MissingFiles += [pscustomobject]@{
                    Path    = $ManifestPath
                    Content = $NewManifest
                }
            }
            if ((Test-Path $NugetConfigPath))
            {
                $CurrentNugetConfig = Get-BrownserveContent -Path $NugetConfigPath -ErrorAction 'Stop'
                $NewNugetConfig = Get-BrownserveContent -Path $NugetConfigTempPath -ErrorAction 'Stop'
                $NugetConfigCompare = Compare-Object `
                    -ReferenceObject $CurrentNugetConfig `
                    -DifferenceObject $NewNugetConfig `
                    -SyncWindow 1 `
                    -ErrorAction 'Stop'
                if ($NugetConfigCompare)
                {
                    $ChangedFiles += [pscustomobject]@{
                        Path       = $NugetConfigPath
                        Content    = $NewNugetConfig
                        Comparison = $NugetConfigCompare
                    }
                }
            }
            else
            {
                $MissingFiles += [pscustomobject]@{
                    Path    = $NugetConfigPath
                    Content = $NugetConfigTempPath
                }
            }
        }
        catch
        {
            throw "Failed to process '$NugetConfigPath'.`n$($_.Exception.Message)"
        }
        <#
            We don't perform any modifications to the dotnet tools manifest, so we'll just test for it's existence
        #>
        if (!(Test-Path $dotnetToolsConfigPath))
        {
            $MissingDirectories += [pscustomobject]@{
                Path = $dotnetToolsConfigPath
            }
        }
        if (!(Test-Path $dotnetToolsPath))
        {
            $MissingFiles += [pscustomobject]@{
                Path    = $dotnetToolsPath
                Content = $dotnetToolsTempPath
            }
        }

        if ($CurrentInitContent)
        {
            $InitCompare = Compare-Object `
                -ReferenceObject $CurrentInitContent `
                -DifferenceObject $InitScriptContent `
                -SyncWindow 1 `
                -ErrorAction 'Stop'
            if ($InitCompare)
            {
                $ChangedFiles += [pscustomobject]@{
                    Path       = $InitPath
                    Content    = $InitScriptContent
                    Comparison = $InitCompare
                }
            }
        }
        else
        {
            $MissingFiles += [pscustomobject]@{
                Path    = $InitPath
                Content = $InitScriptContent
            }
        }

        if ($GitIgnoresContent)
        {
            $GitIgnoreCompare = Compare-Object `
                -ReferenceObject $CurrentGitIgnores `
                -DifferenceObject $GitIgnoresContent `
                -SyncWindow 1 `
                -ErrorAction 'Stop'
            if ($GitIgnoreCompare)
            {
                $ChangedFiles += [pscustomobject]@{
                    Path       = $GitIgnorePath
                    Content    = $GitIgnoresContent
                    Comparison = $GitIgnoreCompare
                }
            }
        }
        else
        {
            $MissingFiles += [pscustomobject]@{
                Path    = $GitIgnorePath
                Content = $GitIgnoresContent
            }
        }

        try
        {
            $VSCodeWorkspaceExtensionIDsJSON = ConvertTo-Json `
                -InputObject @{ recommendations = $VSCodeWorkspaceExtensionIDs } `
                -Depth 100 `
                -ErrorAction 'Stop'
            if ((Test-Path $VSCodeExtensionsFilePath))
            {
                $CurrentVSCodeExtensions = Get-BrownserveContent -Path $VSCodeExtensionsFilePath -ErrorAction 'Stop'
                $VSCodeExtensionsCompare = Compare-Object `
                    -ReferenceObject $CurrentVSCodeExtensions `
                    -DifferenceObject $VSCodeWorkspaceExtensionIDsJSON `
                    -SyncWindow 1 `
                    -ErrorAction 'Stop'
                if ($VSCodeExtensionsCompare)
                {
                    $ChangedFiles += [pscustomobject]@{
                        Path       = $VSCodeExtensionsFilePath
                        Content    = $VSCodeWorkspaceExtensionIDsJSON
                        Comparison = $VSCodeExtensionsCompare
                    }
                }
            }
            else
            {
                $MissingFiles += [pscustomobject]@{
                    Path    = $VSCodeExtensionsFilePath
                    Content = $VSCodeWorkspaceExtensionIDsJSON
                }
            }
        }
        catch
        {
            throw "Failed to process '$VSCodeExtensionsFilePath'.`n$($_.Exception.Message)"
        }

        try
        {
            $VSCodeWorkspaceSettingsJSON = ConvertTo-Json `
                -InputObject $VSCodeWorkspaceSettings `
                -Depth 100 `
                -ErrorAction 'Stop'
            if ((Test-Path $VSCodeWorkspaceSettingsFilePath))
            {
                $CurrentVSCodeWorkspaceSettings = Get-BrownserveContent -Path $VSCodeWorkspaceSettingsFilePath -ErrorAction 'Stop'
                $VSCodeWorkspaceSettingsCompare = Compare-Object `
                    -ReferenceObject $CurrentVSCodeWorkspaceSettings `
                    -DifferenceObject $VSCodeWorkspaceSettingsJSON `
                    -SyncWindow 1 `
                    -ErrorAction 'Stop'
                if ($VSCodeWorkspaceSettingsCompare)
                {
                    $ChangedFiles += [pscustomobject]@{
                        Path       = $VSCodeWorkspaceSettingsFilePath
                        Content    = $VSCodeWorkspaceSettingsJSON
                        Comparison = $VSCodeWorkspaceSettingsCompare
                    }
                }
            }
            else
            {
                $MissingFiles += [pscustomobject]@{
                    Path    = $VSCodeWorkspaceSettingsFilePath
                    Content = $VSCodeWorkspaceSettingsJSON
                }
            }
        }
        catch
        {
            throw "Failed to process '$VSCodeWorkspaceSettingsFilePath'.`n$($_.Exception.Message)"
        }

        if ($PaketDependenciesContent)
        {
            try
            {
                if ((Test-Path $PaketDependenciesPath))
                {
                    $CurrentPaketDependencies = Get-BrownserveContent -Path $PaketDependenciesPath -ErrorAction 'Stop'
                    $PaketDependenciesCompare = Compare-Object `
                        -ReferenceObject $CurrentPaketDependencies `
                        -DifferenceObject $PaketDependenciesContent `
                        -SyncWindow 1 `
                        -ErrorAction 'Stop'
                    if ($PaketDependenciesCompare)
                    {
                        $ChangedFiles += [pscustomobject]@{
                            Path       = $PaketDependenciesPath
                            Content    = $PaketDependenciesContent
                            Comparison = $PaketDependenciesCompare
                        }
                    }
                }
                else
                {
                    $MissingFiles += [pscustomobject]@{
                        Path    = $PaketDependenciesPath
                        Content = $PaketDependenciesContent
                    }
                }
            }
            catch
            {
                throw "Failed to process '$PaketDependenciesPath'.`n$($_.Exception.Message)"
            }
        }

        if ($Devcontainer)
        {
            try
            {
                # Devcontainer can't exist if the parent directory doesn't exist!
                if ((Test-Path $DevcontainerDirectoryPath))
                {
                    if ((Test-Path $DevcontainerPath))
                    {
                        $CurrentDevcontainer = Get-BrownserveContent -Path $DevcontainerPath -ErrorAction 'Stop'
                        $DevcontainerCompare = Compare-Object `
                            -ReferenceObject $CurrentDevcontainer `
                            -DifferenceObject $Devcontainer.Devcontainer `
                            -SyncWindow 1 `
                            -ErrorAction 'Stop'
                        if ($DevcontainerCompare)
                        {
                            $ChangedFiles += [pscustomobject]@{
                                Path       = $DevcontainerPath
                                Content    = $Devcontainer.Devcontainer
                                Comparison = $DevcontainerCompare
                            }
                        }
                    }
                    else
                    {
                        $MissingFiles += [pscustomobject]@{
                            Path    = $DevcontainerPath
                            Content = $Devcontainer.Devcontainer
                        }
                    }
                }
                else
                {
                    $MissingDirectories += [pscustomobject]@{
                        Path = $DevcontainerDirectoryPath
                    }
                    $MissingFiles += [pscustomobject]@{
                        Path    = $DevcontainerPath
                        Content = $Devcontainer.Devcontainer
                    }
                }
            }
            catch
            {
                throw "Failed to process '$DevcontainerDirectoryPath'"
            }

            try
            {
                if ((Test-Path $DockerfilePath))
                {
                    $CurrentDockerfile = Get-BrownserveContent -Path $DockerfilePath -ErrorAction 'Stop'
                    $DockerfileCompare = Compare-Object `
                        -ReferenceObject $CurrentDockerfile `
                        -DifferenceObject $Devcontainer.Dockerfile `
                        -SyncWindow 1 `
                        -ErrorAction 'Stop'
                    if ($DockerfileCompare)
                    {
                        $ChangedFiles += [pscustomobject]@{
                            Path       = $DockerfilePath
                            Content    = $Devcontainer.Dockerfile
                            Comparison = $DockerfileCompare
                        }
                    }
                }
                else
                {
                    $MissingFiles += [pscustomobject]@{
                        Path    = $DockerfilePath
                        Content = $Devcontainer.Dockerfile
                    }
                }
            }
            catch
            {
                throw "Failed to process '$DockerfilePath'.`n$($_.Exception.Message)"
            }
        }

        if ($EditorConfigContent)
        {
            try
            {
                if ((Test-Path $EditorConfigPath))
                {
                    try
                    {
                        $CurrentEditorConfig = Get-BrownserveContent -Path $EditorConfigPath -ErrorAction 'Stop'
                        $EditorConfigCompare = Compare-Object `
                            -ReferenceObject $CurrentEditorConfig `
                            -DifferenceObject $EditorConfigContent `
                            -SyncWindow 1 `
                            -ErrorAction 'Stop'
                        if ($EditorConfigCompare)
                        {
                            $ChangedFiles += [pscustomobject]@{
                                Path       = $EditorConfigPath
                                Content    = $EditorConfigContent
                                Comparison = $EditorConfigCompare
                            }
                        }
                    }
                    catch
                    {
                        throw "Failed to process '$EditorConfigPath'.`n$($_.Exception.Message)"
                    }
                }
                else
                {
                    $MissingFiles += [pscustomobject]@{
                        Path    = $EditorConfigPath
                        Content = $EditorConfigContent
                    }
                }
            }
            catch
            {
                throw "Failed to process '$EditorConfigPath'.`n$($_.Exception.Message)"
            }
        }
    }
    end
    {
        # Return an object that contains all the information we've gathered
        $Return = [pscustomobject]@{
            MissingFiles       = $MissingFiles
            ChangedFiles       = $ChangedFiles
            MissingDirectories = $MissingDirectories
        }
        Return $Return
    }
}

