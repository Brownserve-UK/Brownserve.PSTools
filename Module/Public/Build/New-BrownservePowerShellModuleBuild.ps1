function New-BrownservePowerShellModuleBuild
{
    [CmdletBinding()]
    param
    (
        # The CI/CD provider
        [Parameter(Mandatory = $true)]
        [BrownserveCICD]
        $CICDProvider,

        # The module information
        [Parameter(Mandatory = $true)]
        [BrownservePowerShellModule]
        $ModuleInfo,

        # The path to where the repo is that contains the module
        [Parameter(Mandatory = $true)]
        [string]
        $RepoPath,

        # The name of the repository this module lives in
        [Parameter(Mandatory = $false)]
        [string]
        $RepoName
    )
    
    begin
    {
        try
        {
            Assert-Directory $RepoPath
            $RepoPath = $RepoPath | Convert-Path # Ensure the path is recorded fully
        }
        catch
        {
            throw "$($_.Exception.Message)"
        }
        if (!$RepoName)
        {
            Write-Verbose "No repo name, using directory name"
            $RepoName = Split-Path $RepoPath -Leaf
        }
        if (!$RepoName)
        {
            throw "Cannot determine RepoName automatically."
        }
    }
    
    process
    {
        switch ($CICDProvider)
        {
            'GitHubActions'
            {
                $GitHubDirectory = Join-Path $RepoPath '.github'
                $WorkflowDirectory = Join-Path $GitHubDirectory 'workflows'
                $BuildWorkflowPath = Join-Path $WorkflowDirectory 'build.yaml'
                $ReleaseWorkflowPath = Join-Path $WorkflowDirectory 'release.yaml'

                if ((Test-Path $BuildWorkflowPath))
                {
                    throw "Build workflow already exists at '$BuildWorkflowPath'"
                }
                if ((Test-Path $ReleaseWorkflowPath))
                {
                    throw "Build workflow already exists at '$ReleaseWorkflowPath'"
                }

                # These steps are always needed regardless of the build
                $DefaultSteps = @(
                    [ordered]@{
                        name = 'checkout-module'
                        uses = 'actions/checkout@v3'
                        with = @{
                            path = $ModuleInfo.Name
                        }
                    }
                )

                # Steps for building and testing the module
                $BuildRunCommand = @"
./$($ModuleInfo.Name)/.build/build.ps1 ``
-GitHubRepoName '$RepoName' ``
-BranchName `$env:GITHUB_REF ``
-Verbose
"@
                $BuildSteps = $DefaultSteps
                $BuildSteps += [ordered]@{
                    name  = 'build-and-test-module'
                    shell = 'pwsh'
                    run   = $BuildRunCommand
                }

                $BuildJobs = @{
                    JobTitle = 'build-and-test'
                    RunsOn   = 'ubuntu-latest'
                    Steps    = $BuildSteps
                }

                # Steps for releasing the module
                $ReleaseRunCommand = @"
./$($ModuleInfo.Name)/.build/build.ps1 ``
-GitHubRepoName '$RepoName' ``
-BranchName `$env:GITHUB_REF ``
-Build release ``
-NugetFeedAPIKey `$env:NugetFeedAPIKey ``
-PSGalleryAPIKey `$env:PSGalleryAPIKey ``
-Verbose
"@

                $ReleaseSteps = $DefaultSteps
                $ReleaseSteps += [ordered]@{
                    name  = 'build-and-release-module'
                    shell = 'pwsh'
                    run   = $ReleaseRunCommand
                }
                
                $ReleaseJobs = @{
                    JobTitle = 'release'
                    RunsOn   = 'ubuntu-latest'
                    Steps    = $ReleaseSteps
                }
                
                try
                {
                    $BuildWorkflowContent = New-GitHubActionsWorkflow `
                        -Name 'build' `
                        -ExecuteOn 'pull_request' `
                        -Jobs $BuildJobs
                    if (!$BuildWorkflowContent)
                    {
                        throw 'Workflow content empty.'
                    }
                    $ReleaseWorkflowContent = New-GitHubActionsWorkflow `
                        -Name 'release' `
                        -ExecuteOn 'workflow_dispatch' `
                        -Jobs $ReleaseJobs
                    if (!$ReleaseWorkflowContent)
                    {
                        throw 'Workflow content empty'
                    }
                }
                catch
                {
                    throw "Failed to create GitHub Actions workflow.`n$($_.Exception.Message)"
                }
                Write-Verbose "Build workflow content:`n$BuildWorkflowContent"
                Write-Verbose "Release workflow content:`n$ReleaseWorkflowContent"
                try
                {
                    if (!(Test-Path $GitHubDirectory))
                    {
                        New-Item $GitHubDirectory -ItemType Directory -ErrorAction 'Stop' | Out-Null
                    }
                    if (!(Test-Path $WorkflowDirectory))
                    {
                        New-Item $WorkflowDirectory -ItemType Directory -ErrorAction 'stop' | Out-Null
                    }
                    New-Item $BuildWorkflowPath -ItemType File -Value $BuildWorkflowContent -ErrorAction 'Stop' | Out-Null
                    New-Item $ReleaseWorkflowPath -ItemType File -Value $ReleaseWorkflowContent -ErrorAction 'Stop' | Out-Null
                }
                catch
                {
                    throw "Failed to write workflows to disk.`n$($_.Exception.Message)"
                }
            }
            Default
            {
                throw "Unsupported CI/CD provider '$CICDProvider'"
            }
        }
    }
    
    end
    {
       
    }
}