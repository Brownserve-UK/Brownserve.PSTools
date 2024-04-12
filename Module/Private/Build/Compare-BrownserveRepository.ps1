<#
.SYNOPSIS
    Checks the current state of a repository to see if it is initialised correctly.
.DESCRIPTION
    This cmdlet is pretty complex as we use it to test the state of a given repository on disk to see if it is
    correctly initialised depending on the type of project the repository houses.
    We don't want to modify any files on disk until we're sure we won't destroy any manual changes that may have
    been made.
    As such this cmdlet will compare the state of the files in the repository to a set of templates that we
    generate based on the type of project the repository houses, if the repository is missing any files or if
    the files are different to that of the templates then we'll add them to a list of files that need to be
    created or updated and return them to the calling process to be handled.
    Due to the complexities of comparing files with line endings and formatting we make heavy use of the various
    "*-BrownserveContent" cmdlets to ensure that we can accurately compare the files.
#>
function Compare-BrownserveRepository
{
    [CmdletBinding()]
    param
    (
        # The path to the repository
        [Parameter(Mandatory = $true, Position = 0)]
        [string]
        $RepositoryPath,

        # The owner of the repository
        [Parameter(Mandatory = $false)]
        [string]
        $Owner = 'Brownserve',

        # The type of build that should be installed in this repo
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [BrownserveRepoProjectType]
        $ProjectType = 'generic',

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
            $RequiredTools = @('dotnet')
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
        Assert-Directory $RepositoryPath -ErrorAction 'Stop'

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
            We type constrain these variables to ensure that we can easily add to them later on.
            In the past certain operations had a tendency to return a single string rather than an array of strings
            Which would cause issues when we converted them to JSON.
        #>
        [array]$VSCodeWorkspaceExtensionIDs = @()
        $VSCodeWorkspaceSettings = [ordered]@{}

        <#
            The below paths will always be required regardless of the type of repository we're working with.
        #>
        $ManifestPath = Join-Path $RepositoryPath '.brownserve_repository_manifest'
        $BuildDirectory = Join-Path $RepositoryPath '.build'
        $InitPath = Join-Path $BuildDirectory '_init.ps1'
        $PaketDependenciesPath = Join-Path $RepositoryPath 'paket.dependencies'
        $dotnetToolsConfigPath = Join-Path $RepositoryPath '.config'
        $dotnetToolsPath = Join-Path $dotnetToolsConfigPath 'dotnet-tools.json'
        $NugetConfigPath = Join-Path $RepositoryPath 'nuget.config'
        $GitIgnorePath = Join-Path $RepositoryPath '.gitignore'

        # These paths may or may not be required depending on the type of repository we're working with
        $VSCodePath = Join-Path $RepositoryPath '.vscode'
        $VSCodeExtensionsFilePath = Join-Path $VSCodePath 'extensions.json'
        $VSCodeWorkspaceSettingsFilePath = Join-Path $VSCodePath 'settings.json'
        $DevcontainerDirectoryPath = Join-Path $RepositoryPath '.devcontainer'
        $DevcontainerPath = Join-Path $DevcontainerDirectoryPath 'devcontainer.json'
        $DockerfilePath = Join-Path $DevcontainerDirectoryPath 'Dockerfile'
        $EditorConfigPath = Join-Path $RepositoryPath '.editorconfig'
        $ChangelogPath = Join-Path $RepositoryPath 'CHANGELOG.md'
        $LicensePath = Join-Path $RepositoryPath 'LICENSE'

        <#
            To help with consistency we store a special manifest file in the repository that contains some basic information
            about the repository. (Right now we just use it to store the type of repository we're working with.)
        #>
        if ((Test-Path $ManifestPath))
        {
            Write-Verbose "Found existing repository manifest file at '$ManifestPath'"
            try
            {
                $CurrentManifest = Get-Content -Path $ManifestPath -ErrorAction 'Stop' | ConvertFrom-Json -Depth 100 -AsHashtable
            }
            catch
            {
                throw "Failed to read repository manifest file.`n$($_.Exception.Message)"
            }

            # Check to see if the repository type is the same as the one we're trying to configure, if it's not
            # then fail unless -Force has been passed.
            if (($CurrentManifest.RepositoryType -ne $ProjectType) -and !$Force)
            {
                throw "Repository type mismatch. Expected '$ProjectType' but repository was previously configured as '$($CurrentManifest.RepositoryType)'.`nUse the '-Force' switch to overwrite the existing configuration."
            }
            # Fail if the repository type is not present in the manifest file
            if (!$CurrentManifest.RepositoryType)
            {
                throw 'Repository type not found in manifest file.'
            }
            Write-Debug "Repository type found in manifest file: $($CurrentManifest.RepositoryType)"
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

        <#
            Our config file may contain a list of ephemeral paths that get created when the _init script is run.
            They are deleted between init's and are commonly gitignored.
        #>
        $DefaultEphemeralPaths = $RepositoryPathsConfig.Defaults.EphemeralPaths

        <#
            We often recommend the use of various VS Code extensions with our projects. There may already
            be some settings in the repo as well, we should try and preserve those as best we can.
            N.B If the extensions.json file only contains a single key then it will be read as a string rather than an array
            so we use the += operator to ensure that we always end up adding any items to the array we created above.
        #>
        try
        {
            $VSCodeWorkspaceExtensionIDs += Get-VSCodeWorkspaceExtensions -WorkspacePath $RepositoryPath -ErrorAction 'Stop'
        }
        catch [BrownserveFileNotFound]
        {
            <#
                Repo probably doesn't have the extensions.json file yet
                Don't terminate as this is expected behaviour.
            #>
            Write-Verbose 'No VS Code extensions.json file found, using the empty array'
        }
        catch
        {
            throw "Failed to get existing recommended extensions.`n$($_.Exception.Message)"
        }

        try
        {
            $VSCodeWorkspaceSettings = Get-VSCodeWorkspaceSettings -WorkspacePath $RepositoryPath -ErrorAction 'Stop'
        }
        catch [BrownserveFileNotFound]
        {
            Write-Verbose 'No VS Code settings.json file found, using the empty dictionary'
            <#
                Repo probably doesn't have the settings.json file yet, We'll use the empty dictionary
                we created above.
            #>
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
        $NewManifest = [System.Management.Automation.OrderedHashtable]@{
            RepositoryType  = $ProjectType.ToString()
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
                $Changelog = $true
                $InitParams = @{
                    IncludeModuleLoader   = $true
                    IncludePowerShellYaml = $true
                    IncludePlatyPS        = $true
                    IncludeBuildTestTools = $true
                }
                $LicenseType = 'MIT'
            }
            <#
                For the repo that houses this very PowerShell module we want to do things a little differently.
                We avoid loading the Brownserve.PSTools module locally in _init.ps1 and use nuget as normal to get a stable version
                (this ensures that we can still get notified of failed builds)
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
                $Changelog = $true
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
            $NewInitScriptContent = New-BrownserveInitScript @InitParams -ErrorAction 'Stop'
        }
        catch
        {
            throw "Failed to generate _init.ps1 content.`n$($_.Exception.Message)"
        }

        # The .gitignore file should always be required too
        try
        {
            $NewGitIgnoresContent = New-GitIgnoresFile @GitIgnoreParams -ErrorAction 'Stop'
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
                $NewPaketDependenciesContent = New-PaketDependenciesFile @PaketParams -ErrorAction 'Stop'
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
                $NewEditorConfigContent = New-BrownserveEditorConfig @EditorConfigParams -ErrorAction 'Stop'
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
                    Path                = $RepositoryPath
                    ChildPath           = $_.Path
                    AdditionalChildPath = $_.ChildPaths
                }
            }
            else
            {
                $JoinPathParams = @{
                    Path      = $RepositoryPath
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

        # The type of license we use is dependent on the type of project we're working with
        # though in the future we may want to allow the user to override this.
        if ($LicenseType)
        {
            $NewLicenseContent = New-SPDXLicense `
                -LicenseType $LicenseType `
                -Owner $Owner `
                -ErrorAction 'Stop'
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
            $NewManifestJSON = (ConvertTo-Json $NewManifest -Depth 100 -ErrorAction 'Stop').Split("`n") -replace "`r",''
            if ($CurrentManifest)
            {
                Write-Verbose 'Checking for changes to repository manifest'
                $ManifestCompare = Compare-Object `
                    -ReferenceObject $CurrentManifest `
                    -DifferenceObject $NewManifest `
                    -SyncWindow 1 `
                    -ErrorAction 'Stop'
                if ($ManifestCompare)
                {
                    Write-Verbose 'Changes detected in repository manifest'
                    $ChangedFiles += [BrownserveContent]@{
                        Path       = $ManifestPath
                        Content    = $NewManifestJSON
                        LineEnding = 'LF'
                    }
                }
            }
            else
            {
                Write-Verbose 'No existing repository manifest found, will create a new one.'
                $MissingFiles += [BrownserveContent]@{
                    Path       = $ManifestPath
                    Content    = $NewManifestJSON
                    LineEnding = 'LF'
                }
            }
        }
        catch
        {
            throw "Failed to process '$ManifestPath'.`n$($_.Exception.Message)"
        }
        try
        {
            $NewNugetConfig = Get-BrownserveContent -Path $NugetConfigTempPath -ErrorAction 'Stop'
            if ((Test-Path $NugetConfigPath))
            {
                Write-Verbose 'Checking for changes to nuget.config'
                $CurrentNugetConfig = Get-BrownserveContent -Path $NugetConfigPath -ErrorAction 'Stop'
                $NugetConfigCompare = Compare-Object `
                    -ReferenceObject $CurrentNugetConfig.Content `
                    -DifferenceObject $NewNugetConfig.Content `
                    -SyncWindow 1 `
                    -ErrorAction 'Stop'
                if ($NugetConfigCompare)
                {
                    Write-Verbose 'Changes detected in nuget.config'
                    $ChangedFiles += [BrownserveContent]@{
                        Path       = $NugetConfigPath
                        Content    = $NewNugetConfig.Content
                        LineEnding = 'LF'
                    }
                }
            }
            else
            {
                Write-Verbose 'No existing nuget.config found, will create a new one.'
                $MissingFiles += [BrownserveContent]@{
                    Path       = $NugetConfigPath
                    Content    = $NewNugetConfig.Content
                    LineEnding = 'LF'
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
            try
            {
                $dotnetToolsContent = Get-Content $dotnetToolsTempPath -ErrorAction 'Stop'
            }
            catch
            {
                throw "Failed to read dotnet-tools.json content.`n$($_.Exception.Message)"
            }
            Write-Verbose 'No existing dotnet-tools.json found, will create a new one.'
            $MissingFiles += [BrownserveContent]@{
                Path       = $dotnetToolsPath
                Content    = $dotnetToolsContent
                LineEnding = 'LF'
            }
        }

        if ($CurrentInitContent)
        {
            Write-Verbose 'Checking for changes to _init.ps1'
            $InitCompare = Compare-Object `
                -ReferenceObject $CurrentInitContent.Content `
                -DifferenceObject $NewInitScriptContent.Content `
                -SyncWindow 1 `
                -ErrorAction 'Stop'
            if ($InitCompare)
            {
                Write-Verbose 'Changes detected in _init.ps1'
                $ChangedFiles += [BrownserveContent]@{
                    Path       = $InitPath
                    Content    = $NewInitScriptContent.Content
                    LineEnding = 'LF'
                }
            }
        }
        else
        {
            Write-Verbose 'No existing _init.ps1 found, will create a new one.'
            $MissingFiles += [BrownserveContent]@{
                Path       = $InitPath
                Content    = $NewInitScriptContent.Content
                LineEnding = 'LF'
            }
        }

        if ($CurrentGitIgnores)
        {
            Write-Verbose 'Checking for changes to .gitignore'
            $GitIgnoreCompare = Compare-Object `
                -ReferenceObject $CurrentGitIgnores.Content `
                -DifferenceObject $NewGitIgnoresContent.Content `
                -SyncWindow 1 `
                -ErrorAction 'Stop'
            if ($GitIgnoreCompare)
            {
                Write-Verbose 'Changes detected in .gitignore'
                $ChangedFiles += [BrownserveContent]@{
                    Path       = $GitIgnorePath
                    Content    = $NewGitIgnoresContent.Content
                    LineEnding = 'LF'
                }
            }
        }
        else
        {
            Write-Verbose 'No existing .gitignore found, will create a new one.'
            $MissingFiles += [BrownserveContent]@{
                Path       = $GitIgnorePath
                Content    = $NewGitIgnoresContent.Content
                LineEnding = 'LF'
            }
        }

        # Ensure the VS Code directory exists
        if (!(Test-Path $VSCodePath))
        {
            $MissingDirectories += [pscustomobject]@{
                Path = $VSCodePath
            }
        }

        try
        {
            $VSCodeWorkspaceExtensionIDsJSON = ConvertTo-Json `
                -InputObject @{ recommendations = $VSCodeWorkspaceExtensionIDs } `
                -Depth 100 `
                -ErrorAction 'Stop'
            $VSCodeWorkspaceExtensionIDsJSON = $VSCodeWorkspaceExtensionIDsJSON.Split("`n") -replace "`r",''
            if ((Test-Path $VSCodeExtensionsFilePath))
            {
                Write-Verbose 'Checking for changes to VS Code extensions.json'
                $CurrentVSCodeExtensions = Get-BrownserveContent -Path $VSCodeExtensionsFilePath -ErrorAction 'Stop'
                $VSCodeExtensionsCompare = Compare-Object `
                    -ReferenceObject $CurrentVSCodeExtensions.Content `
                    -DifferenceObject $VSCodeWorkspaceExtensionIDsJSON `
                    -SyncWindow 1 `
                    -ErrorAction 'Stop'
                if ($VSCodeExtensionsCompare)
                {
                    Write-Verbose 'Changes detected in VS Code extensions.json'
                    $ChangedFiles += [BrownserveContent]@{
                        Path       = $VSCodeExtensionsFilePath
                        Content    = $VSCodeWorkspaceExtensionIDsJSON
                        LineEnding = 'LF'
                    }
                }
            }
            else
            {
                Write-Verbose 'No existing extensions.json found, will create a new one.'
                $MissingFiles += [BrownserveContent]@{
                    Path       = $VSCodeExtensionsFilePath
                    Content    = $VSCodeWorkspaceExtensionIDsJSON
                    LineEnding = 'LF'
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
            $VSCodeWorkspaceSettingsJSON = $VSCodeWorkspaceSettingsJSON.Split("`n") -replace "`r",''
            if ((Test-Path $VSCodeWorkspaceSettingsFilePath))
            {
                Write-Verbose 'Checking for changes to VS Code settings.json'
                $CurrentVSCodeWorkspaceSettings = Get-BrownserveContent -Path $VSCodeWorkspaceSettingsFilePath -ErrorAction 'Stop'
                $VSCodeWorkspaceSettingsCompare = Compare-Object `
                    -ReferenceObject $CurrentVSCodeWorkspaceSettings.Content `
                    -DifferenceObject $VSCodeWorkspaceSettingsJSON `
                    -SyncWindow 1 `
                    -ErrorAction 'Stop'
                if ($VSCodeWorkspaceSettingsCompare)
                {
                    Write-Verbose 'Changes detected in VS Code settings.json'
                    $ChangedFiles += [BrownserveContent]@{
                        Path       = $VSCodeWorkspaceSettingsFilePath
                        Content    = $VSCodeWorkspaceSettingsJSON
                        LineEnding = 'LF'
                    }
                }
            }
            else
            {
                Write-Verbose 'No existing settings.json found, will create a new one.'
                $MissingFiles += [BrownserveContent]@{
                    Path       = $VSCodeWorkspaceSettingsFilePath
                    Content    = $VSCodeWorkspaceSettingsJSON
                    LineEnding = 'LF'
                }
            }
        }
        catch
        {
            throw "Failed to process '$VSCodeWorkspaceSettingsFilePath'.`n$($_.Exception.Message)"
        }

        if ($NewPaketDependenciesContent)
        {
            try
            {
                if ((Test-Path $PaketDependenciesPath))
                {
                    Write-Verbose 'Checking for changes to paket.dependencies'
                    $CurrentPaketDependencies = Get-BrownserveContent -Path $PaketDependenciesPath -ErrorAction 'Stop'
                    $PaketDependenciesCompare = Compare-Object `
                        -ReferenceObject $CurrentPaketDependencies.Content `
                        -DifferenceObject $NewPaketDependenciesContent.Content `
                        -SyncWindow 1 `
                        -ErrorAction 'Stop'
                    if ($PaketDependenciesCompare)
                    {
                        Write-Verbose 'Changes detected in paket.dependencies'
                        $ChangedFiles += [BrownserveContent]@{
                            Path       = $PaketDependenciesPath
                            Content    = $NewPaketDependenciesContent.Content
                            LineEnding = 'LF'
                        }
                    }
                }
                else
                {
                    Write-Verbose 'No existing paket.dependencies found, will create a new one.'
                    $MissingFiles += [BrownserveContent]@{
                        Path       = $PaketDependenciesPath
                        Content    = $NewPaketDependenciesContent.Content
                        LineEnding = 'LF'
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
                        Write-Verbose 'Checking for changes to devcontainer.json'
                        $CurrentDevcontainer = Get-BrownserveContent -Path $DevcontainerPath -ErrorAction 'Stop'
                        $DevcontainerCompare = Compare-Object `
                            -ReferenceObject $CurrentDevcontainer.Content `
                            -DifferenceObject $Devcontainer.Devcontainer `
                            -SyncWindow 1 `
                            -ErrorAction 'Stop'
                        if ($DevcontainerCompare)
                        {
                            Write-Verbose 'Changes detected in devcontainer.json'
                            $ChangedFiles += [BrownserveContent]@{
                                Path       = $DevcontainerPath
                                Content    = $Devcontainer.Devcontainer
                                LineEnding = 'LF'
                            }
                        }
                    }
                    else
                    {
                        Write-Verbose 'No existing devcontainer.json found, will create a new one.'
                        $MissingFiles += [BrownserveContent]@{
                            Path       = $DevcontainerPath
                            Content    = $Devcontainer.Devcontainer
                            LineEnding = 'LF'
                        }
                    }
                }
                else
                {
                    Write-Verbose 'No existing .devcontainer directory found, will create a new one.'
                    $MissingDirectories += [pscustomobject]@{
                        Path = $DevcontainerDirectoryPath
                    }
                    $MissingFiles += [BrownserveContent]@{
                        Path       = $DevcontainerPath
                        Content    = $Devcontainer.Devcontainer
                        LineEnding = 'LF'
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
                    Write-Verbose 'Checking for changes to Dockerfile'
                    $CurrentDockerfile = Get-BrownserveContent -Path $DockerfilePath -ErrorAction 'Stop'
                    $DockerfileCompare = Compare-Object `
                        -ReferenceObject $CurrentDockerfile `
                        -DifferenceObject $Devcontainer.Dockerfile `
                        -SyncWindow 1 `
                        -ErrorAction 'Stop'
                    if ($DockerfileCompare)
                    {
                        $ChangedFiles += [BrownserveContent]@{
                            Path       = $DockerfilePath
                            Content    = $Devcontainer.Dockerfile
                            LineEnding = 'LF'
                        }
                    }
                }
                else
                {
                    Write-Verbose 'No existing Dockerfile found, will create a new one.'
                    $MissingFiles += [BrownserveContent]@{
                        Path       = $DockerfilePath
                        Content    = $Devcontainer.Dockerfile
                        LineEnding = 'LF'
                    }
                }
            }
            catch
            {
                throw "Failed to process '$DockerfilePath'.`n$($_.Exception.Message)"
            }
        }

        if ($NewEditorConfigContent)
        {
            try
            {
                if ((Test-Path $EditorConfigPath))
                {
                    try
                    {
                        Write-Verbose 'Checking for changes to .editorconfig'
                        $CurrentEditorConfig = Get-BrownserveContent -Path $EditorConfigPath -ErrorAction 'Stop'
                        $EditorConfigCompare = Compare-Object `
                            -ReferenceObject $CurrentEditorConfig.Content `
                            -DifferenceObject $NewEditorConfigContent.Content `
                            -SyncWindow 1 `
                            -ErrorAction 'Stop'
                        if ($EditorConfigCompare)
                        {
                            Write-Verbose 'Changes detected in .editorconfig'
                            $ChangedFiles += [BrownserveContent]@{
                                Path       = $EditorConfigPath
                                Content    = $NewEditorConfigContent.Content
                                LineEnding = 'LF'
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
                    Write-Verbose 'No existing .editorconfig found, will create a new one.'
                    $MissingFiles += [BrownserveContent]@{
                        Path       = $EditorConfigPath
                        Content    = $NewEditorConfigContent.Content
                        LineEnding = 'LF'
                    }
                }
            }
            catch
            {
                throw "Failed to process '$EditorConfigPath'.`n$($_.Exception.Message)"
            }
        }

        <#
            For the changelog we only test to ensure it exists, we don't want to make any changes to it.
        #>
        if ($Changelog -eq $true)
        {
            if (!(Test-Path $ChangelogPath))
            {
                $MissingFiles += [BrownserveContent]@{
                    Path       = $ChangelogPath
                    Content    = ''
                    LineEnding = 'LF'
                }
            }
        }

        <#
            We don't ever want to overwrite the license file if it already exists, any changes to the license file
            should be made manually for legal reasons.
        #>
        if ($LicenseType)
        {
            if (!(Test-Path $LicensePath))
            {
                $MissingFiles += [BrownserveContent]@{
                    Path       = $LicensePath
                    Content    = $NewLicenseContent
                    LineEnding = 'LF'
                }
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

