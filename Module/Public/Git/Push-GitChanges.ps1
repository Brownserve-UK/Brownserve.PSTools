<#
.SYNOPSIS
    Pushes local git changes to the remote repository.
.DESCRIPTION
    This cmdlet pushes local git changes to the remote repository.
#>
function Push-GitChanges
{
    [CmdletBinding()]
    param
    (
        # The name of the branch to push
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0
        )]
        [string]
        $BranchName,

        # The path to the repository
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 1
        )]
        [string]
        $RepositoryPath = $PWD,

        # The name of the remote repository
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 2
        )]
        [string]
        $RemoteName = 'origin'
    )
    begin
    {
        Assert-Directory $RepositoryPath -ErrorAction 'Stop'
    }
    process
    {
        try
        {
            Invoke-NativeCommand `
                -FilePath 'git' `
                -ArgumentList @('push', '--set-upstream', $RemoteName, $BranchName) `
                -WorkingDirectory $RepositoryPath `
                -SuppressOutput `
                -ErrorAction 'Stop'
        }
        catch
        {
            throw "Failed to push changes to remote repository.`n$($_.Exception.Message)"
        }
    }
    end
    {
    }
}
