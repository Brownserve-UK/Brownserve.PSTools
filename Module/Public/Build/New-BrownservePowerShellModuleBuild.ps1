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
                $FilesToCheck = @( $BuildWorkflowPath, $ReleaseWorkflowPath)

                $FilesToCheck | Assert-PathDoesNotExist

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

                # This command is used to run the module build script, we build up the params separately and splat them in
                $RunCommand = "./$($ModuleInfo.Name)/.build/build.ps1 @Params"

                # Params for building/testing the module
                $BuildTestParams = @"
`$Params = @{
    BranchName = `$env:GITHUB_REF
    GitHubRepoName = '$RepoName'
    Build = 'BuildTestAndCheck'
    Verbose = `$true
}
"@
                # Steps for building and testing the module
                $StageReleaseParams = @"
`$Params = @{
    BranchName = `$env:GITHUB_REF
    GitHubRepoName = '$RepoName'
    Build = 'StageRelease'
    GitHubStageReleaseToken = `$env:GitHubPAT
    ReleaseType = '`${{inputs.release_type}}'
    UseWorkingCopy = `$true
    Verbose = `$true
    }
    if (`$env:ReleaseNotice)
    {
        `$Params.Add('ReleaseNotice', `$env:ReleaseNotice)
    }
"@
            $ReleaseParams = @"
`$Params = @{
    BranchName = `$env:GITHUB_REF
    GitHubRepoName = '$RepoName'
    Build = 'Release'
    GitHubReleaseToken = `$env:GitHubPAT
    NugetFeedAPIKey = `$env:NugetFeedAPIKey
    PSGalleryAPIKey = `$env:PSGalleryAPIKey
    PublishTo = `${{ inputs.publish_to }}
    Verbose = `$true
}
"@
                $BuildSteps = $DefaultSteps
                $BuildSteps += [ordered]@{
                    name  = 'run-build-script'
                    shell = 'pwsh'
                    run   = $BuildTestParams + "`n" + $RunCommand
                }

                $BuildJobs = @{
                    JobTitle = 'BuildTestAndCheck'
                    RunsOn   = 'ubuntu-latest'
                    Steps    = $BuildSteps
                }

                $StageReleaseSteps = $DefaultSteps
                # We need to fetch the full history so that we can determine the changelog entries from the previous release
                $StageReleaseSteps[0].with.Add('fetch-depth', 0)
                $StageReleaseSteps += [ordered]@{
                    name  = 'stage-release'
                    shell = 'pwsh'
                    run   = $StageReleaseParams + "`n" + $RunCommand
                }

                $ReleaseSteps = $DefaultSteps
                $ReleaseSteps += [ordered]@{
                    name  = 'build-and-release-module'
                    shell = 'pwsh'
                    run   = $ReleaseParams + "`n" + $RunCommand
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
                    $StageReleaseWorkflowContent = New-GitHubActionsWorkflow `
                        -Name 'stage-release' `
                        -ExecuteOn 'workflow_dispatch' `
                        -Jobs $StageReleaseJobs
                    if (!$StageReleaseWorkflowContent)
                    {
                        throw 'Workflow content empty'
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
                Write-Verbose "Stage release workflow content:`n$StageReleaseWorkflowContent"
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
                    New-Item $StageReleaseWorkflowPath -ItemType File -Value $StageReleaseWorkflowContent -ErrorAction 'Stop' | Out-Null
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
