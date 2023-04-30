function Copy-BrownserveRepoBuildTemplates
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
        $Force

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
                $Check = Get-Command $Tool
                if (!$Check)
                {
                    Write-Error "'$Tool' is not available on your path. This is required to configure a Brownserve repo"
                }
            }
    
        }
        catch
        {
            throw $_.Exception.Message
        }
    }
    
    process
    {
        Assert-Directory $RepoPath -ErrorAction 'Stop'

        # The below paths will always need to exist and we should check for them to avoid causing any mishaps even if we are going to do this on a branch
        $InitPath = Join-Path $BuildDirectory '_init.ps1'
        $PaketDependenciesPath = Join-Path $RepoPath 'paket.dependencies'
        $dotnetToolsPath = Join-Path $RepoPath '.config' 'dotnet-tools.json'
        $NugetConfigPath = Join-Path $RepoPath 'nuget.config'
        $GitIgnorePath = Join-Path $RepoPath '.gitignore'

        $PathsToTest = @($InitPath, $PaketDependenciesPath, $dotnetToolsPath, $NugetConfigPath)
        $PathsToTest | ForEach-Object {
            if ((Test-Path $_))
            {
                throw "It looks like this project has already been at least partially initialized as the path '$_' already exists.`nPlease use '' to update the project or the '-Force' parameter to forcefully overwrite the files."
            }
        }

        # Ensure we have a directory where we can create some staging files before writing them to the repo
        try
        {
            $TempDir = New-BrownserveTempDirectory
        }
        catch
        {
            throw "Failed to create temporary directory.`n$($_.Exception.Message)"
        }

        # Create our list of permanent paths that should be sync'd to git and not deleted between init's
        $PermanentPaths = @(@{
                VariableName = 'BrownserveRepoBuildDirectory'
                Path         = '.build'
                Description  = 'Holds all build related configuration along with this _init script'
                LocalPath    = (Join-Path $RepoPath '.build')
            })

        # And our list of ephemeral paths that are gitignored and recreated between init's
        $EphemeralPaths = @(
            @{
                VariableName = 'BrownserveRepoTempDirectory'
                Path         = '.tmp'
                Description  = 'Used to store temporary files created for builds/tests'
            },
            @{
                VariableName = 'BrownserveRepoLogDirectory'
                Path         = '.tmp'
                ChildPaths   = 'logs'
                Description  = 'Used to store build logs, output from Invoke-NativeCommand and the like'
            },
            @{
                VariableName = 'BrownserveRepoBuildOutputDirectory'
                Path         = '.tmp'
                ChildPaths   = 'output'
                Description  = 'Used to store any output from builds (e.g. Terraform plans, MSBuild artifacts etc)'
            },
            @{
                VariableName = 'BrownserveRepoBinaryDirectory'
                Path         = '.tmp'
                ChildPaths   = 'bin'
                Description  = 'Used to store any downloaded/copied binaries required for builds, cmdlets like Get-Vault make use of this variable'
            },
            @{
                VariableName = 'BrownserveRepoNugetPackagesDirectory'
                Path         = 'Packages'
                Description  = 'Paket/nuget will restore their dependencies to this directory'
            },
            @{
                VariableName = 'BrownserveRepoPaketFilesDirectory'
                Path         = 'paket-files'
                Description  = 'Paket will restore certain types of dependencies to this directory'
            },
            @{
                VariableName = 'BrownservePaketLockFile'
                Path         = 'paket.lock'
                Description  = 'We deliberately regenerate this every time because we live on the edge and always take the latest versions of our packages. 🤠'
            }
        )

        # Check what branch we are on
        try
        {
            $CurrentBranch = Invoke-NativeCommand `
                -FilePath 'git' `
                -ArgumentList @('rev-parse', '--abbrev-ref', 'HEAD') `
                -WorkingDirectory $RepoPath `
                -PassThru `
                -SuppressOutput `
                -ErrorAction 'Stop'
            $CurrentBranch = $CurrentBranch | Select-Object -ExpandProperty 'OutputContent'
        }
        catch
        {
            if ($CurrentBranch.ExitCode -eq 128)
            {
                throw "Repository at '$RepoPath' does not appear to have been configured in git yet."
            }
            else
            {
                throw $_.Exception.Message
            }
        }

        # Make sure we're running on a branch
        if ($CurrentBranch -ne 'brownserve_repo_init')
        {
            try
            {
                Invoke-NativeCommand `
                    -FilePath 'git' `
                    -ArgumentList @('branch', 'brownserve_repo_init') `
                    -WorkingDirectory $RepoPath `
                    -PassThru `
                    -SuppressOutput `
                    -ErrorAction 'Stop'
            }
            catch
            {
                throw "Failed to create working branch.`n$($_.Exception.Message)"
            }
        }
        
        # Build up our default list of git-ignores that we always want to use
        # TODO: Do we want to make ignoring paket.lock optional?
        $GitIgnores = @(
            @{
                Item    = @(
                    'paket.lock',
                    'packages/',
                    'paket-files/'
                )
                Comment = "Ignore paket related things,`nWe deliberately ignore the 'paket.lock' file in the hopes of always taking the latest packages"
            },
            @{
                Item    = '.tmp/'
                Comment = "Ignore our temporary directory that's used for storing build output and such"
            },
            @{
                Item    = '*.log'
                Comment = 'Ignore any log files that get created by things like "Invoke-NativeCommand"'
            }
        )

        # Set-up the paket dependency that are common to all our projects
        $PaketDependencies = @(
            @{
                Comment = 'We use Invoke-Build to run our builds'
                Rule    = @{
                    Source      = 'nuget'
                    PackageName = 'Invoke-Build'
                }
            }
        )

        switch ($BuildType)
        {
            'PowerShellModule'
            {
                $PermanentPaths += @(@{
                        VariableName = 'BrownserveModuleDirectory'
                        Path         = 'Module'
                        Description  = 'Stores our module'
                        LocalPath    = (Join-Path $RepoPath 'Module')
                    })
                <# 
                    For a repo that houses a PowerShell module we'll want to include:
                        - The logic for loading the module as part of the _init script
                        - PlatyPS for building module documentation
                        - powershell-yaml for working with CI/CD files
                        - Invoke-Build/Pester for building and testing the module
                #>
                $InitParams = @{
                    PermanentPaths        = $PermanentPaths
                    EphemeralPaths        = $EphemeralPaths
                    IncludeModuleLoader   = $true
                    IncludePowerShellYaml = $true
                    IncludePlatyPS        = $true
                    IncludeBuildTestTools = $true
                }
                # We shouldn't need any special git ignores
                $GitIgnoreParams = @{
                    GitIgnores = $GitIgnores
                }

                $ExtraPaketDeps = @(
                    @{
                        Comment = 'We use Pester for unit testing our module'
                        Rule    = @{
                            PackageName = 'Pester'
                            Source      = 'nuget'
                        }
                    },
                    @{
                        Comment = 'We currently have to build PlatyPS from source so download that from GitHub'
                        Rule    = @{
                            Source      = 'github'
                            PackageName = 'PowerShell/platyPS:v2'
                        }
                    }
                )

                $PaketParams = @{
                    PaketDependencies = ($PaketDependencies + $ExtraPaketDeps)
                }

            }
            Default
            {}
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
            $dotnetToolsTempPath = Join-Path $TempDir '.config' 'dotnet-tools.json'
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

        # Now we have everything we need then we can start creating files on disk!
        try
        {
            Move-Item $NugetConfigTempPath -Destination $NugetConfigPath -Force:$Force
        }
        catch
        {
            throw "Failed to write '$NugetConfigPath'.`n$($_.Exception.Message)"
        }
        try
        {
            Move-Item $dotnetToolsTempPath -Destination $dotnetToolsPath -Force:$Force
        }
        catch
        {
            throw "Failed to write '$dotnetToolsPath'.`n$($_.Exception.Message)"
        }

        try
        {
            New-Item $InitPath -Value $InitScriptContent -ItemType File -Force:$Force
        }
        catch
        {
            throw "Failed to write '$InitPath'.`n$($_.Exception.Message)"
        }

        try
        {
            New-Item $GitIgnorePath -ItemType File -Value $GitIgnoresContent -Force:$Force
        }
        catch
        {
            throw "Failed to write '$GitIgnorePath'.`n$($_.Exception.Message)"
        }

        if ($PaketDependenciesContent)
        {
            try
            {
                New-Item -Value $PaketDependenciesPath -ItemType File -Value $PaketDependenciesContent -Force:$Force
            }
            catch
            {
                throw "Failed to write '$PaketDependenciesPath'.`n$($_.Exception.Message)"
            }
        }

        try
        {
            $PermanentPaths.GetEnumerator() | ForEach-Object {
                New-Item $_.LocalPath -ItemType 'Directory' -Force:$Force # I think these should _always_ be directories, but we may need to rethink this if not!
            }
        }
        catch
        {
            throw "Failed to create permanent paths.`n$($_.Exception.Message)"
        }
    }
    
    end
    {
        
    }
}